import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockupPaymentConfirmationScreen extends StatefulWidget {
  final String amount;

  const MockupPaymentConfirmationScreen({super.key, required this.amount});

  @override
  State<MockupPaymentConfirmationScreen> createState() => _MockupPaymentConfirmationScreenState();
}

class _MockupPaymentConfirmationScreenState extends State<MockupPaymentConfirmationScreen> {
  String _selectedYapa = 'NINGUNA';

  final Map<String, double> _yapaRates = {
    'ORO': 0.03,
    'PLATA': 0.02,
    'BRONCE': 0.01,
  };

  @override
  Widget build(BuildContext context) {
    double originalAmount = double.tryParse(widget.amount.replaceAll(',', '.')) ?? 0.0;
    double discountRate = _yapaRates[_selectedYapa] ?? 0.0;
    
    double discountedAmount = originalAmount * (1 - discountRate);
    String displayOriginal = originalAmount.toStringAsFixed(2);
    String displayDiscounted = discountedAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/mockup'), // Cancelar payment flow
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- ALERTA GENERAL DE YAPA ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2F9), // Celeste utilizado anteriormente
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A1587),
                                shape: BoxShape.circle,
                              ),
                              child: const Text('\$', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('¡Boom!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                                  SizedBox(height: 4),
                                  Text('Tienes yapas disponibles', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3B1066))),
                                  SizedBox(height: 2),
                                  Text('Desliza la pantalla y reclámalas', style: TextStyle(fontSize: 14, color: Color(0xFF4D4D4D))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A1587).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF4A1587)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        'Confirmemos tu pago',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Block 1: Para
                    _buildListTile(
                      iconWidget: const Text('EJ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      iconColor: const Color(0xFF4A1587),
                      label: 'Para',
                      title: 'Emilio Jose',
                      subtitle: 'Banco Pichincha ******5424',
                    ),
                    const SizedBox(height: 24),
                    
                    // Block 2: Monto
                    _buildListTile(
                      iconWidget: const Text('\$', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
                      iconColor: const Color(0xFFF3F4F6),
                      label: 'Monto',
                      title: 'USD \$${widget.amount}',
                      subtitle: null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Block 3: Desde
                    _buildListTile(
                      iconWidget: const Text('d!', style: TextStyle(color: Color(0xFF00BFA5), fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, fontSize: 20)),
                      iconColor: const Color(0xFF4A1587),
                      label: 'Desde',
                      title: 'Mi cuenta Deuna',
                      subtitle: '******8424',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Completaremos tu pago alert box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2F9), // Light blue from image
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Completaremos tu pago', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 4),
                                  Text('Usaremos \$$displayDiscounted de tu cuenta Banco Pichincha *******6971', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Cambiar', style: TextStyle(color: Color(0xFF0F5A9A), fontWeight: FontWeight.bold, fontSize: 14)),
                            )
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // --- NUEVO FEATURE: Dropdown Yapa ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF4A1587).withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                                const SizedBox(width: 8),
                                const Expanded(child: Text('¡Utiliza tu Yapa!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4A1587)))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedYapa,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A1587)),
                                  style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w700),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: 'NINGUNA',
                                      child: Text('Ninguna', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                                    ),
                                    ..._yapaRates.keys.map((String key) {
                                      double calcDiscount = originalAmount * _yapaRates[key]!;
                                      return DropdownMenuItem<String>(
                                        value: key,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Yapa $key', style: const TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold)),
                                            Text('-\$${calcDiscount.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w900)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedYapa = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40), // Padding extra abajo para scroll libre
                  ],
                ),
              ),
            ),
            
            // Footer bottom bar (Total + Button)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total del pago', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      if (_selectedYapa != 'NINGUNA')
                        Row(
                          children: [
                            Text(
                              '\$$displayOriginal', 
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey, decoration: TextDecoration.lineThrough)
                            ),
                            const SizedBox(width: 8),
                            Text('\$$displayDiscounted', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00BFA5))),
                          ],
                        )
                      else
                        Text('\$$displayOriginal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.pushNamed(
                          'payment_receipt',
                          pathParameters: {
                             'amount': displayDiscounted,
                             'yapa': _selectedYapa,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A1587),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Pagar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required Widget iconWidget,
    required Color iconColor,
    required String label,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15)),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}
