import 'package:flutter/material.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/core/services/loyalty_service.dart';

class MyYapasScreen extends StatefulWidget {
  final List<LoyaltyProfileEntry> entries;

  const MyYapasScreen({super.key, this.entries = const []});

  @override
  State<MyYapasScreen> createState() => _MyYapasScreenState();
}

class _MyYapasScreenState extends State<MyYapasScreen> {
  late List<LoyaltyProfileEntry> _entries;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _entries = widget.entries;
    if (_entries.isEmpty) _loadFromBackend();
  }

  Future<void> _loadFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final data = await LoyaltyService().fetchProfile();
      if (mounted) setState(() => _entries = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<LoyaltyProfileEntry> get _withYapas =>
      _entries.where((e) => e.activeYapas.isNotEmpty).toList();

  double get _totalValue =>
      _entries.fold(0.0, (sum, e) => sum + e.totalYapasValue);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mis Yapas',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A1587)))
          : _withYapas.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    _buildTotalBanner(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _withYapas.length,
                        itemBuilder: (_, i) => _MerchantYapaGroup(
                          entry: _withYapas[i],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTotalBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A1587), Color(0xFF7B2FBE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A1587).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${_totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Total disponible para canjear',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF4A1587).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 48,
                color: Color(0xFF4A1587),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no tienes yapas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sigue comprando en tus negocios del barrio para ganar yapas de cashback.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MerchantYapaGroup extends StatelessWidget {
  final LoyaltyProfileEntry entry;

  const _MerchantYapaGroup({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: Color(0xFF4A1587),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.merchantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${entry.activeYapas.length} ${entry.activeYapas.length == 1 ? 'yapa disponible' : 'yapas disponibles'}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.tierBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.tierName,
                    style: TextStyle(
                      color: entry.tierColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1),
          ...entry.activeYapas.map((yapa) => _YapaItem(yapa: yapa)),
        ],
      ),
    );
  }
}

class _YapaItem extends StatelessWidget {
  final ActiveYapa yapa;

  const _YapaItem({required this.yapa});

  @override
  Widget build(BuildContext context) {
    final days = yapa.daysUntilExpiry;
    final isExpiringSoon = yapa.isExpiringSoon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpiringSoon
                  ? const Color(0xFFFFF3E0)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: isExpiringSoon
                  ? const Color(0xFFE65100)
                  : const Color(0xFF2E7D32),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yapa de \$${yapa.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: isExpiringSoon
                          ? const Color(0xFFE65100)
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      days <= 0
                          ? 'Vence hoy'
                          : days == 1
                              ? 'Vence mañana'
                              : 'Vence en $days días',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpiringSoon
                            ? const Color(0xFFE65100)
                            : Colors.grey.shade500,
                        fontWeight: isExpiringSoon
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Usar',
              style: TextStyle(
                color: Color(0xFF00796B),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
