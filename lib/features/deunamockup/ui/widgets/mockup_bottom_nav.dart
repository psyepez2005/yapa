import 'package:flutter/material.dart';

class MockupBottomNav extends StatelessWidget {
  final int currentIndex;

  const MockupBottomNav({
    super.key, 
    this.currentIndex = 1, // Por defecto en 1 (Beneficios) como en tu foto
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
        type: BottomNavigationBarType.fixed, // Evita que los íconos salten
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A1587), // Morado DeUna
        unselectedItemColor: const Color(0xFF757575), // Gris
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        elevation: 0,
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
            icon: Icon(Icons.account_balance_wallet_outlined), 
            activeIcon: Icon(Icons.account_balance_wallet), 
            label: 'Billetera',
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