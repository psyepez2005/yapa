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
            const SizedBox(height: 20),
            const Text(
              'Monto a cobrar',
              style: TextStyle(color: Colors.grey, fontSize: 13, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            Text(
              amount.isEmpty ? '\$0' : '\$$amount',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: amount.isEmpty ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Toggle QR / Manual
            Container(
              height: 46,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
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
                          boxShadow: mode == CobrarMode.qr
                              ? [BoxShadow(color: const Color(0xFF4A1587).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 16, color: mode == CobrarMode.qr ? Colors.white : const Color(0xFF4A1587)),
                            const SizedBox(width: 6),
                            Text(
                              'QR',
                              style: TextStyle(
                                color: mode == CobrarMode.qr ? Colors.white : const Color(0xFF4A1587),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
                          boxShadow: mode == CobrarMode.manual
                              ? [BoxShadow(color: const Color(0xFF4A1587).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.dialpad, size: 16, color: mode == CobrarMode.manual ? Colors.white : const Color(0xFF4A1587)),
                            const SizedBox(width: 6),
                            Text(
                              'Manual',
                              style: TextStyle(
                                color: mode == CobrarMode.manual ? Colors.white : const Color(0xFF4A1587),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Navigation row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined, color: Colors.grey.shade400, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Agregar descripción (opcional)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Keypad
            CobrarKeypad(onKeyTap: onKeyTap),

            const SizedBox(height: 40),
            // Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isAmountValid ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A1587),
                  disabledBackgroundColor: Colors.grey.shade200,
                  elevation: _isAmountValid ? 4 : 0,
                  shadowColor: const Color(0xFF4A1587).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(
                  'Cobrar',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _isAmountValid ? Colors.white : Colors.grey.shade400,
                  ),
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
