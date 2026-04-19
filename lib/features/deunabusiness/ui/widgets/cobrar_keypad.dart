import 'package:flutter/material.dart';

class CobrarKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;

  const CobrarKeypad({super.key, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => onKeyTap(key),
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
