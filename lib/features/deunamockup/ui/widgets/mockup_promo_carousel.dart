import 'package:flutter/material.dart';
import 'package:yapa/core/network/api_client.dart';

class MockupPromoCarousel extends StatefulWidget {
  const MockupPromoCarousel({super.key});

  @override
  State<MockupPromoCarousel> createState() => _MockupPromoCarouselState();
}

class _MockupPromoCarouselState extends State<MockupPromoCarousel> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _broadcasts = [];

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    try {
      final dio = await ApiClient.userAuthorized();
      final response = await dio.get('/loyalty/broadcasts');
      final List data = response.data['data'] as List;
      if (mounted) {
        setState(() {
          _broadcasts = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ofertas para ti', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          Container(height: 120, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16))),
        ],
      );
    }

    if (_broadcasts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Ofertas para ti', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE64A19),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_broadcasts.length} nueva${_broadcasts.length > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 132,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _broadcasts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _BroadcastCard(broadcast: _broadcasts[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BroadcastCard extends StatelessWidget {
  final Map<String, dynamic> broadcast;
  const _BroadcastCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final merchantName = broadcast['merchantName'] as String? ?? 'Negocio';
    final message = broadcast['message'] as String? ?? '';
    final couponValue = broadcast['couponValue'];
    final couponDouble = couponValue == null ? 0.0
        : couponValue is num ? couponValue.toDouble()
        : double.tryParse(couponValue.toString()) ?? 0.0;
    final initials = merchantName.length >= 2
        ? merchantName.substring(0, 2).toUpperCase()
        : merchantName.toUpperCase();

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A1587).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A1587), Color(0xFF7B2FBE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
                if (couponDouble > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '-\$${couponDouble.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE64A19).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('🎁 Oferta especial', style: TextStyle(color: Color(0xFFE64A19), fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    merchantName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
