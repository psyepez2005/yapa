import 'package:flutter/material.dart';
import 'cobrar_keypad.dart';

enum CobrarMode { qr, manual }

class CobrarView extends StatelessWidget {
  final String amount;
  final CobrarMode mode;
  final ValueChanged<String> onKeyTap;
  final VoidCallback onContinue;
  final ValueChanged<CobrarMode> onModeChanged;

  const CobrarView({
    super.key,
    required this.amount,
    required this.mode,
    required this.onKeyTap,
    required this.onContinue,
    required this.onModeChanged,
  });

  bool get _isAmountValid {
    if (amount.isEmpty) return false;
    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    return parsed != null && parsed > 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Monto', style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              amount.isEmpty ? '\$ 0' : '\$$amount',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Toggle QR / Manual
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onModeChanged(CobrarMode.qr),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: mode == CobrarMode.qr
                              ? const Color(0xFF4A1587)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'QR',
                          style: TextStyle(
                            color: mode == CobrarMode.qr
                                ? Colors.white
                                : const Color(0xFF4A1587),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onModeChanged(CobrarMode.manual),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: mode == CobrarMode.manual
                              ? const Color(0xFF4A1587)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Manual',
                          style: TextStyle(
                            color: mode == CobrarMode.manual
                                ? Colors.white
                                : const Color(0xFF4A1587),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
            CobrarKeypad(onKeyTap: onKeyTap),

            const SizedBox(height: 48),
            // Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isAmountValid ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A1587),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Continuar para Cobrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
