import 'package:flutter/material.dart';

class LoyaltyGlobalProgress extends StatelessWidget {
  const LoyaltyGlobalProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Yapa acumulada', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5), // Turquesa
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  children: const [
                    Text('Usar en mi\npróxima compra', style: TextStyle(fontSize: 12, height: 1.2)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const Text(
            '\$5.20',
            style: TextStyle(color: Color(0xFF00BFA5), fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('En 3 negocios del barrio', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          _buildProgressBar('Haz 2 compras más para desbloquear el 3% de', 'Progreso 3/5', 0.6),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String text, String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF00BFA5), // Turquesa
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}