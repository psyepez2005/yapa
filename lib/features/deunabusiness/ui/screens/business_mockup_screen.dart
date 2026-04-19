import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yapa/core/models/merchant_stats.dart';
import 'package:yapa/core/services/merchant_service.dart';
import 'package:yapa/core/storage/token_storage.dart';

class BusinessMockupScreen extends StatefulWidget {
  const BusinessMockupScreen({super.key});

  @override
  State<BusinessMockupScreen> createState() => _BusinessMockupScreenState();
}

class _BusinessMockupScreenState extends State<BusinessMockupScreen> {
  int _currentTab = 0;
  String _amount = '';
  bool _showQR = false;
  String? _merchantId;
  MerchantStats? _stats;
  List<MerchantCoupon> _coupons = [];
  bool _loadingStats = false;
  bool _loyaltyEnabled = true;
  bool _togglingLoyalty = false;

  @override
  void initState() {
    super.initState();
    _loadMerchantId();
  }

  Future<void> _loadMerchantId() async {
    final id = await TokenStorage.getMerchantId();
    if (mounted) setState(() => _merchantId = id);
  }

  Future<void> _loadStats() async {
    if (_loadingStats) return;
    setState(() => _loadingStats = true);
    try {
      final service = MerchantService();
      final results = await Future.wait([
        service.fetchStats(),
        service.fetchCoupons(),
      ]);
      if (mounted) {
        final stats = results[0] as MerchantStats;
        setState(() {
          _stats = stats;
          _coupons = results[1] as List<MerchantCoupon>;
          _loyaltyEnabled = stats.loyaltyEnabled;
        });
      }
    } catch (_) {
      // Stats are informational — silently fall back to cached/empty
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _toggleLoyalty(bool enabled) async {
    if (_togglingLoyalty) return;
    setState(() {
      _togglingLoyalty = true;
      _loyaltyEnabled = enabled;
    });
    try {
      await MerchantService().toggleLoyalty(enabled: enabled);
    } on MerchantException catch (e) {
      if (mounted) {
        setState(() => _loyaltyEnabled = !enabled);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingLoyalty = false);
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearAll();
    if (mounted) context.go('/');
  }

  void _showTopUpModal() {
    String amount = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Recargar Saldo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Ingresa el monto a recargar (máx. \$10,000)', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              TextField(
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4A1587), width: 2),
                  ),
                ),
                onChanged: (v) => setModal(() => amount = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A1587),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final parsed = double.tryParse(amount.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return;
                    Navigator.pop(ctx);
                    try {
                      await MerchantService().topUpFund(parsed);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Saldo recargado: \$${parsed.toStringAsFixed(2)}'),
                            backgroundColor: const Color(0xFF0A9E8F),
                          ),
                        );
                        _loadStats();
                      }
                    } on MerchantException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  child: const Text('Recargar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateCouponModal() {
    final valueCtrl = TextEditingController();
    final minPurchaseCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    DateTime? expiresAt;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nueva Yapa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Configura un cupón de descuento para tus clientes', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                _modalField(valueCtrl, 'Valor del descuento', prefix: '\$ ', numeric: true),
                const SizedBox(height: 12),
                _modalField(minPurchaseCtrl, 'Compra mínima requerida', prefix: '\$ ', numeric: true),
                const SizedBox(height: 12),
                _modalField(codeCtrl, 'Código (4-20 caracteres)', hint: 'Ej: YAPA2024'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4A1587)),
                  label: Text(
                    expiresAt == null
                        ? 'Seleccionar fecha de vencimiento'
                        : 'Vence: ${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}',
                    style: const TextStyle(color: Color(0xFF4A1587)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4A1587)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setModal(() => expiresAt = picked);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A1587),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final value = double.tryParse(valueCtrl.text.replaceAll(',', '.'));
                      final minPurchase = double.tryParse(minPurchaseCtrl.text.replaceAll(',', '.'));
                      final code = codeCtrl.text.trim();
                      if (value == null || minPurchase == null || code.length < 4 || expiresAt == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Completa todos los campos correctamente')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      try {
                        final coupon = await MerchantService().createCoupon(
                          value: value,
                          minimumPurchase: minPurchase,
                          code: code,
                          expiresAt: expiresAt!.toIso8601String(),
                        );
                        if (mounted) {
                          setState(() => _coupons = [..._coupons, coupon]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Yapa creada exitosamente'),
                              backgroundColor: Color(0xFF0A9E8F),
                            ),
                          );
                        }
                      } on MerchantException catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    child: const Text('Crear Yapa', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField(
    TextEditingController ctrl,
    String label, {
    String? prefix,
    String? hint,
    bool numeric = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4A1587), width: 2),
        ),
      ),
    );
  }

  void _onKeypadTap(String key) {
    setState(() {
      if (key == 'delete') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else {
        _amount += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 50,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFE8EAF6),
            child: const Icon(Icons.storefront, color: Color(0xFF4A1587), size: 18),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hola! Da...', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('M...', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
          IconButton(icon: const Icon(Icons.headset_mic_outlined, color: Colors.black87), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _currentTab = 0;
                    _showQR = false; // Reset view when switching tabs
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _currentTab == 0 ? const Color(0xFF4A1587) : Colors.transparent, width: 2.5)),
                    ),
                    alignment: Alignment.center,
                    child: Text('Cobrar', style: TextStyle(color: _currentTab == 0 ? const Color(0xFF4A1587) : Colors.blueGrey, fontWeight: _currentTab == 0 ? FontWeight.bold : FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentTab = 1);
                    if (_stats == null) _loadStats();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: _currentTab == 1 ? const Color(0xFF4A1587) : Colors.transparent, width: 2.5)),
                    ),
                    alignment: Alignment.center,
                    child: Text('Gestionar', style: TextStyle(color: _currentTab == 1 ? const Color(0xFF4A1587) : Colors.blueGrey, fontWeight: _currentTab == 1 ? FontWeight.bold : FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
          Container(height: 1.5, color: Colors.grey.shade200),

          Expanded(
            child: _currentTab == 0 
                ? (_showQR ? _buildQRView() : _buildCobrarView()) 
                : _buildGestionarView(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4A1587),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Mi Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Yapa'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }

  Widget _buildCobrarView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Monto', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(_amount.isEmpty ? '\$ 0' : '\$$_amount', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            
            // Toggle Buttons
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A1587),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text('Manual', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Agregar motivo (opcional)', style: TextStyle(color: Colors.grey, fontSize: 15)),
                Icon(Icons.chevron_right, color: Colors.black87),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200, thickness: 1.5),
            const SizedBox(height: 16),

            // Keypad
            _buildKeypad(),
            
            const SizedBox(height: 48),
            // Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (_amount.isNotEmpty) {
                    setState(() {
                      _showQR = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A1587),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continuar para Cobrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQRView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Text('Monto', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 4),
            Text('\$$_amount', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            
            // QR Generator View
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _merchantId == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A1587)))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: QrImageView(
                            data: 'deuna://merchant/$_merchantId?name=${Uri.encodeComponent(_stats?.merchantName ?? '')}&amount=$_amount',
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'd!',
                            style: TextStyle(
                              color: Color(0xFF4A1587),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            
            // Yapa Activa Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5), // Morado muy tenue
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4A1587), width: 1),
              ),
              child: Row(
                children: const [
                  Text('🎁', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Yapa Activa · El cliente recibirá \$0.12 de cashback', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 13)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, color: Color(0xFF4A1587), size: 20),
                    label: const Text('Compartir', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, color: Colors.white, size: 20),
                    label: const Text('Verificar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A1587),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Bottom Continue
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showQR = false;
                    _amount = '';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A1587),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Continuar para Cobrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGestionarView() {
    final stats = _stats;
    return RefreshIndicator(
      color: const Color(0xFF4A1587),
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saldo Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mi Saldo', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _loadingStats
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A1587)))
                                : Text(
                                    '\$${(stats?.balance ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                  ),
                            const SizedBox(width: 12),
                            const Icon(Icons.remove_red_eye, color: Colors.black87, size: 20),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats row: Transacciones + Clientes
              if (stats != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: 'Transacciones',
                        value: stats.totalTransactions.toString(),
                        color: const Color(0xFF4A1587),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        label: 'Clientes totales',
                        value: stats.totalCustomers.toString(),
                        color: const Color(0xFF0A9E8F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (stats.totalRevenue > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A1587), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ingresos totales', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${stats.totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Icon(Icons.trending_up, color: Colors.white70, size: 36),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Loyalty toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A1587).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.loyalty, color: Color(0xFF4A1587), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Programa de Yapas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            _loyaltyEnabled ? 'Activo · Clientes acumulan puntos' : 'Inactivo · Sin acumulación de puntos',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    _togglingLoyalty
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A1587)))
                        : Switch(
                            value: _loyaltyEnabled,
                            onChanged: _toggleLoyalty,
                            activeColor: const Color(0xFF4A1587),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Accesos rapidos
              const Text('Accesos rápidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionIcon(Icons.arrow_downward, 'Recargar\nsaldo'),
                  _buildActionIcon(Icons.arrow_upward, 'Transferir\nsaldo'),
                  _buildActionIcon(Icons.attach_money, 'Venta\nManual'),
                  _buildActionIcon(Icons.verified_user_outlined, 'Verificar\npago'),
                ],
              ),
              const SizedBox(height: 32),

              // Trazabilidad de Yapa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🎁', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              'Trazabilidad de Yapa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A1587),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (_loadingStats)
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A1587)))
                        else
                          const Text('Este mes', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Inversión del negocio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${(stats?.yapaInvestmentTotal ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFF4A1587), fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${((stats?.yapaCashbackRate ?? 0.02) * 100).toInt()}% por cliente',
                                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Vecinos que volvieron', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${stats?.returningCustomersThisMonth ?? 0}',
                                  style: const TextStyle(color: Color(0xFF0A9E8F), fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'de ${stats?.totalCustomers ?? 0} clientes',
                                  style: const TextStyle(color: Color(0xFF0A9E8F), fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cupones activos
              if (_coupons.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Mis Yapas configuradas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._coupons.map((c) => _buildCouponTile(c)),
              ],

              const SizedBox(height: 32),
              // Novedades Deuna Negocios
              const Text('Novedades Deuna Negocios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildNovedadCard('Agrega\nvendedores\na tu equipo')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildNovedadCard('Administra\ntus ventas\ncon tu caja')),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponTile(MerchantCoupon coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: coupon.isActive ? const Color(0xFFE0F7FA) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 20, color: coupon.isActive ? null : Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${coupon.discountValue.toStringAsFixed(2)} de descuento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: coupon.isActive ? const Color(0xFF00897B) : Colors.grey,
                  ),
                ),
                Text(
                  'Nivel requerido: ${coupon.tierRequired}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: coupon.isActive ? const Color(0xFF00BFA5) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              coupon.isActive ? 'Activo' : 'Inactivo',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return Flexible(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 4, offset: const Offset(0, 2))
              ]
            ),
            child: Icon(icon, color: Colors.black87, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildNovedadCard(String text) {
    return Container(
      height: 140, 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.2, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A9E8F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('d!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [',', '0', 'delete'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return SizedBox(
                width: 80,
                height: 50,
                child: InkWell(
                  onTap: () => _onKeypadTap(key),
                  borderRadius: BorderRadius.circular(25),
                  child: Center(
                    child: key == 'delete'
                        ? const Icon(Icons.backspace, color: Color(0xFF4A1587), size: 28)
                        : Text(
                            key,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4A1587), 
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
