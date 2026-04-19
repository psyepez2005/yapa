import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/core/models/broadcast.dart';
import 'package:yapa/core/services/loyalty_service.dart';
import 'package:yapa/core/services/broadcast_service.dart';
import '../widgets/loyalty_header.dart';
import '../widgets/loyalty_global_progress.dart';
import '../widgets/loyalty_business_card.dart';
import '../../../deunamockup/ui/widgets/mockup_bottom_nav.dart';

class LoyaltyDashboardScreen extends StatefulWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  State<LoyaltyDashboardScreen> createState() => _LoyaltyDashboardScreenState();
}

class _LoyaltyDashboardScreenState extends State<LoyaltyDashboardScreen> {
  final _service = LoyaltyService();
  final _broadcastService = BroadcastService();

  List<LoyaltyProfileEntry> _entries = [];
  List<MerchantBroadcast> _broadcasts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadBroadcasts();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchProfile();
      if (mounted) setState(() => _entries = data);
    } on LoyaltyException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBroadcasts() async {
    try {
      final data = await _broadcastService.fetchBroadcasts();
      if (mounted) setState(() => _broadcasts = data);
    } catch (_) {
    }
  }

  double get _totalYapasValue =>
      _entries.fold(0.0, (sum, e) => sum + e.totalYapasValue);

  int get _totalYapasCount =>
      _entries.fold(0, (sum, e) => sum + e.yapasCount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_loadProfile(), _loadBroadcasts()]);
        },
        color: const Color(0xFF4A1587),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: const LoyaltyHeader()),
            SliverToBoxAdapter(
              child: _isLoading
                  ? _buildGlobalSkeleton()
                  : LoyaltyGlobalProgress(
                      totalYapasValue: _totalYapasValue,
                      totalYapasCount: _totalYapasCount,
                      entries: _entries,
                    ),
            ),
            if (!_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.pushNamed('my_yapas', extra: _entries),
                      icon: const Icon(Icons.stars_rounded, color: Colors.white),
                      label: const Text(
                        'Ver mis Yapas disponibles',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A1587),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_broadcasts.isNotEmpty)
              SliverToBoxAdapter(
                child: _BroadcastsSection(broadcasts: _broadcasts),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Negocios del Barrio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (!_isLoading && _entries.isNotEmpty)
                      Text(
                        '${_entries.length} ${_entries.length == 1 ? 'local' : 'locales'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildCardSkeleton(),
                  childCount: 3,
                ),
              )
            else if (_error != null)
              SliverToBoxAdapter(child: _buildErrorState())
            else if (_entries.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final entry = _entries[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (entry.isDegradationRisk)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.orange.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '⚠️ Tu nivel en ${entry.merchantName} baja en ${entry.degradationRiskDays} día${entry.degradationRiskDays == 1 ? '' : 's'}. ¡Visita pronto!',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        LoyaltyBusinessCard(
                          businessName: entry.merchantName,
                          category: 'Negocio local',
                          location: 'Ecuador',
                          tierName: entry.tierName,
                          cashbackPercentage: entry.cashbackLabel,
                          minPurchaseAmount: '-',
                          visits: entry.yapasCount,
                          progress: entry.progressValue,
                          nextLevel: entry.nextTierName,
                          purchasesNeeded:
                              entry.pointsToNextCoupon?.toInt() ?? 0,
                          businessIcon: Icons.storefront,
                          currentYapas: entry.yapasCount,
                          onTap: () => context.pushNamed(
                            'business_detail',
                            extra: {
                              'merchantId': entry.merchantId,
                              'name': entry.merchantName,
                              'icon': Icons.storefront,
                              'tier': entry.tierName,
                              'cashback': entry.cashbackLabel,
                              'currentPoints': entry.trustPoints.toInt(),
                              'targetPoints': entry.targetPoints.toInt(),
                              'activeYapas': entry.activeYapas,
                              'totalYapasValue': entry.totalYapasValue,
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: _entries.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
      bottomNavigationBar: const MockupBottomNav(currentIndex: 1),
    );
  }

  Widget _buildGlobalSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _SkeletonBox(height: 140, borderRadius: 20),
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonBox(width: 50, height: 50, borderRadius: 25),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(height: 16, borderRadius: 8),
                    const SizedBox(height: 8),
                    _SkeletonBox(height: 12, width: 120, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SkeletonBox(height: 12, borderRadius: 6),
          const SizedBox(height: 8),
          _SkeletonBox(height: 8, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfile,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A1587),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF4A1587).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 52,
              color: Color(0xFF4A1587),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '¡Aún no tienes negocios!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escanea el QR de un negocio y empieza\na acumular puntos de confianza y yapas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/qr-scanner'),
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text(
              'Escanear mi primer QR',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A1587),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _BroadcastsSection extends StatelessWidget {
  final List<MerchantBroadcast> broadcasts;

  const _BroadcastsSection({required this.broadcasts});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A1587).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign_outlined, color: Color(0xFF4A1587), size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ofertas de tus negocios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A1587),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${broadcasts.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...broadcasts.take(3).map((b) => _BroadcastCard(broadcast: b, timeAgo: _timeAgo(b.createdAt))),
        ],
      ),
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final MerchantBroadcast broadcast;
  final String timeAgo;

  const _BroadcastCard({required this.broadcast, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4A1587).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A1587).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_outlined, color: Color(0xFF4A1587), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        broadcast.merchantName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  broadcast.message,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                ),
                if (broadcast.couponValue != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A9E8F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Descuento: \$${broadcast.couponValue!.toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFF0A9E8F), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: _anim.value * 0.3),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
