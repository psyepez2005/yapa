import 'package:flutter/material.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/features/deunamockup/ui/widgets/mockup_bottom_nav.dart';

import '../widgets/business_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/trust_points_progress.dart';

class BusinessDetailScreen extends StatelessWidget {
  final String businessName;
  final IconData businessIcon;
  final String tierName;
  final String cashbackPercentage;
  final List<Map<String, dynamic>> transactions;
  final int currentTrustPoints;
  final int targetTrustPoints;
  final List<ActiveYapa> activeYapas;

  const BusinessDetailScreen({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.tierName,
    required this.cashbackPercentage,
    required this.transactions,
    required this.currentTrustPoints,
    required this.targetTrustPoints,
    this.activeYapas = const [],
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
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BusinessHeader(
                    businessName: businessName,
                    businessIcon: businessIcon,
                    tierName: tierName,
                    cashbackPercentage: cashbackPercentage,
                  ),
                  if (activeYapas.isNotEmpty) _buildActiveYapasSection(),
                  _buildTransactionsSection(),
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

  Widget _buildActiveYapasSection() {
    final total = activeYapas.fold(0.0, (s, y) => s + y.value);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A1587).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('🎁', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Yapas disponibles',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A1587),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Text(
                '\$${total.toStringAsFixed(2)} total',
                style: const TextStyle(
                  color: Color(0xFF4A1587),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activeYapas.map(
            (yapa) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Color(0xFF4A1587),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Yapa de \$${yapa.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    yapa.daysUntilExpiry <= 0
                        ? 'Vence hoy'
                        : 'Vence en ${yapa.daysUntilExpiry}d',
                    style: TextStyle(
                      fontSize: 11,
                      color: yapa.isExpiringSoon
                          ? const Color(0xFFE65100)
                          : Colors.grey.shade500,
                      fontWeight: yapa.isExpiringSoon
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Container(
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
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'Historial de Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: transactions.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.grey.shade200, height: 1),
            itemBuilder: (_, i) {
              final tx = transactions[i];
              return TransactionListItem(
                date: tx['date'] as String,
                amount: (tx['amount'] as num).toDouble(),
                points: tx['points'] as int,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
