import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ Necesario para navegar
import 'package:yapa/features/deunamockup/ui/widgets/mockup_bottom_nav.dart';

import '../widgets/business_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/trust_points_progress.dart';

class BusinessDetailScreen extends StatelessWidget {
  final String businessName;
  final IconData businessIcon;
  final String tierName;
  final List<Map<String, dynamic>> transactions;
  final int currentTrustPoints;
  final int targetTrustPoints;
  final int availableYapas; // ✅ NUEVA VARIABLE: Yapas disponibles

  const BusinessDetailScreen({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.tierName,
    required this.transactions,
    required this.currentTrustPoints, 
    required this.targetTrustPoints,
    required this.availableYapas, // ✅ Requerido en constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A1587), size: 20),
          onPressed: () => Navigator.of(context).pop(), 
        ),
        title: const Text(
          'Detalle del Negocio',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          BusinessHeader(
            businessName: businessName,
            businessIcon: businessIcon,
            tierName: tierName,
          ),
          
          // ✅ NUEVO BANNER DE YAPAS DISPONIBLES
          if (availableYapas > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: InkWell(
                onTap: () {
                  context.pushNamed('business_yapas', extra: {
                    'name': businessName,
                    'yapas': availableYapas,
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A1587), // Fondo Morado
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Tienes $availableYapas Yapas disponibles',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 8),

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Historial de Gastos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return TransactionListItem(
                          date: tx['date'] as String,
                          amount: tx['amount'] as double,
                          points: tx['points'] as int,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          TrustPointsProgress(
            currentPoints: currentTrustPoints,
            targetPoints: targetTrustPoints,
          ),
          const MockupBottomNav(currentIndex: 0),
        ],
      ),
    );
  }
}