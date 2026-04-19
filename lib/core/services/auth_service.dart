import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  // ── Usuario ──────────────────────────────────────────────────────────────

  Future<void> loginUser(String phone, String password) async {
    try {
      final response = await ApiClient.public.post('/auth/login', data: {
        'phone': phone,
        'password': password,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['accessToken'] as String;
      final fullName = data['fullName'] as String?;
      
      await Future.wait([
        TokenStorage.saveUserToken(token),
        if (fullName != null) TokenStorage.saveUserName(fullName),
      ]);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  Future<void> registerUser({
    required String phone,
    required String fullName,
    required String password,
    String? email,
  }) async {
    try {
      final response = await ApiClient.public.post('/auth/register', data: {
        'phone': phone,
        'fullName': fullName,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      });
      final token = response.data['data']['accessToken'] as String;
      await Future.wait([
        TokenStorage.saveUserToken(token),
        TokenStorage.saveUserName(fullName),
      ]);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  // ── Comerciante ───────────────────────────────────────────────────────────

  Future<void> loginMerchant(String email, String password) async {
    try {
      final response = await ApiClient.public.post('/merchants/auth/login', data: {
        'ownerEmail': email,
        'password': password,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      await Future.wait([
        TokenStorage.saveMerchantToken(data['accessToken'] as String),
        TokenStorage.saveMerchantId(data['merchantId'] as String),
      ]);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  Future<void> registerMerchant({
    required String businessName,
    required String ruc,
    required String ownerEmail,
    required String password,
    required String categoryId,
  }) async {
    try {
      final response = await ApiClient.public.post('/merchants/auth/register', data: {
        'businessName': businessName,
        'ruc': ruc,
        'ownerEmail': ownerEmail,
        'password': password,
        'categoryId': categoryId,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      await Future.wait([
        TokenStorage.saveMerchantToken(data['accessToken'] as String),
        TokenStorage.saveMerchantId(data['merchantId'] as String),
      ]);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  // ── Categorías (para el formulario de registro de comerciante) ────────────

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await ApiClient.public.get('/merchants/categories');
      final List data = response.data['data'] as List;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Error de conexión. Intenta de nuevo.';
  }
}
