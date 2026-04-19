import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yapa/core/storage/token_storage.dart';
import '../screens/mapa_yapas_screen.dart';

class MockupBottomNav extends StatelessWidget {
  final int currentIndex;

  const MockupBottomNav({
    super.key,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A1587),
        unselectedItemColor: const Color(0xFF757575),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        elevation: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              if (currentIndex != 0) context.go('/mockup');
              break;
            case 1:
              if (currentIndex != 1) context.go('/loyalty');
              break;
            case 2:
              // Radar Screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapaYapasScreen()),
              );
              break;
            case 3:
              // Logout
              TokenStorage.clearAll().then((_) {
                context.go('/');
              });
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            activeIcon: Icon(Icons.card_giftcard),
            label: 'Beneficios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar_outlined),
            activeIcon: Icon(Icons.radar),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tú',
          ),
        ],
      ),
    );
  }
}