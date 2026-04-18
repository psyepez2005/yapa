import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/mockup_app_bar.dart';
import '../widgets/mockup_balance_card.dart';
import '../widgets/mockup_service_grid.dart';
import '../widgets/mockup_promo_carousel.dart';
import '../widgets/mockup_bottom_nav.dart';

class MockupHomeScreen extends StatelessWidget {
  const MockupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: const MockupAppBar(), // Widget extraído
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            MockupBalanceCard(),
            SizedBox(height: 24.0),
            MockupServiceGrid(),
            SizedBox(height: 32.0),
            MockupPromoCarousel(), // <-- Aquí agregamos el carrusel
          ],
        ),
      ),
      // Botón flotante QR
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        width: double.infinity,
        height: 56,
        child: FloatingActionButton.extended(
          // ✅ ACÁ CONECTAMOS LA NAVEGACIÓN
          onPressed: () => context.pushNamed('qr_scanner'), 
          backgroundColor: const Color(0xFF4A1587),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          label: const Text('Escanear QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        ),
      ),
      bottomNavigationBar: const MockupBottomNav(currentIndex: 0),
      // bottomNavigationBar: const MockupBottomNav(), // Widget extraído
    );
  }
}