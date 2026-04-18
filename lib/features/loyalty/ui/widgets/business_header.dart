import 'package:flutter/material.dart';

class BusinessHeader extends StatelessWidget {
  final String businessName;
  final IconData businessIcon;
  final String tierName;
  final String cashbackPercentage;

  const BusinessHeader({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.tierName,
    required this.cashbackPercentage,
  });

  @override
  Widget build(BuildContext context) {
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
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ]
            ),
            child: Icon(businessIcon, color: const Color(0xFF4A1587), size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            businessName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFBE9E7), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  tierName, 
                  style: const TextStyle(color: Color(0xFFE64A19), fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '$cashbackPercentage Cashback', 
                  style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Acumula Puntos de Confianza con cada compra para mejorar tu nivel y ganar más beneficios.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}