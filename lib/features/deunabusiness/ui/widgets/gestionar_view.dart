import 'package:flutter/material.dart';
import 'package:yapa/core/models/merchant_stats.dart';

class GestionarView extends StatelessWidget {
  final MerchantStats? stats;
  final List<MerchantCoupon> coupons;
  final bool loadingStats;
  final Future<void> Function() onRefresh;
  final VoidCallback onTopUp;
  final VoidCallback onCreateCoupon;
  final VoidCallback onNavigateToYapa;

  const GestionarView({
    super.key,
    required this.stats,
    required this.coupons,
    required this.loadingStats,
    required this.onRefresh,
    required this.onTopUp,
    required this.onCreateCoupon,
    required this.onNavigateToYapa,
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
              // Saldo Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mi Saldo', style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            loadingStats
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A1587)))
                                : Text(
                                    '\$${(stats?.balance ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                                  ),
                            const SizedBox(width: 12),
                            const Icon(Icons.remove_red_eye, color: Colors.black87, size: 20),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats row: Transacciones + Clientes
              if (stats != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        label: 'Transacciones',
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
                const SizedBox(height: 12),
                if (stats!.totalRevenue > 0)
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
                            const Text('Ingresos totales', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '\$${stats!.totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Icon(Icons.trending_up, color: Colors.white70, size: 36),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Accesos rapidos
              const Text('Accesos rápidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildActionIcon(Icons.arrow_downward, 'Recargar\nsaldo', onTap: onTopUp),
                  _buildActionIcon(Icons.arrow_upward, 'Transferir\nsaldo'),
                  _buildActionIcon(Icons.attach_money, 'Venta\nManual'),
                  _buildActionIcon(Icons.verified_user_outlined, 'Verificar\npago'),
                ],
              ),
              const SizedBox(height: 32),

              // ── Card-preview de Yapa (lleva a la pantalla completa) ──
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
                        child: const Text('🎁', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trazabilidad de Yapa',
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
                                  : '\$${(stats?.yapaInvestmentTotal ?? 0).toStringAsFixed(2)} invertidos · ${stats?.returningCustomersThisMonth ?? 0} vecinos',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              // Novedades Deuna Negocios
              const Text('Novedades Deuna Negocios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildNovedadCard('Agrega\nvendedores\na tu equipo')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildNovedadCard('Administra\ntus ventas\ncon tu caja')),
                ],
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
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Icon(icon, color: Colors.black87, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNovedadCard(String text) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.2, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A9E8F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('d!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
