import 'package:flutter/material.dart';
import 'package:yapa/core/models/merchant_stats.dart';

class GestionarView extends StatelessWidget {
  final MerchantStats? stats;
  final List<MerchantCoupon> coupons;
  final bool loadingStats;
  final Future<void> Function() onRefresh;
  final VoidCallback onTopUp;
  final VoidCallback onCreateCoupon;

  const GestionarView({
    super.key,
    required this.stats,
    required this.coupons,
    required this.loadingStats,
    required this.onRefresh,
    required this.onTopUp,
    required this.onCreateCoupon,
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

              // Trazabilidad de Yapa
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🎁', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text(
                              'Trazabilidad de Yapa',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A1587),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (loadingStats)
                          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4A1587)))
                        else
                          const Text('Este mes', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Inversión del negocio', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${(stats?.yapaInvestmentTotal ?? 0).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFF4A1587), fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${((stats?.yapaCashbackRate ?? 0.02) * 100).toInt()}% por cliente',
                                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Vecinos que volvieron', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${stats?.returningCustomersThisMonth ?? 0}',
                                  style: const TextStyle(color: Color(0xFF0A9E8F), fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'de ${stats?.totalCustomers ?? 0} clientes',
                                  style: const TextStyle(color: Color(0xFF0A9E8F), fontSize: 9),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cupones activos
              if (coupons.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mis Yapas configuradas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: onCreateCoupon,
                      icon: const Icon(Icons.add, color: Color(0xFF4A1587), size: 18),
                      label: const Text('Nueva', style: TextStyle(color: Color(0xFF4A1587))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...coupons.map((c) => _buildCouponTile(c)),
              ] else ...[
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: onCreateCoupon,
                  icon: const Icon(Icons.add, color: Color(0xFF4A1587)),
                  label: const Text('Crear nueva Yapa', style: TextStyle(color: Color(0xFF4A1587))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4A1587)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],

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

  Widget _buildCouponTile(MerchantCoupon coupon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: coupon.isActive ? const Color(0xFFE0F7FA) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 20, color: coupon.isActive ? null : Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${coupon.discountValue.toStringAsFixed(2)} de descuento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: coupon.isActive ? const Color(0xFF00897B) : Colors.grey,
                  ),
                ),
                Text(
                  'Nivel requerido: ${coupon.tierRequired}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: coupon.isActive ? const Color(0xFF00BFA5) : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              coupon.isActive ? 'Activo' : 'Inactivo',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
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
