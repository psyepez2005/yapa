import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView extends StatelessWidget {
  final String amount;
  final String? merchantId;
  final VoidCallback onContinue;
  /// Label for the bottom action button (changes with cobrar mode)
  final String continueLabel;

  const QRView({
    super.key,
    required this.amount,
    required this.merchantId,
    required this.onContinue,
    this.continueLabel = 'Continuar para Cobrar',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Text('Monto', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 4),
            Text('\$$amount', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w700)),
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
              child: merchantId == null
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A1587)))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: QrImageView(
                            data: 'deuna://merchant/$merchantId',
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

            // Actions Row (Compartir + Verificar — sin card de Yapa Activa)
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
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A1587),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(continueLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
