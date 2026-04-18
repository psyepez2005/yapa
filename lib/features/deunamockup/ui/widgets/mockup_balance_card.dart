import 'package:flutter/material.dart';

class MockupBalanceCard extends StatelessWidget {
  const MockupBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saldo disponible', style: TextStyle(color: Color(0xFF757575), fontSize: 14.0)),
                    const SizedBox(height: 8.0),
                    Row(
                      children: const [
                        Text('\$0,00', style: TextStyle(color: Colors.black, fontSize: 32.0, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12.0),
                        Icon(Icons.visibility, color: Colors.black54, size: 20),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Colors.black, size: 32),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Recargar desde', style: TextStyle(color: Color(0xFF757575), fontSize: 12.0)),
                    SizedBox(height: 4.0),
                    Text('Principal ******2634', style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('+ \$20', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.bold, fontSize: 14.0)),
                    ),
                    const SizedBox(width: 12.0),
                    const Icon(Icons.keyboard_double_arrow_right, color: Colors.black54, size: 16),
                    const SizedBox(width: 4.0),
                    const Text('d!', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 20.0)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}