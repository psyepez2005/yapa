import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMerchantId();
  }

  Future<void> _loadMerchantId() async {
    final id = await TokenStorage.getMerchantId();
    if (mounted) setState(() => _merchantId = id);
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
                  onTap: () => setState(() => _currentTab = 1),
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
                            data: 'deuna://merchant/$_merchantId',
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
    return SingleChildScrollView(
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
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
                        children: const [
                          Text('\$0,05', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                          Icon(Icons.remove_red_eye, color: Colors.black87, size: 20),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
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
            
            const SizedBox(height: 40),

            // Trazabilidad de Yapa
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF7FF), // Lila pálido
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                           Text('🎁', style: TextStyle(fontSize: 18)),
                           SizedBox(width: 8),
                           Text('Trazabilidad de Yapa', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A1587), fontSize: 16)),
                        ],
                      ),
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
                            children: const [
                              Text('Inversión del negocio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              SizedBox(height: 4),
                              Text('\$4.20', style: TextStyle(color: Color(0xFF4A1587), fontSize: 22, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('2% por cliente · Nivel Plata', style: TextStyle(color: Colors.grey, fontSize: 9)),
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
                            children: const [
                              Text('Vecinos que volvieron', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              SizedBox(height: 4),
                              Text('18', style: TextStyle(color: Color(0xFF0A9E8F), fontSize: 22, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('↑ +6 vs semana anterior', style: TextStyle(color: Color(0xFF0A9E8F), fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
