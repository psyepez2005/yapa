import 'package:flutter/material.dart';
import 'package:yapa/core/models/merchant_stats.dart';
import 'package:yapa/core/network/api_client.dart';

class GestionarView extends StatefulWidget {
  final MerchantStats? stats;
  final List<MerchantCoupon> coupons;
  final bool loadingStats;
  final bool loyaltyEnabled;
  final bool togglingLoyalty;
  final Future<void> Function() onRefresh;
  final VoidCallback onTopUp;
  final VoidCallback onCreateCoupon;
  final VoidCallback onNavigateToYapa;
  final ValueChanged<bool> onToggleLoyalty;

  const GestionarView({
    super.key,
    required this.stats,
    required this.coupons,
    required this.loadingStats,
    required this.loyaltyEnabled,
    required this.togglingLoyalty,
    required this.onRefresh,
    required this.onTopUp,
    required this.onCreateCoupon,
    required this.onNavigateToYapa,
    required this.onToggleLoyalty,
  });

  @override
  State<GestionarView> createState() => _GestionarViewState();
}

class _GestionarViewState extends State<GestionarView> {
  List<Map<String, dynamic>> _recentTx = [];

  @override
  void initState() {
    super.initState();
    if (widget.stats != null) _loadRecentTx();
  }

  @override
  void didUpdateWidget(covariant GestionarView old) {
    super.didUpdateWidget(old);
    if (old.stats == null && widget.stats != null) _loadRecentTx();
  }

  Future<void> _loadRecentTx() async {
    try {
      final dio = await ApiClient.merchantAuthorized();
      final res = await dio.get('/merchants/me/transactions?limit=5');
      final List raw = res.data['data'] as List? ?? [];
      if (mounted) setState(() => _recentTx = raw.cast<Map<String, dynamic>>());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stats;
    final total = s?.totalCustomers ?? 0;
    final returning = s?.returningCustomers ?? 0;
    final retPct = total > 0 ? ((returning / total) * 10).round() : 0;
    final gmv = s?.totalRevenue ?? 0.0;
    final balance = s?.balance ?? 0.0;
    final activeCoupons = widget.coupons.where((c) => c.isActive).length;

    return RefreshIndicator(
      color: const Color(0xFF4A1587),
      onRefresh: () async {
        await widget.onRefresh();
        await _loadRecentTx();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: widget.loadingStats
            ? _Skeleton()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Resumen de ingresos (con color) ─────────────────
                  _GmvCard(gmv: gmv, totalTx: s?.totalTransactions ?? 0),
                  const SizedBox(height: 16),

                  // ── Saldo ─────────────────────────────────────────────
                  _BalanceCard(balance: balance, onTopUp: widget.onTopUp),
                  const SizedBox(height: 20),

                  // ── Clientes ──────────────────────────────────────────
                  if (total > 0) ...[
                    _ClientsSummary(
                      total: total,
                      retPct: retPct,
                      bronce: s?.tierDistribution.tier1 ?? 0,
                      plata: s?.tierDistribution.tier2 ?? 0,
                      oro: s?.tierDistribution.tier3 ?? 0,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Alerta principal ──────────────────────────────────
                  if (_mainAlert(activeCoupons, balance, widget.loyaltyEnabled) != null) ...[
                    _mainAlert(activeCoupons, balance, widget.loyaltyEnabled)!,
                    const SizedBox(height: 20),
                  ],

                  // ── Acciones ──────────────────────────────────────────
                  _ActionsRow(
                    onTopUp: widget.onTopUp,
                    onYapa: widget.onCreateCoupon,
                    onMisYapas: widget.onNavigateToYapa,
                  ),
                  const SizedBox(height: 20),

                  // ── Programa de lealtad ───────────────────────────────
                  _LoyaltyRow(
                    enabled: widget.loyaltyEnabled,
                    toggling: widget.togglingLoyalty,
                    onToggle: widget.onToggleLoyalty,
                  ),
                  const SizedBox(height: 20),

                  // ── Últimos cobros ────────────────────────────────────
                  if (_recentTx.isNotEmpty) ...[
                    const Text('Últimos cobros',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black45, letterSpacing: 0.3)),
                    const SizedBox(height: 10),
                    _RecentTxList(transactions: _recentTx),
                  ],
                ],
              ),
      ),
    );
  }

  Widget? _mainAlert(int activeCoupons, double balance, bool loyaltyEnabled) {
    if (!loyaltyEnabled) {
      return _Alert(
        title: 'Tu programa de Yapas está apagado',
        subtitle: 'Tus clientes no están ganando puntos. Actívalo para retenerlos.',
        actionLabel: 'Activar ahora',
        onTap: () => widget.onToggleLoyalty(true),
      );
    }
    if (activeCoupons == 0 && balance > 0) {
      return _Alert(
        title: 'Tienes saldo disponible',
        subtitle: 'Crea una Yapa y avisa a tus clientes — puedes hacerlo en menos de un minuto.',
        actionLabel: 'Crear Yapa',
        onTap: widget.onCreateCoupon,
      );
    }
    return null;
  }
}

// ── GMV Card (con gradiente) ──────────────────────────────────────────────────
class _GmvCard extends StatelessWidget {
  final double gmv;
  final int totalTx;
  const _GmvCard({required this.gmv, required this.totalTx});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
          const Text('Ventas generadas', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            '\$${gmv.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            totalTx > 0 ? 'en $totalTx cobro${totalTx != 1 ? 's' : ''} completados' : 'Aún sin cobros registrados',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Balance Card ──────────────────────────────────────────────────────────────
class _BalanceCard extends StatefulWidget {
  final double balance;
  final VoidCallback onTopUp;
  const _BalanceCard({required this.balance, required this.onTopUp});

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo para Yapas', style: TextStyle(color: Colors.black45, fontSize: 12)),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _hidden = !_hidden),
                  child: Row(
                    children: [
                      Text(
                        _hidden ? '\$••••' : '\$${widget.balance.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 16, color: Colors.black38),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onTopUp,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF4A1587),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Recargar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Clients Summary ───────────────────────────────────────────────────────────
class _ClientsSummary extends StatelessWidget {
  final int total, retPct, bronce, plata, oro;
  const _ClientsSummary({required this.total, required this.retPct,
    required this.bronce, required this.plata, required this.oro});

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem('$total', 'visitantes'),
              _divider(),
              _statItem('$retPct de cada 10', 'vuelven'),
              _divider(),
              _statItem('$oro', 'clientes VIP'),
            ],
          ),
          if (bronce > 0 || plata > 0 || oro > 0) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 14),
            Row(children: [
              _tierPill('Bronce', bronce, const Color(0xFFCD7F32)),
              const SizedBox(width: 8),
              _tierPill('Plata', plata, const Color(0xFF9E9E9E)),
              const SizedBox(width: 8),
              _tierPill('Oro', oro, const Color(0xFFFFB300)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45), textAlign: TextAlign.center),
    ]),
  );

  Widget _divider() => Container(width: 1, height: 36, color: const Color(0xFFEEEEEE));

  Widget _tierPill(String label, int count, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
      ]),
    ),
  );
}

// ── Alert ─────────────────────────────────────────────────────────────────────
class _Alert extends StatelessWidget {
  final String title, subtitle, actionLabel;
  final VoidCallback onTap;
  const _Alert({required this.title, required this.subtitle, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4A1587).withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D0066))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: const Text('→ ', style: TextStyle(color: Color(0xFF4A1587), fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Actions Row ───────────────────────────────────────────────────────────────
class _ActionsRow extends StatelessWidget {
  final VoidCallback onTopUp, onYapa, onMisYapas;
  const _ActionsRow({required this.onTopUp, required this.onYapa, required this.onMisYapas});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _ActionBtn(icon: Icons.add, label: 'Crear Yapa', onTap: onYapa, primary: true),
      const SizedBox(width: 10),
      _ActionBtn(icon: Icons.star_outline, label: 'Mis Yapas', onTap: onMisYapas),
      const SizedBox(width: 10),
      _ActionBtn(icon: Icons.arrow_downward, label: 'Recargar', onTap: onTopUp),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: primary ? const Color(0xFF4A1587) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary ? const Color(0xFF4A1587) : const Color(0xFFEEEEEE)),
          ),
          child: Column(children: [
            Icon(icon, size: 22, color: primary ? Colors.white : Colors.black54),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: primary ? Colors.white : Colors.black54)),
          ]),
        ),
      ),
    );
  }
}

// ── Loyalty Row ───────────────────────────────────────────────────────────────
class _LoyaltyRow extends StatelessWidget {
  final bool enabled, toggling;
  final ValueChanged<bool> onToggle;
  const _LoyaltyRow({required this.enabled, required this.toggling, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Programa de Yapas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 2),
          Text(enabled ? 'Activo — tus clientes ganan puntos' : 'Inactivo — tus clientes no acumulan',
              style: TextStyle(fontSize: 12, color: enabled ? const Color(0xFF0A9E8F) : Colors.black38)),
        ])),
        toggling
            ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A1587)))
            : Switch(value: enabled, onChanged: onToggle, activeColor: const Color(0xFF4A1587)),
      ]),
    );
  }
}

// ── Recent Transactions ───────────────────────────────────────────────────────
class _RecentTxList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  const _RecentTxList({required this.transactions});

  String _timeAgo(String? d) {
    if (d == null) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(d).toLocal());
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      return 'Hace ${diff.inDays}d';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: transactions.asMap().entries.map((e) {
          final i = e.key;
          final tx = e.value;
          final amt = (tx['amount'] as num?)?.toDouble() ?? 0.0;
          final date = tx['date'] as String?;
          return Column(children: [
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF5F5F5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                const Icon(Icons.receipt_outlined, size: 18, color: Colors.black26),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  _timeAgo(date).isNotEmpty ? _timeAgo(date) : 'Cobro reciente',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                )),
                Text('+\$${amt.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0A9E8F))),
              ]),
            ),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 100, decoration: BoxDecoration(color: const Color(0xFF4A1587).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16))),
      const SizedBox(height: 16),
      ...List.generate(2, (_) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
      )),
    ]);
  }
}
