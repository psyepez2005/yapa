import 'package:flutter/material.dart';
import 'package:yapa/core/models/merchant_stats.dart';

class GestionarView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF4A1587),
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Saldo Card ──────────────────────────────────────────
              _BalanceCard(stats: stats, loading: loadingStats, onTopUp: onTopUp),
              const SizedBox(height: 20),

              // ── Stats (Transacciones + Clientes) ────────────────────
              if (loadingStats)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(color: Color(0xFF4A1587)),
                  ),
                )
              else if (stats != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: 'Cobros realizados',
                        value: stats!.totalTransactions.toString(),
                        color: const Color(0xFF4A1587),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_outline,
                        label: 'Clientes totales',
                        value: stats!.totalCustomers.toString(),
                        color: const Color(0xFF0A9E8F),
                      ),
                    ),
                  ],
                ),
                if (stats!.totalRevenue > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A1587), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ingresos totales',
                                style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${stats!.totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Icon(Icons.trending_up, color: Colors.white70, size: 36),
                      ],
                    ),
                  ),
                ],
              ] else
                _EmptyStatsCard(onRefresh: onRefresh),

              const SizedBox(height: 24),

              // ── Programa de Fidelización (Loyalty Toggle) ───────────
              _LoyaltyToggleCard(
                enabled: loyaltyEnabled,
                toggling: togglingLoyalty,
                onToggle: onToggleLoyalty,
              ),
              const SizedBox(height: 24),

              // ── Accesos rápidos ──────────────────────────────────────
              const Text('Accesos rápidos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionIcon(context, Icons.arrow_downward, 'Recargar\nsaldo',
                      onTap: onTopUp),
                  _buildActionIcon(context, Icons.star_outline, 'Mis Yapas',
                      onTap: onNavigateToYapa),
                  _buildActionIcon(context, Icons.add_circle_outline, 'Crear\nYapa',
                      onTap: onCreateCoupon),
                  _buildActionIcon(context, Icons.history, 'Próx.\nfunciones',
                      disabled: true),
                ],
              ),
              const SizedBox(height: 32),

              // ── Trazabilidad de Yapa ─────────────────────────────────
              GestureDetector(
                onTap: onNavigateToYapa,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A1587), Color(0xFF7B1FA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.card_giftcard_outlined, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ver mis Yapas y clientes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              loadingStats
                                  ? 'Cargando...'
                                  : '${stats?.activeLoyaltyCoupons ?? 0} yapas activas · ${stats?.totalCustomers ?? 0} clientes',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return Flexible(
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: GestureDetector(
          onTap: disabled
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente disponible'),
                      duration: Duration(seconds: 2),
                    ),
                  )
              : onTap,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.01),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Icon(icon, color: Colors.black87, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: Colors.blueGrey, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loyalty Toggle Card ──────────────────────────────────────────────────────
class _LoyaltyToggleCard extends StatelessWidget {
  final bool enabled;
  final bool toggling;
  final ValueChanged<bool> onToggle;

  const _LoyaltyToggleCard({
    required this.enabled,
    required this.toggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? const Color(0xFF4A1587).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFF4A1587).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: enabled ? const Color(0xFF4A1587) : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Programa de Yapas',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                const SizedBox(height: 3),
                Text(
                  enabled
                      ? 'Activo — tus clientes están ganando puntos'
                      : 'Inactivo — tus clientes no ganan puntos',
                  style: TextStyle(
                    fontSize: 12,
                    color: enabled
                        ? const Color(0xFF0A9E8F)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          toggling
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF4A1587)),
                )
              : Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeColor: const Color(0xFF4A1587),
                ),
        ],
      ),
    );
  }
}

// ── Balance Card ────────────────────────────────────────────────────────────
class _BalanceCard extends StatefulWidget {
  final MerchantStats? stats;
  final bool loading;
  final VoidCallback onTopUp;

  const _BalanceCard({
    required this.stats,
    required this.loading,
    required this.onTopUp,
  });

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saldo para Yapas',
                  style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
              GestureDetector(
                onTap: () => setState(() => _hidden = !_hidden),
                child: Icon(
                  _hidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          widget.loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF4A1587)))
              : Text(
                  _hidden
                      ? '\$ ••••'
                      : '\$${(widget.stats?.balance ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 4),
          const Text(
            'Este saldo se usa para financiar los cupones que creas',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A1587),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: widget.onTopUp,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Recargar saldo',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty Stats Card ─────────────────────────────────────────────────────────
class _EmptyStatsCard extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyStatsCard({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 36, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No se pudo cargar la información',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black54)),
          const SizedBox(height: 4),
          const Text('Verifica tu conexión e intenta de nuevo',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh,
                color: Color(0xFF4A1587), size: 18),
            label: const Text('Reintentar',
                style: TextStyle(color: Color(0xFF4A1587))),
          ),
        ],
      ),
    );
  }
}
