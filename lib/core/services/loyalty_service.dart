import 'package:dio/dio.dart';
import '../models/loyalty_profile.dart';
import '../network/api_client.dart';

class LoyaltyException implements Exception {
  LoyaltyException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LoyaltyService {
  Future<List<LoyaltyProfileEntry>> fetchProfile() async {
    try {
      final dio = await ApiClient.userAuthorized();
      final response = await dio.get('/loyalty/profile');
      final List data = response.data['data'] as List;
      return data
          .map((e) => LoyaltyProfileEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw LoyaltyException(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) return data['error'].toString();
    if (e.response?.statusCode == 401) return 'Sesión expirada. Vuelve a ingresar.';
    return 'No se pudo cargar tu perfil. Intenta de nuevo.';
  }
}
