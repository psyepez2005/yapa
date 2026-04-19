import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView extends StatelessWidget {
  final String amount;
  final String? merchantId;
  final String? merchantName;
  final VoidCallback onContinue;
  /// Label for the bottom action button (changes with cobrar mode)
  final String continueLabel;

  const QRView({
    super.key,
    required this.amount,
    required this.merchantId,
    this.merchantName,
    required this.onContinue,
    this.continueLabel = 'Continuar para Cobrar',
  });

  String get _qrData => merchantId == null
      ? ''
      : 'deuna://merchant/$merchantId?amount=$amount&name=${Uri.encodeComponent(merchantName ?? '')}';

  void _copyToClipboard(BuildContext context) {
    if (_qrData.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _qrData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enlace de cobro copiado'),
        backgroundColor: Color(0xFF4A1587),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showVerifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF0A9E8F), size: 28),
            SizedBox(width: 10),
            Text('Verificar pago', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Pide a tu cliente que escanee el QR con la app Deuna.\nEl pago se registrará automáticamente.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A1587),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Instrucción clara para el comerciante
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A1587).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF4A1587), size: 16),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Muéstrale este código a tu cliente para recibir el pago',
                      style: TextStyle(
                          color: Color(0xFF4A1587),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Monto a cobrar',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text('\$$amount',
                style: const TextStyle(
                    fontSize: 56, fontWeight: FontWeight.w700)),
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
                            data: _qrData,
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
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy_outlined, color: Color(0xFF4A1587), size: 20),
                    label: const Text('Copiar enlace', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold)),
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
                    onPressed: () => _showVerifyDialog(context),
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
