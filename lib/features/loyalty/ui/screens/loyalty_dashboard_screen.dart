import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ Necesario para navegar
import '../widgets/loyalty_header.dart';
import '../widgets/loyalty_global_progress.dart';
import '../widgets/loyalty_business_card.dart';
import '../../../deunamockup/ui/widgets/mockup_bottom_nav.dart';

class LoyaltyDashboardScreen extends StatelessWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Datos simulados de Base de Datos
    final businesses = [
      {
        'name': 'Tienda Don Pepe', 'category': 'Abarrotes', 'location': 'Quito',
        'tier': 'Bronce', 'cashback': '1%', 'minPurchase': '5', 'visits': 3, 'progress': 0.4, 
        'nextLevel': 'Plata (2%)', 'needed': 2, 'currentYapas': 3, 'icon': Icons.storefront
      },
      {
        'name': 'Farmacia El Barrio', 'category': 'Salud', 'location': 'Quito',
        'tier': 'Plata', 'cashback': '2%', 'minPurchase': '10', 'visits': 6, 'progress': 0.7, 
        'nextLevel': 'Oro (3%)', 'needed': 5, 'currentYapas': 1, 'icon': Icons.local_pharmacy
      },
      {
        'name': 'Panadería La Rosa', 'category': 'Comida', 'location': 'Quito',
        'tier': 'Oro', 'cashback': '3%', 'minPurchase': '3', 'visits': 12, 'progress': 1.0, 
        'nextLevel': 'Nivel Máximo', 'needed': 0, 'currentYapas': 5, 'icon': Icons.bakery_dining
      },
    ];

    // ✅ SUMAMOS LAS YAPAS Y AHORROS
    final int totalYapasSum = businesses.fold(0, (sum, b) => sum + (b['currentYapas'] as int));
    const double ahorroTotal = 15.40;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoyaltyHeader(),
            
            // 1. Tarjeta puramente informativa
            LoyaltyGlobalProgress(
              totalYapas: totalYapasSum,
              totalSaved: ahorroTotal,
            ),

            // ✅ 2. NUEVO BOTÓN DEDICADO PARA VER LAS YAPAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.pushNamed('my_yapas'),
                  icon: const Icon(Icons.stars_rounded, color: Colors.white),
                  label: const Text(
                    'Ver mis Yapas disponibles', 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A1587), // Morado institucional
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),

            // 3. Título de la sección
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Mis Negocios del Barrio',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),

            // 4. Lista de comercios
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
              currentYapas: b['currentYapas'] as int,
            )).toList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const MockupBottomNav(currentIndex: 1),
    );
  }
}