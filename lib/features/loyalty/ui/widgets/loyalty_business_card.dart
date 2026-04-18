import 'package:flutter/material.dart';

class LoyaltyBusinessCard extends StatelessWidget {
  final String businessName;
  final String category;
  final String location;
  final String tierName; 
  final String cashbackPercentage; 
  final String minPurchaseAmount; // Nuevo parámetro
  final int visits;
  final double progress;
  final String nextLevel;
  final int purchasesNeeded;
  final IconData businessIcon;

  const LoyaltyBusinessCard({
    super.key,
    required this.businessName,
    required this.category,
    required this.location,
    required this.tierName,
    required this.cashbackPercentage,
    required this.minPurchaseAmount, // Agregado al constructor
    required this.visits,
    required this.progress,
    required this.nextLevel,
    required this.purchasesNeeded,
    required this.businessIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 8, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            debugPrint('Clic en el negocio: $businessName');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                      child: Icon(businessIcon, color: const Color(0xFF4A1587), size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(businessName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('$category · $location', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFBE9E7), borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              tierName, 
                              style: const TextStyle(color: Color(0xFFE64A19), fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$cashbackPercentage Cashback', 
                          style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        const SizedBox(height: 2),
                        // Nuevo texto del monto mínimo con el mismo estilo de las visitas
                        Text('min \$$minPurchaseAmount', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('$visits visitas', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tienes un $cashbackPercentage de cashback con cada transacción.',
                  style: const TextStyle(color: Color(0xFF4A1587), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF00BFA5), 
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Te faltan $purchasesNeeded compras para subir a $nextLevel', 
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        children: const [
                          Text('Ver', style: TextStyle(color: Color(0xFF4A1587), fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF4A1587)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}