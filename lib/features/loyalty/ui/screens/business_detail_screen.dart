import 'package:flutter/material.dart';
import 'package:yapa/features/deunamockup/ui/widgets/mockup_bottom_nav.dart';

class BusinessDetailScreen extends StatelessWidget {
  final String businessName;
  final IconData businessIcon;
  final String tierName;
  final String cashbackPercentage;

  const BusinessDetailScreen({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.tierName,
    required this.cashbackPercentage,
  });

  @override
  Widget build(BuildContext context) {
    // Generamos un historial de transacciones de prueba
    final transactions = [
      {'date': '18 Abr 2026, 10:30', 'amount': 15.50, 'points': 15},
      {'date': '15 Abr 2026, 14:15', 'amount': 8.00, 'points': 8},
      {'date': '10 Abr 2026, 09:00', 'amount': 22.40, 'points': 22},
      {'date': '05 Abr 2026, 18:45', 'amount': 5.25, 'points': 5},
      {'date': '01 Abr 2026, 12:20', 'amount': 12.00, 'points': 12},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4A1587), size: 20),
          onPressed: () => Navigator.of(context).pop(), // Vuelve a la pantalla anterior
        ),
        title: const Text(
          'Detalle del Negocio',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildBusinessHeader(),
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
                        return _buildTransactionItem(
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
          MockupBottomNav(currentIndex: 1),
        ],
      ),
    );
  }

  // --- Widgets internos para mantener el código limpio ---

  Widget _buildBusinessHeader() {
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

  Widget _buildTransactionItem({required String date, required double amount, required int points}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_long, color: Color(0xFF757575), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pago en local', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-\$${amount.toStringAsFixed(2)}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFF00BFA5), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+$points pts confianza', 
                    style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}