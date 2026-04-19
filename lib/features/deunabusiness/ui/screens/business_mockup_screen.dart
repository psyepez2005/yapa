import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:yapa/core/models/merchant_stats.dart';
import 'package:yapa/core/services/merchant_service.dart';
import 'package:yapa/core/storage/token_storage.dart';
import '../widgets/business_app_bar.dart';
import '../widgets/business_tab_bar.dart';
import '../widgets/cobrar_view.dart';
import '../widgets/qr_view.dart';
import '../widgets/gestionar_view.dart';

export '../widgets/cobrar_view.dart' show CobrarMode;

class BusinessMockupScreen extends StatefulWidget {
  const BusinessMockupScreen({super.key});

  @override
  State<BusinessMockupScreen> createState() => _BusinessMockupScreenState();
}

class _BusinessMockupScreenState extends State<BusinessMockupScreen> {
  int _currentTab = 0;
  String _amount = '';
  bool _showQR = false;
  CobrarMode _cobrarMode = CobrarMode.qr;
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
      appBar: const BusinessAppBar(),
      body: Column(
        children: [
          BusinessTabBar(
            currentTab: _currentTab,
            onTabChanged: (tab) {
              setState(() {
                _currentTab = tab;
                if (tab == 0) {
                  _showQR = false;
                  _cobrarMode = CobrarMode.qr;
                }
              });
              if (tab == 1 && _stats == null) _loadStats();
            },
          ),
          Expanded(
            child: _currentTab == 0
                ? (_showQR
                    ? QRView(
                        amount: _amount,
                        merchantId: _merchantId,
                        continueLabel: _cobrarMode == CobrarMode.manual
                            ? 'Nuevo Cobro'
                            : 'Continuar para Cobrar',
                        onContinue: () => setState(() {
                          _showQR = false;
                          _amount = '';
                          _cobrarMode = CobrarMode.qr;
                        }),
                      )
                    : CobrarView(
                        amount: _amount,
                        mode: _cobrarMode,
                        onKeyTap: _onKeypadTap,
                        onModeChanged: (newMode) {
                          setState(() {
                            _cobrarMode = newMode;
                            // En modo Manual el QR aparece de inmediato
                            if (newMode == CobrarMode.manual) {
                              _showQR = true;
                            }
                          });
                        },
                        onContinue: () => setState(() {
                          _showQR = true;
                        }),
                      ))
                : GestionarView(
                    stats: _stats,
                    coupons: _coupons,
                    loadingStats: _loadingStats,
                    onRefresh: _loadStats,
                    onTopUp: _showTopUpModal,
                    onCreateCoupon: _showCreateCouponModal,
                  ),
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
