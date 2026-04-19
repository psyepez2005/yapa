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

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (data is Map && data['message'] != null) return data['message'].toString();
    if (e.response?.statusCode == 401) return 'Sesión expirada. Vuelve a ingresar.';
    return 'Error al cargar datos del negocio.';
  }
}
