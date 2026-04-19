import 'package:flutter/material.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/core/services/loyalty_service.dart';
import 'package:intl/intl.dart';
import 'package:yapa/features/deunamockup/ui/widgets/mockup_bottom_nav.dart';

import '../widgets/business_header.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/trust_points_progress.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessName;
  final IconData businessIcon;
  final String merchantId;
  final String tierName;
  final String cashbackPercentage;
  final int currentTrustPoints;
  final int targetTrustPoints;
  final List<ActiveYapa> activeYapas;

  const BusinessDetailScreen({
    super.key,
    required this.businessName,
    required this.businessIcon,
    required this.merchantId,
    required this.tierName,
    required this.cashbackPercentage,
    required this.currentTrustPoints,
    required this.targetTrustPoints,
    this.activeYapas = const [],
  });

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final _service = LoyaltyService();
  bool _isLoadingTxs = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final txs = await _service.fetchTransactionHistory(widget.merchantId);
      if (mounted) {
        setState(() {
          _transactions = txs;
          _isLoadingTxs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTxs = false);
      }
    }
  }

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
                    businessName: widget.businessName,
                    businessIcon: widget.businessIcon,
                    tierName: widget.tierName,
                    cashbackPercentage: widget.cashbackPercentage,
                  ),
                  if (widget.activeYapas.isNotEmpty) _buildActiveYapasSection(),
                  _buildTransactionsSection(),
                ],
              ),
            ),
          ),
          TrustPointsProgress(
            currentPoints: widget.currentTrustPoints,
            targetPoints: widget.targetTrustPoints,
          ),
          const MockupBottomNav(currentIndex: 0),
        ],
      ),
    );
  }

  Widget _buildActiveYapasSection() {
    final total = widget.activeYapas.fold(0.0, (s, y) => s + y.value);
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
          ...widget.activeYapas.map(
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
          if (_isLoadingTxs)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4A1587)),
              ),
            )
          else if (_transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('Aún no tienes historial de gastos.',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _transactions.length,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade200, height: 1),
              itemBuilder: (_, i) {
                final tx = _transactions[i];
                // Formatear fecha
                final dt = DateTime.parse(tx['date'] as String);
                final formattedDate =
                    DateFormat("dd MMM yyyy, HH:mm", "es_ES").format(dt);

                return TransactionListItem(
                  date: formattedDate,
                  amount: (tx['amount'] as num).toDouble(),
                  points: (tx['pointsEarned'] as num).toInt(),
                );
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
