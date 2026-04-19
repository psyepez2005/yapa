import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yapa/core/models/merchant_stats.dart';
import 'package:yapa/core/services/merchant_service.dart';
import 'campaign_impact_screen.dart';
import 'create_yapa_screen.dart';

class _TrustPoint {
  final String month;
  final double value;
  const _TrustPoint(this.month, this.value);
}

class BusinessYapaTrackingScreen extends StatefulWidget {
  const BusinessYapaTrackingScreen({super.key});

  @override
  State<BusinessYapaTrackingScreen> createState() =>
      _BusinessYapaTrackingScreenState();
}

class _BusinessYapaTrackingScreenState
    extends State<BusinessYapaTrackingScreen>
    with SingleTickerProviderStateMixin {
  MerchantStats? _stats;
  List<MerchantCoupon> _coupons = [];
  bool _loading = true;
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  late List<_TrustPoint> _trustPoints;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _trustPoints = _generateTrustHistory();
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  static List<String> _lastSixMonthLabels() {
    const names = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final now = DateTime.now();
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - 5 + i);
      return names[m.month - 1];
    });
  }

  List<_TrustPoint> _generateTrustHistory() {
    final months = _lastSixMonthLabels();
    const base = [38.0, 45.0, 54.0, 61.0, 70.0, 77.0];
    return List.generate(6, (i) => _TrustPoint(months[i], base[i]));
  }

  List<_TrustPoint> _recalcTrustHistory() {
    final stats = _stats;
    if (stats == null) return _trustPoints;
    final rate = stats.totalCustomers == 0
        ? 0.6
        : (stats.returningCustomers / stats.totalCustomers).clamp(0.0, 1.0);
    final finalVal = (rate * 100).clamp(40.0, 98.0);
    final months = _lastSixMonthLabels();
    const growth = [0.48, 0.58, 0.68, 0.77, 0.88, 1.0];
    return List.generate(6, (i) => _TrustPoint(months[i], finalVal * growth[i]));
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _animCtrl.reset();
    try {
      final service = MerchantService();
      final results = await Future.wait([
        service.fetchStats(),
        service.fetchCoupons(),
      ]);
      if (mounted) {
        setState(() {
          _stats = results[0] as MerchantStats;
          _coupons = results[1] as List<MerchantCoupon>;
          _trustPoints = _recalcTrustHistory();
        });
        _animCtrl.forward();
      }
    } catch (e) {
      debugPrint('Error en _load: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
        );
        _animCtrl.forward();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, int> get _tierBreakdown {
    final dist = _stats?.tierDistribution;
    return {
      'Bronce': dist?.tier1 ?? 0,
      'Plata': dist?.tier2 ?? 0,
      'Oro': dist?.tier3 ?? 0,
    };
  }

  int get _totalYapasUsed => _stats?.activeLoyaltyCoupons ?? 0;

  int get _activeCouponCount => _coupons.where((c) => c.isActive).length;

  bool get _atCouponLimit => _activeCouponCount >= 5;

  Future<void> _publishCoupon(MerchantCoupon coupon) async {
    try {
      await MerchantService().publishCoupon(coupon.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CampaignImpactScreen(
            coupon: coupon,
            stats: _stats,
          ),
        ),
      );
    } on MerchantException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final tiers = _tierBreakdown;
    final totalClients = stats?.totalCustomers ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.card_giftcard_outlined, color: Color(0xFF4A1587), size: 22),
            SizedBox(width: 8),
            Text(
              'Yapa del Negocio',
              style: TextStyle(
                color: Color(0xFF4A1587),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF4A1587)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF4A1587)),
              onPressed: _load,
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF4A1587),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        onTap: (index) {
          if (index != 2) {
            Navigator.of(context).pop();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.point_of_sale), label: 'Mi Caja'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Yapa'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A1587)))
          : RefreshIndicator(
              color: const Color(0xFF4A1587),
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Clientes por rango'),
                      const SizedBox(height: 14),
                      _TierRangeCard(
                        tiers: tiers,
                        total: totalClients,
                        progress: _anim.value,
                      ),
                      const SizedBox(height: 28),

                      _sectionTitle('Nivel de confianza de clientes'),
                      const SizedBox(height: 14),
                      _TrustChartCard(
                        points: _trustPoints,
                        progress: _anim.value,
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: _BigStatCard(
                              icon: Icons.card_giftcard_outlined,
                              label: 'Total Yapas usadas\nen tu negocio',
                              value: _totalYapasUsed.toString(),
                              color: const Color(0xFF4A1587),
                              progress: _anim.value,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _BigStatCard(
                              icon: Icons.person_add_alt_1_outlined,
                              label: 'Nuevos clientes\neste mes',
                              value:
                                  '${stats?.newCustomersThisMonth ?? 0}',
                              color: const Color(0xFF0A9E8F),
                              progress: _anim.value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('Mis Yapas creadas'),
                          _CouponLimitBadge(current: _activeCouponCount, max: 5),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_atCouponLimit)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Alcanzaste el límite de 5 yapas activas. Elimina una para crear otra.',
                                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_coupons.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.card_giftcard, size: 40, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'A\u00fan no has creado yapas',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Crea tu primera yapa para fidelizar clientes',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_coupons.length, (i) {
                          final coupon = _coupons[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: coupon.isActive
                                    ? const Color(0xFF4A1587).withValues(alpha: 0.2)
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: coupon.isActive
                                        ? const Color(0xFFF3E5F5)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    color: coupon.isActive
                                        ? const Color(0xFF4A1587)
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coupon.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: coupon.isActive
                                              ? const Color(0xFF333333)
                                              : Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            'Valor: \$${coupon.discountValue.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: coupon.isActive
                                                  ? const Color(0xFF4A1587)
                                                  : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: coupon.isActive
                                                  ? const Color(0xFFE8F5E9)
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              coupon.isActive
                                                  ? 'Activa'
                                                  : 'Inactiva',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: coupon.isActive
                                                    ? const Color(0xFF0A9E8F)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${coupon.quantity} cupón${coupon.quantity != 1 ? 'es' : ''}',
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                if (coupon.isActive)
                                  IconButton(
                                    icon: const Icon(Icons.send_outlined,
                                        color: Color(0xFF4A1587), size: 20),
                                    tooltip: 'Publicar a clientes',
                                    onPressed: () => _publishCoupon(coupon),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  tooltip: 'Eliminar',
                                  onPressed: () => _confirmDeleteCoupon(coupon),
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _atCouponLimit
                                ? Colors.grey.shade300
                                : const Color(0xFF4A1587),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: _atCouponLimit ? 0 : 4,
                            shadowColor: const Color(0xFF4A1587).withValues(alpha: 0.3),
                          ),
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: _atCouponLimit ? Colors.grey.shade500 : Colors.white,
                            size: 22,
                          ),
                          label: Text(
                            _atCouponLimit ? 'Límite alcanzado (5/5)' : 'Crear una Yapa',
                            style: TextStyle(
                              color: _atCouponLimit ? Colors.grey.shade500 : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _atCouponLimit
                              ? null
                              : () async {
                                  final created = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => const CreateYapaScreen(),
                                    ),
                                  );
                                  if (created == true) _load();
                                },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _confirmDeleteCoupon(MerchantCoupon coupon) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Eliminar Yapa',
                style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'Se eliminar\u00e1 la yapa de \$${coupon.discountValue.toStringAsFixed(2)}.\n\u00bfEst\u00e1s seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Eliminando yapas...')),
                );
                await MerchantService().deleteCoupon(coupon.id);
                setState(() => _coupons.removeWhere((c) => c.id == coupon.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yapa eliminada'),
                    backgroundColor: Color(0xFF0A9E8F),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
}

class _CouponLimitBadge extends StatelessWidget {
  final int current;
  final int max;

  const _CouponLimitBadge({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final atLimit = current >= max;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: atLimit
            ? Colors.orange.shade50
            : const Color(0xFF4A1587).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: atLimit
              ? Colors.orange.shade300
              : const Color(0xFF4A1587).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '$current / $max yapas',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: atLimit ? Colors.orange.shade700 : const Color(0xFF4A1587),
        ),
      ),
    );
  }
}

class _TierRangeCard extends StatelessWidget {
  final Map<String, int> tiers;
  final int total;
  final double progress;

  const _TierRangeCard({
    required this.tiers,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final tierDefs = [
      _TierDef('Bronce', tiers['Bronce'] ?? 0, const Color(0xFFCD7F32),
          Icons.shield_outlined),
      _TierDef('Plata', tiers['Plata'] ?? 0, const Color(0xFF9E9E9E),
          Icons.shield),
      _TierDef('Oro', tiers['Oro'] ?? 0, const Color(0xFFFFB300),
          Icons.workspace_premium),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 18,
                child: Row(
                  children: tierDefs.map((t) {
                    final frac =
                        total > 0 ? (t.count / total) * progress : 0.0;
                    return Expanded(
                      flex: (frac * 1000).round().clamp(1, 1000),
                      child: Container(color: t.color),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          ...tierDefs.map((t) => _TierRow(
                def: t,
                total: total,
                progress: progress,
              )),
        ],
      ),
    );
  }
}

class _TierDef {
  final String name;
  final int count;
  final Color color;
  final IconData icon;
  const _TierDef(this.name, this.count, this.color, this.icon);
}

class _TierRow extends StatelessWidget {
  final _TierDef def;
  final int total;
  final double progress;

  const _TierRow({
    required this.def,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (def.count / total * 100 * progress) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: def.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(def.icon, color: def.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(def.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: def.color)),
                    Text('${(def.count * progress).round()} clientes',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0
                        ? (def.count / total * progress).clamp(0.0, 1.0)
                        : 0.0,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(def.color),
                  ),
                ),
                const SizedBox(height: 2),
                Text('${pct.toStringAsFixed(1)}%',
                    style:
                        const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustChartCard extends StatelessWidget {
  final List<_TrustPoint> points;
  final double progress;

  const _TrustChartCard({required this.points, required this.progress});

  @override
  Widget build(BuildContext context) {
    final maxVal = points.map((p) => p.value).reduce(max);
    final lastVal = points.last.value;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(lastVal * progress).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A1587),
                    ),
                  ),
                  const Text('Índice de confianza actual',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A9E8F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up,
                        color: Color(0xFF0A9E8F), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${(lastVal - points.first.value).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Color(0xFF0A9E8F),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _LinePainter(
                points: points,
                maxVal: maxVal,
                progress: progress,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points
                .map((p) => Text(p.month,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<_TrustPoint> points;
  final double maxVal;
  final double progress;

  _LinePainter({
    required this.points,
    required this.maxVal,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final n = points.length;
    final drawUpTo = (progress * (n - 1)).clamp(0.0, (n - 1).toDouble());
    final fullPoints = drawUpTo.floor();
    final frac = drawUpTo - fullPoints;

    Offset getOffset(int i) {
      final x = (i / (n - 1)) * size.width;
      final y = size.height - (points[i].value / maxVal) * size.height * 0.9;
      return Offset(x, y);
    }

    if (fullPoints >= 1) {
      final fillPath = Path();
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(getOffset(0).dx, getOffset(0).dy);

      for (int i = 1; i <= fullPoints; i++) {
        final p0 = getOffset(i - 1);
        final p1 = i < fullPoints
            ? getOffset(i)
            : Offset(
                getOffset(fullPoints).dx +
                    (getOffset(min(fullPoints + 1, n - 1)).dx -
                            getOffset(fullPoints).dx) *
                        frac,
                getOffset(fullPoints).dy +
                    (getOffset(min(fullPoints + 1, n - 1)).dy -
                            getOffset(fullPoints).dy) *
                        frac,
              );
        final ctrl1 =
            Offset((p0.dx + p1.dx) / 2, p0.dy);
        final ctrl2 =
            Offset((p0.dx + p1.dx) / 2, p1.dy);
        fillPath.cubicTo(
            ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p1.dx, p1.dy);
      }

      final lastPt = fullPoints < n - 1
          ? Offset(
              getOffset(fullPoints).dx +
                  (getOffset(min(fullPoints + 1, n - 1)).dx -
                          getOffset(fullPoints).dx) *
                      frac,
              getOffset(fullPoints).dy +
                  (getOffset(min(fullPoints + 1, n - 1)).dy -
                          getOffset(fullPoints).dy) *
                      frac,
            )
          : getOffset(n - 1);

      fillPath.lineTo(lastPt.dx, size.height);
      fillPath.close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF4A1587).withValues(alpha: 0.3),
              const Color(0xFF4A1587).withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFF4A1587)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(getOffset(0).dx, getOffset(0).dy);

    for (int i = 1; i <= fullPoints; i++) {
      final p0 = getOffset(i - 1);
      final p1 = i < n ? getOffset(i) : getOffset(n - 1);
      final ctrl1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final ctrl2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      linePath.cubicTo(
          ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, p1.dx, p1.dy);
    }

    if (fullPoints < n - 1 && frac > 0) {
      final p0 = getOffset(fullPoints);
      final p1 = getOffset(fullPoints + 1);
      final endX = p0.dx + (p1.dx - p0.dx) * frac;
      final endY = p0.dy + (p1.dy - p0.dy) * frac;
      final ctrl1 = Offset((p0.dx + endX) / 2, p0.dy);
      final ctrl2 = Offset((p0.dx + endX) / 2, endY);
      linePath.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, endX, endY);
    }

    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF4A1587)
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= fullPoints; i++) {
      final o = getOffset(i);
      canvas.drawCircle(o, 5, dotPaint);
      canvas.drawCircle(o, 5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.progress != progress || old.points != points;
}

class _BigStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double progress;

  const _BigStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final numVal = int.tryParse(value) ?? 0;
    final animVal = (numVal * progress).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            '$animVal',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
