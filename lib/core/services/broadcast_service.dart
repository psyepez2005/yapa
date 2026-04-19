import 'package:dio/dio.dart';
import '../models/broadcast.dart';
import '../network/api_client.dart';

class BroadcastService {
  Future<List<MerchantBroadcast>> fetchBroadcasts({DateTime? since}) async {
    final sinceParam = (since ?? DateTime.now().subtract(const Duration(days: 7)))
        .toUtc()
        .toIso8601String();
    try {
      final dio = await ApiClient.userAuthorized();
      final response = await dio.get(
        '/loyalty/broadcasts',
        queryParameters: {'since': sinceParam},
      );
      final List raw = (response.data['data'] as List?) ?? [];
      return raw.cast<Map<String, dynamic>>().map(MerchantBroadcast.fromJson).toList();
    } on DioException {
      return [];
    }
  }
}
