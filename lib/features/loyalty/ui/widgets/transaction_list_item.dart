import 'package:flutter/material.dart';

class TransactionListItem extends StatelessWidget {
  final String date;
  final double amount;
  final int points;

  const TransactionListItem({
    super.key,
    required this.date,
    required this.amount,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFF757575), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pago en local', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-\$${amount.toStringAsFixed(2)}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFF00BFA5), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+$points pts confianza', 
                    style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}