import 'package:flutter/material.dart';

class LoyaltyGlobalProgress extends StatelessWidget {
  final String currentTier;

  const LoyaltyGlobalProgress({super.key, this.currentTier = 'Bronce'});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAEDFF), // Fondo suave morado
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3E5F5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yapa Total Header
          Row(
            children: const [
              Text('💰', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Yapa total', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          // Amount and Usar button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '\$5.20',
                style: TextStyle(color: Color(0xFF4A1587), fontSize: 48, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A1587), // Morado DeUna
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: Row(
                  children: const [
                    Text('Usar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Paused alert box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCCBC), width: 1), // Naranja moderado
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFE64A19), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Tienes \$1.50 en pausa.', style: TextStyle(color: Color(0xFFE64A19), fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('¡Compra antes del viernes para liberarlos!', style: TextStyle(color: Color(0xFFE64A19), fontSize: 13)),
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