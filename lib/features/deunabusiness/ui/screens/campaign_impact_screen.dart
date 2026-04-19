import 'package:flutter/material.dart';
import 'package:yapa/core/models/merchant_stats.dart';
import 'package:yapa/core/services/merchant_service.dart';

/// Pantalla de "Vista de Impacto de Campaña" — se muestra tras publicar una Yapa.
class CampaignImpactScreen extends StatefulWidget {
  final MerchantCoupon coupon;
  final MerchantStats? stats;

  const CampaignImpactScreen({
    super.key,
    required this.coupon,
    this.stats,
  });

  @override
  State<CampaignImpactScreen> createState() => _CampaignImpactScreenState();
}

class _CampaignImpactScreenState extends State<CampaignImpactScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  MerchantStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Si ya vienen stats, las usamos. Si no, las cargamos.
    if (widget.stats != null) {
      _stats = widget.stats;
      _loading = false;
      _ctrl.forward();
    } else {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    try {
      final s = await MerchantService().fetchStats();
      if (mounted) setState(() { _stats = s; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    } finally {
      if (mounted) _ctrl.forward();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  // ── Métricas calculadas ───────────────────────────────────────────────────

  bool get _isNewMerchant => (_stats?.totalCustomers ?? 0) == 0;

  // Clientes alcanzados: real si hay histórico, estimado si es nuevo
  int get _clientesAlcanzados {
    if (!_isNewMerchant) return _stats!.totalCustomers;
    // Estimado: los primeros clientes que visiten el negocio verán la Yapa.
    // Usamos la cantidad de cupones como alcance potencial mínimo garantizado.
    return widget.coupon.quantity;
  }

  // Canjes proyectados con fallback inteligente
  int get _canjesProyectados {
    if (!_isNewMerchant) {
      final s = _stats!;
      final highValue = (s.tierDistribution.tier2 + s.tierDistribution.tier3).toDouble();
      final low = s.tierDistribution.tier1.toDouble();
      return ((highValue * 0.4) + (low * 0.15)).round().clamp(1, widget.coupon.quantity);
    }
    // Para merchants nuevos: estimamos que el 60% de los cupones será canjeado
    return (widget.coupon.quantity * 0.6).ceil().clamp(1, widget.coupon.quantity);
  }

  double get _costoEstimado => widget.coupon.discountValue * widget.coupon.quantity;

  // GMV adicional proyectado
  double get _gmvAdicional {
    final s = _stats;
    final double avgTicket;
    if (s != null && s.totalTransactions > 0) {
      avgTicket = s.totalRevenue / s.totalTransactions;
    } else {
      // Benchmark: el ticket generado por la Yapa suele ser 3-4x el valor del descuento
      avgTicket = widget.coupon.discountValue * 3.5;
    }
    return _canjesProyectados * avgTicket;
  }

  double get _roi {
    if (_costoEstimado == 0) return 0;
    return ((_gmvAdicional - _costoEstimado) / _costoEstimado * 100).clamp(0, 9999);
  }

  // Etiqueta de contexto según si hay datos reales o son proyecciones
  String get _alcanceLabel => _isNewMerchant
      ? 'Cupones disponibles'
      : 'Clientes notificados';

  String get _proyeccionLabel => _isNewMerchant
      ? 'Canjes estimados'
      : 'Canjes proyectados';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A1587),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Impacto de tu Yapa',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A1587)))
          : FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Banner de éxito ───────────────────────────────
                      _SuccessBanner(coupon: widget.coupon),
                      const SizedBox(height: 24),

                      // ── Métricas principales ──────────────────────────
                      _sectionLabel('Alcance estimado'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _MetricCard(
                          value: '$_clientesAlcanzados',
                          label: _alcanceLabel,
                          sublabel: _isNewMerchant ? 'Cupones listos para repartir' : 'Personas con historial en tu negocio',
                          icon: Icons.people_outline,
                          iconColor: const Color(0xFF4A1587),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _MetricCard(
                          value: '$_canjesProyectados',
                          label: _proyeccionLabel,
                          sublabel: _isNewMerchant ? 'Estimado al 60% de uso' : 'Según fidelidad de clientes',
                          icon: Icons.redeem_outlined,
                          iconColor: const Color(0xFF0A9E8F),
                        )),
                      ]),
                      const SizedBox(height: 24),

                      // ── ROI destacado ─────────────────────────────────
                      _RoiCard(roi: _roi, gmv: _gmvAdicional, costo: _costoEstimado),
                      const SizedBox(height: 24),

                      // ── Distribución de clientes ──────────────────────
                      if (_stats != null && _stats!.totalCustomers > 0) ...[
                        _sectionLabel('¿A quiénes llega?'),
                        const SizedBox(height: 12),
                        _TierBreakdown(stats: _stats!),
                        const SizedBox(height: 24),
                      ],

                      // ── Disclaimer ────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.black38),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Las proyecciones se basan en el historial de tu negocio. Los resultados reales pueden variar.',
                                style: TextStyle(fontSize: 11, color: Colors.black38, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Cerrar ────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A1587),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text('Listo',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black45, letterSpacing: 0.3),
  );
}

// ── Success Banner ────────────────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  final MerchantCoupon coupon;
  const _SuccessBanner({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A1587), Color(0xFF7B2FBE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0A9E8F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text('Yapa publicada', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            coupon.name.isNotEmpty ? coupon.name : 'Yapa especial',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Descuento de \$${coupon.discountValue.toStringAsFixed(2)} · ${coupon.quantity} cupón${coupon.quantity != 1 ? 'es' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Metric Card ───────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String value, label, sublabel;
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 2),
          Text(sublabel, style: const TextStyle(fontSize: 11, color: Colors.black38, height: 1.3)),
        ],
      ),
    );
  }
}

// ── ROI Card ──────────────────────────────────────────────────────────────────
class _RoiCard extends StatelessWidget {
  final double roi, gmv, costo;
  const _RoiCard({required this.roi, required this.gmv, required this.costo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inversión y retorno',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black45, letterSpacing: 0.3)),
          const SizedBox(height: 16),
          _FinancialRow(
            label: 'Costo de la campaña',
            value: '\$${costo.toStringAsFixed(2)}',
          ),
          const Divider(height: 24, color: Color(0xFFF0F0F0)),
          _FinancialRow(
            label: 'Ventas adicionales proyectadas',
            value: '\$${gmv.toStringAsFixed(2)}',
            valueColor: const Color(0xFF0A9E8F),
          ),
          const Divider(height: 24, color: Color(0xFFF0F0F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ganancia sobre tu inversión',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: roi >= 100
                      ? const Color(0xFF0A9E8F).withValues(alpha: 0.1)
                      : const Color(0xFF4A1587).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${roi.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: roi >= 100 ? const Color(0xFF0A9E8F) : const Color(0xFF4A1587),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _FinancialRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        Text(value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? Colors.black87)),
      ],
    );
  }
}

// ── Tier Breakdown ────────────────────────────────────────────────────────────
class _TierBreakdown extends StatelessWidget {
  final MerchantStats stats;
  const _TierBreakdown({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.totalCustomers;
    final tiers = [
      (name: 'Bronce', count: stats.tierDistribution.tier1, color: const Color(0xFFCD7F32)),
      (name: 'Plata', count: stats.tierDistribution.tier2, color: const Color(0xFF9E9E9E)),
      (name: 'Oro', count: stats.tierDistribution.tier3, color: const Color(0xFFFFB300)),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: tiers.map((t) {
          final pct = total > 0 ? t.count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(t.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.color)),
                  Text('${t.count} · ${(pct * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.black38)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF0F0F0),
                    valueColor: AlwaysStoppedAnimation(t.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
