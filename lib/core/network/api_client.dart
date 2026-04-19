import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  ApiClient._();

  static Dio get public => _buildDio();

  static Future<Dio> userAuthorized() async {
    final token = await TokenStorage.getUserToken();
    return _buildDio(token: token);
  }

  static Future<Dio> merchantAuthorized() async {
    final token = await TokenStorage.getMerchantToken();
    return _buildDio(token: token);
  }

  static Dio _buildDio({String? token}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    return dio;
  }
}
