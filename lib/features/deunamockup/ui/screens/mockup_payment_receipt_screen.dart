import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockupPaymentReceiptScreen extends StatelessWidget {
  final String amount;
  final String merchantName;
  final Map<String, dynamic>? transactionResult;

  const MockupPaymentReceiptScreen({
    super.key,
    required this.amount,
    required this.merchantName,
    this.transactionResult,
  });

  @override
  Widget build(BuildContext context) {
    // Generar formato de fechas simulado
    final now = DateTime.now();
    final dateStr = '${now.day} abr ${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    // Extraer datos del resultado real enviado por AWS
    final String txNumber = transactionResult?['transactionId']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final num trustPointsEarned = transactionResult?['trustPointsEarned'] as num? ?? 0;
    final Map<String, dynamic>? couponApplied = transactionResult?['couponApplied'];
    final Map<String, dynamic>? couponUnlocked = transactionResult?['couponUnlocked'];
    final bool antifraudBlocked = transactionResult?['antifraudBlocked'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF3B1066), // Fondo morado oscuro
      body: SafeArea(
        child: Stack(
          children: [
            // Close button at top right
            Positioned(
              top: 16,
              right: 16,
              child: InkWell(
                onTap: () => context.goNamed('mockup_home'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 20),
                ),
              ),
            ),
            
            // Scrollable Receipt Card
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          // Logo
                          const Text('d!', style: TextStyle(color: Color(0xFF4A1587), fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, fontSize: 40)),
                          const SizedBox(height: 16),
                          // Título
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Pagaste a $merchantName',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF4A1587), fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            antifraudBlocked ? 'Pago bloqueado por prevención de fraude' : 'Tu dinero llegó al instante', 
                            style: TextStyle(color: antifraudBlocked ? Colors.red : Colors.grey, fontSize: 14, fontWeight: antifraudBlocked ? FontWeight.bold : FontWeight.normal),
                          ),
                          const SizedBox(height: 24),
                          // Valor final cobrado
                          Text(
                            '\$$amount',
                            style: const TextStyle(color: Color(0xFF4A1587), fontSize: 48, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 16),
                          
                          // --- YAPA APLICADA INJECTION ---
                          if (couponApplied != null)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '¡Descuento Yapa aplicado! (-\$${(couponApplied['discountAmount'] as num).toStringAsFixed(2)}) 🎁', 
                                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (!antifraudBlocked)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Tienes descuentos solo por pagar con Deuna 🎁',
                                style: TextStyle(color: Color(0xFF4A1587), fontStyle: FontStyle.italic, fontSize: 13),
                              ),
                            ),
                          const SizedBox(height: 24),
                          
                          // Transaction details
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Fecha de pago', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Nro. de transacción', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 13)),
                                Flexible(child: Text(txNumber.length > 15 ? '${txNumber.substring(0, 15)}...' : txNumber, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Earned Pts & Yapa unlocking integration
                          if (!antifraudBlocked)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E5F5), // Light purple
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.stars, color: Color(0xFF4A1587), size: 32),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('¡Suma Deuna Puntos!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A1587))),
                                            Text('Ganaste +$trustPointsEarned pts de confianza', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (couponUnlocked != null) ...[
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: Colors.yellow.shade100, shape: BoxShape.circle),
                                          child: const Text('🎉', style: TextStyle(fontSize: 18)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('¡NUEVA YAPA DESBLOQUEADA!', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                                              Text(couponUnlocked['message']?.toString() ?? 'Recibiste un cupón', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                          const SizedBox(height: 32),
                          
                          // QR Code Mockup (Placeholder elegante)
                          Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.qr_code_2, size: 160, color: Colors.black87),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Text('d!', style: TextStyle(color: Color(0xFF4A1587), fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, fontSize: 20)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shield_outlined, color: Colors.grey, size: 16),
                              SizedBox(width: 4),
                              Text('Código de verificación', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          // Divider line
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 24),
                          
                          // De / Para section
                          _buildTransferParty(title: 'De', initials: 'TÚ', name: 'Tu Cuenta Deuna', subtext: 'Banco Pichincha ******6971', avatarColor: const Color(0xFFEAD8F7)),
                          const SizedBox(height: 16),
                          _buildTransferParty(title: 'Para', initials: merchantName.substring(0, 2).toUpperCase(), name: merchantName, subtext: 'Cobro por escáner de pagos', avatarColor: const Color(0xFFEAD8F7)),
                          
                          const SizedBox(height: 24),
                          // Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.goNamed('mockup_home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A1587),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Ir al inicio', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.share_outlined, color: Color(0xFF4A1587)),
                                label: const Text('Compartir', style: TextStyle(color: Color(0xFF4A1587), fontSize: 16, fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Color(0xFF4A1587), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Volver a pagar text outside the card
                    InkWell(
                      onTap: () => context.pop(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Volver a pagar', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferParty({required String title, required String initials, required String name, required String subtext, required Color avatarColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  child: Text(initials, style: const TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(subtext, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
