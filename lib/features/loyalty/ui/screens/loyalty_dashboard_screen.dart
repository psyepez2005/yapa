import 'package:flutter/material.dart';
import '../widgets/loyalty_header.dart';
import '../widgets/loyalty_global_progress.dart';
import '../widgets/loyalty_business_card.dart';
import '../../../deunamockup/ui/widgets/mockup_bottom_nav.dart';

class LoyaltyDashboardScreen extends StatelessWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // 🔹 Esto simula que viene de lógica/navegación/estado
    final String currentTier = 'Plata';

    final businesses = [
      {
        'name': 'Tienda Don Pepe', 'category': 'Abarrotes', 'location': 'Quito',
        'tier': 'Bronce', 'cashback': '1%', 'minPurchase': '5', 'visits': 3, 'progress': 0.4, 
        'nextLevel': 'Plata (2%)', 'needed': 2, 'icon': Icons.storefront
      },
      {
        'name': 'Farmacia El Barrio', 'category': 'Salud', 'location': 'Quito',
        'tier': 'Plata', 'cashback': '2%', 'minPurchase': '10', 'visits': 6, 'progress': 0.7, 
        'nextLevel': 'Oro (3%)', 'needed': 5, 'icon': Icons.local_pharmacy
      },
      {
        'name': 'Panadería La Rosa', 'category': 'Comida', 'location': 'Quito',
        'tier': 'Oro', 'cashback': '3%', 'minPurchase': '3', 'visits': 12, 'progress': 1.0, 
        'nextLevel': 'Nivel Máximo', 'needed': 0, 'icon': Icons.bakery_dining
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoyaltyHeader(),

            // 🔹 UI correcta + control dinámico
            LoyaltyGlobalProgress(currentTier: currentTier),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Mis Negocios del Barrio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            ...businesses.map((b) => LoyaltyBusinessCard(
              businessName: b['name'] as String,
              category: b['category'] as String,
              location: b['location'] as String,
              tierName: b['tier'] as String,
              cashbackPercentage: b['cashback'] as String,
              minPurchaseAmount: b['minPurchase'] as String,
              visits: b['visits'] as int,
              progress: b['progress'] as double,
              nextLevel: b['nextLevel'] as String,
              purchasesNeeded: b['needed'] as int,
              businessIcon: b['icon'] as IconData,
            )).toList(),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // 🔹 navegación (igual en ambos, pero lista para expandirse)
      bottomNavigationBar: const MockupBottomNav(currentIndex: 1),
    );
  }
}