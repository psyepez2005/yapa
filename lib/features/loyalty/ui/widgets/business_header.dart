import 'package:flutter/material.dart';

class BusinessHeader extends StatelessWidget {
  final String businessName;
  final IconData businessIcon;
  final String tierName;
  final String? cashbackPercentage;

  const BusinessHeader({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.tierName,
    this.cashbackPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // Determinamos en qué paso está según la categoría (0 = Bronce, 1 = Plata, 2 = Oro)
    int currentStep = 0;
    final tier = tierName.toLowerCase();
    if (tier.contains('plata')) currentStep = 1;
    if (tier.contains('oro')) currentStep = 2;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
              ]
            ),
            child: Icon(businessIcon, color: const Color(0xFF4A1587), size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            businessName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          if (cashbackPercentage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$cashbackPercentage cashback',
                style: const TextStyle(
                  color: Color(0xFF00897B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // ✅ EL NUEVO MENSAJE EDUCATIVO
          const Text(
            'Acumula puntos con cada consumo para reclamar Yapas y así ahorrar dinero en siguientes compras.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
          ),
          
          const SizedBox(height: 24),
          
          // ✅ EL NUEVO PROGRESS BAR DE CATEGORÍAS (Timeline)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTierBadge('Bronce', currentStep >= 0),
              _buildLine(currentStep >= 1),
              _buildTierBadge('Plata', currentStep >= 1),
              _buildLine(currentStep >= 2),
              _buildTierBadge('Oro', currentStep >= 2),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widgets internos para dibujar el timeline ---
  Widget _buildTierBadge(String name, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF00BFA5) : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isActive ? Icons.check : Icons.lock_outline,
            color: isActive ? Colors.white : Colors.grey.shade400,
            size: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            color: isActive ? const Color(0xFF00BFA5) : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: 40,
      height: 3,
      margin: const EdgeInsets.only(bottom: 20), // Para alinearlo con los círculos y no con el texto
      color: isActive ? const Color(0xFF00BFA5) : Colors.grey.shade200,
    );
  }
}