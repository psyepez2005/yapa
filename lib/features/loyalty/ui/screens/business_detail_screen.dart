import 'package:flutter/material.dart';
import 'package:yapa/features/deunamockup/ui/widgets/mockup_bottom_nav.dart';

// Importa tus widgets locales
import '../widgets/business_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/trust_points_progress.dart'; // <-- No olvides importar este también

class BusinessDetailScreen extends StatelessWidget {
  final String businessName;
  final IconData businessIcon;
  final String tierName;
  final String cashbackPercentage;
  final List<Map<String, dynamic>> transactions;
  
  // VARIABLES FALTANTES AGREGADAS AQUÍ:
  final int currentTrustPoints;
  final int targetTrustPoints;

  const BusinessDetailScreen({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.tierName,
    required this.cashbackPercentage,
    required this.transactions,
    required this.currentTrustPoints, // <-- Agregado al constructor
    required this.targetTrustPoints,  // <-- Agregado al constructor
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
            cashbackPercentage: cashbackPercentage,
          ),
          const SizedBox(height: 16),
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
          // AÑADIMOS EL WIDGET DE PROGRESO AQUÍ ABAJO
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