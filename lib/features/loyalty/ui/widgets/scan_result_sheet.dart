import 'package:flutter/material.dart';
import 'package:yapa/core/models/transaction_result.dart';

class ScanResultSheet extends StatefulWidget {
  final TransactionResult result;
  final String merchantName;
  final VoidCallback onDone;

  const ScanResultSheet({
    super.key,
    required this.result,
    required this.merchantName,
    required this.onDone,
  });

  @override
  State<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<ScanResultSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final hasNewYapa = r.couponUnlocked != null;
    final isBlocked = r.antifraudBlocked;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          ScaleTransition(
            scale: _scaleAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildMainIcon(hasNewYapa, isBlocked),
            ),
          ),
          const SizedBox(height: 16),

          FadeTransition(
            opacity: _fadeAnim,
            child: Text(
              _buildTitle(hasNewYapa, isBlocked),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isBlocked ? Colors.orange.shade800 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.merchantName,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 24),

          if (!isBlocked) ...[
            _StatsRow(
              points: r.trustPointsEarned,
              total: r.totalTrustPoints,
              tier: r.tierName,
              couponApplied: r.couponApplied,
            ),
            const SizedBox(height: 16),
          ],

          if (hasNewYapa) ...[
            _YapaCelebrationCard(coupon: r.couponUnlocked!),
            const SizedBox(height: 16),
          ],

          if (isBlocked) ...[
            _AntifraudWarning(),
            const SizedBox(height: 16),
          ],

          if (!isBlocked && r.pointsToNextCoupon != null && r.pointsToNextCoupon! > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Te faltan ${r.pointsToNextCoupon!.toInt()} pts para tu próxima Yapa',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasNewYapa
                    ? const Color(0xFF00BFA5)
                    : const Color(0xFF4A1587),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainIcon(bool hasNewYapa, bool isBlocked) {
    if (isBlocked) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.warning_amber_rounded,
            color: Colors.orange.shade700, size: 44),
      );
    }
    if (hasNewYapa) {
      return Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFE0F7FA),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text('🎁', style: TextStyle(fontSize: 40)),
        ),
      );
    }
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_circle_rounded,
          color: Color(0xFF2E7D32), size: 44),
    );
  }

  String _buildTitle(bool hasNewYapa, bool isBlocked) {
    if (isBlocked) return '¡Ops! Límite de velocidad';
    if (hasNewYapa) return '¡Yapa desbloqueada! 🎉';
    return '¡Pago registrado!';
  }
}

class _StatsRow extends StatelessWidget {
  final double points;
  final double total;
  final String tier;
  final CouponApplied? couponApplied;

  const _StatsRow({
    required this.points,
    required this.total,
    required this.tier,
    required this.couponApplied,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            label: 'Pts ganados',
            value: '+${points.toInt()}',
            color: const Color(0xFF4A1587),
          ),
          _divider(),
          _Stat(
            label: 'Total pts',
            value: total.toInt().toString(),
            color: const Color(0xFF4A1587),
          ),
          _divider(),
          _Stat(
            label: 'Nivel',
            value: tier,
            color: const Color(0xFF4A1587),
          ),
          if (couponApplied != null) ...[
            _divider(),
            _Stat(
              label: 'Descuento',
              value: '-\$${couponApplied!.discountAmount.toStringAsFixed(2)}',
              color: const Color(0xFF00796B),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: const Color(0xFF4A1587).withValues(alpha: 0.15),
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}

class _YapaCelebrationCard extends StatelessWidget {
  final CouponUnlocked coupon;

  const _YapaCelebrationCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFA5).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${coupon.value.toStringAsFixed(2)} de Yapa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lista para usar en tu próxima compra',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AntifraudWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Se detectó actividad inusual. Esta transacción no acumuló puntos de confianza.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
