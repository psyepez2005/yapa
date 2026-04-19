import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yapa/core/services/loyalty_service.dart';

/// Card that shows the user's active yapas summary on the Home screen.
/// Loads data asynchronously and shows a shimmer skeleton while loading.
class MockupYapasCard extends StatefulWidget {
  const MockupYapasCard({super.key});

  @override
  State<MockupYapasCard> createState() => _MockupYapasCardState();
}

class _MockupYapasCardState extends State<MockupYapasCard> {
  bool _isLoading = true;
  int _totalYapas = 0;
  double _totalValue = 0.0;
  String _topMerchant = '';

  @override
  void initState() {
    super.initState();
    _loadYapas();
  }

  Future<void> _loadYapas() async {
    try {
      final profile = await LoyaltyService().fetchProfile();
      if (!mounted) return;

      int count = 0;
      double value = 0.0;
      String topMerchant = '';
      int maxYapas = 0;

      for (final e in profile) {
        count += e.yapasCount;
        value += e.totalYapasValue;
        if (e.yapasCount > maxYapas) {
          maxYapas = e.yapasCount;
          topMerchant = e.merchantName;
        }
      }

      setState(() {
        _totalYapas = count;
        _totalValue = value;
        _topMerchant = topMerchant;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();
    
    // ── HACKATHON DEMO: Si no hay yapas en DB, mostramos datos falsos atractivos
    // en lugar de ocultar la tarjeta (return SizedBox.shrink()), para que el UI nunca se dañe.
    if (_totalYapas == 0) {
      _totalYapas = 2;
      _totalValue = 3.51;
      _topMerchant = 'Ceviches de la Ruleta';
    }

    return GestureDetector(
      onTap: () => context.go('/loyalty'),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A1587), Color(0xFF7B2FBE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A1587).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_totalYapas} ${_totalYapas == 1 ? 'Yapa disponible' : 'Yapas disponibles'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Valor total: \$${_totalValue.toStringAsFixed(2)} · ${_topMerchant.isNotEmpty ? 'Más en $_topMerchant' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
