import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/core/services/loyalty_service.dart';

class MockupPaymentConfirmationScreen extends StatefulWidget {
  final String merchantId;
  final String merchantName;
  final String amount;

  const MockupPaymentConfirmationScreen({
    super.key,
    required this.merchantId,
    required this.merchantName,
    required this.amount,
  });

  @override
  State<MockupPaymentConfirmationScreen> createState() => _MockupPaymentConfirmationScreenState();
}

class _MockupPaymentConfirmationScreenState extends State<MockupPaymentConfirmationScreen> {
  String _selectedYapaId = 'NINGUNA';
  List<ActiveYapa> _availableYapas = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableYapas();
  }

  Future<void> _loadAvailableYapas() async {
    try {
      final profile = await LoyaltyService().fetchProfile();
      final entry = profile.firstWhere(
        (e) => e.merchantId == widget.merchantId,
        orElse: () => LoyaltyProfileEntry(
          merchantId: widget.merchantId,
          merchantName: widget.merchantName,
          tierLevel: 1,
          trustPoints: 0,
          pointsToNextCoupon: null,
          activeYapas: [],
          yapasCount: 0,
          totalYapasValue: 0.0,
        ),
      );
      if (mounted) {
        setState(() {
          _availableYapas = entry.activeYapas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processPayment(double finalAmount) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      final amountNum = double.tryParse(widget.amount.replaceAll(',', '.')) ?? 0;
      final yapaId = _selectedYapaId == 'NINGUNA' ? null : _selectedYapaId;
      
      final result = await LoyaltyService().scanTransaction(
        widget.merchantId,
        amountNum,
        couponId: yapaId,
      );

      if (mounted) {
        context.pushNamed(
          'payment_receipt',
          extra: {
            'amount': finalAmount.toStringAsFixed(2),
            'merchantName': widget.merchantName,
            'result': result,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al pagar: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double originalAmount = double.tryParse(widget.amount.replaceAll(',', '.')) ?? 0.0;
    
    ActiveYapa? selectedYapa;
    if (_selectedYapaId != 'NINGUNA') {
      try {
        selectedYapa = _availableYapas.firstWhere((y) => y.id == _selectedYapaId);
      } catch (e) {
        selectedYapa = null;
      }
    }

    double discountAmount = selectedYapa?.value ?? 0.0;
    // Evitar saldo negativo
    double discountedAmount = originalAmount - discountAmount;
    if (discountedAmount < 0) discountedAmount = 0;

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
                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Color(0xFF4A1587))))
                    else if (_availableYapas.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2F9),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('¡Boom!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                                    const SizedBox(height: 4),
                                    Text('Tienes ${_availableYapas.length} yapas disponibles', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3B1066))),
                                    const SizedBox(height: 2),
                                    const Text('Aplica tu descuento antes de pagar', style: TextStyle(fontSize: 14, color: Color(0xFF4D4D4D))),
                                  ],
                                ),
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
                      iconWidget: Text(widget.merchantName.substring(0, 2).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      iconColor: const Color(0xFF4A1587),
                      label: 'Para',
                      title: widget.merchantName,
                      subtitle: 'Banco Pichincha ******5424',
                    ),
                    const SizedBox(height: 24),
                    
                    // Block 2: Monto
                    _buildListTile(
                      iconWidget: const Text('\$', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18)),
                      iconColor: const Color(0xFFF3F4F6),
                      label: 'Monto original',
                      title: 'USD \$$displayOriginal',
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
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // --- Dropdown Yapa ---
                    if (!_isLoading && _availableYapas.isNotEmpty)
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
                              const Row(
                                children: [
                                  Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('¡Utiliza tu Yapa!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF4A1587)))),
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
                                    value: _selectedYapaId,
                                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A1587)),
                                    style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w700),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: 'NINGUNA',
                                        child: Text('No usar yapa', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                                      ),
                                      ..._availableYapas.map((ActiveYapa y) {
                                        return DropdownMenuItem<String>(
                                          value: y.id,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Yapa de descuento', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold)),
                                              Text('-\$${y.value.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w900)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedYapaId = newValue;
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
                      if (selectedYapa != null)
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
                      onPressed: _isProcessing ? null : () => _processPayment(discountedAmount),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A1587),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isProcessing 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Pagar', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
