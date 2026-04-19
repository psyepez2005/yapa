import 'package:dio/dio.dart';
import '../models/transaction_result.dart';
import '../network/api_client.dart';

class ScanException implements Exception {
  ScanException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ScanService {
  Future<TransactionResult> scan({
    required String merchantId,
    required double amount,
    String? couponId,
  }) async {
    try {
      final dio = await ApiClient.userAuthorized();
      final body = <String, dynamic>{
        'merchantId': merchantId,
        'amount': amount,
      };
      if (couponId != null) body['couponId'] = couponId;

      final response = await dio.post('/loyalty/scan', data: body);
      return TransactionResult.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ScanException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.response?.statusCode == 401) return 'Sesión expirada. Vuelve a ingresar.';
    if (e.response?.statusCode == 404) return 'Negocio no encontrado.';
    return 'No se pudo procesar el pago. Intenta de nuevo.';
  }
}
