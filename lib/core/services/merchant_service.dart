import 'package:dio/dio.dart';
import '../models/merchant_stats.dart';
import '../network/api_client.dart';

class MerchantException implements Exception {
  MerchantException(this.message);
  final String message;

  @override
  String toString() => message;
}

class MerchantService {
  Future<MerchantStats> fetchStats() async {
    try {
      final dio = await ApiClient.merchantAuthorized();
      final response = await dio.get('/merchants/me/stats');
      final body = response.data;
      final data = body is Map<String, dynamic> ? body : {'data': body};
      return MerchantStats.fromJson(data);
    } on DioException catch (e) {
      throw MerchantException(_extractMessage(e));
    }
  }

  Future<List<MerchantCoupon>> fetchCoupons() async {
    try {
      final dio = await ApiClient.merchantAuthorized();
      final response = await dio.get('/merchants/me/coupons');
      final body = response.data;
      final List raw = (body is Map ? body['data'] : body) as List? ?? [];
      return raw
          .cast<Map<String, dynamic>>()
          .map(MerchantCoupon.fromJson)
          .toList();
    } on DioException catch (e) {
      throw MerchantException(_extractMessage(e));
    }
  }

  Future<void> topUpFund(double amount) async {
    try {
      final dio = await ApiClient.merchantAuthorized();
      await dio.post('/merchants/me/fund', data: {'amount': amount});
    } on DioException catch (e) {
      throw MerchantException(_extractMessage(e));
    }
  }

  Future<MerchantCoupon> createCoupon({
    required double value,
    required double minimumPurchase,
    required String code,
    required String expiresAt,
  }) async {
    try {
      final dio = await ApiClient.merchantAuthorized();
      final response = await dio.post('/merchants/me/coupons', data: {
        'value': value,
        'minimumPurchase': minimumPurchase,
        'code': code,
        'expiresAt': expiresAt,
      });
      final body = response.data;
      final data = (body is Map ? body['data'] : body) as Map<String, dynamic>;
      return MerchantCoupon.fromJson(data);
    } on DioException catch (e) {
      throw MerchantException(_extractMessage(e));
    }
  }

  Future<void> toggleLoyalty({required bool enabled}) async {
    try {
      final dio = await ApiClient.merchantAuthorized();
      await dio.patch('/merchants/me/loyalty', data: {'enabled': enabled});
    } on DioException catch (e) {
      throw MerchantException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (e.response?.statusCode == 401) return 'Sesión expirada. Vuelve a ingresar.';
    return 'Error al cargar datos del negocio.';
  }
}
