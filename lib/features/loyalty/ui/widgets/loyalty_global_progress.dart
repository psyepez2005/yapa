import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoyaltyGlobalProgress extends StatelessWidget {
  final int totalYapas;

  const LoyaltyGlobalProgress({
    super.key,
    required this.totalYapas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 5)
          )
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
                'Total de yapas acumuladas',
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)
              ),
              ElevatedButton(
                onPressed: () => context.pushNamed('my_yapas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text(
                  'Mis yapas',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalYapas',
            style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text(
            '¡Sigue comprando en tu barrio para ganar más!',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}