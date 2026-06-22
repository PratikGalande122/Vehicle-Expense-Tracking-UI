import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/storage_helper.dart';

class AuthResult {
  final String userId;
  final String name;
  final String email;
  final String accessToken;
  final String refreshToken;

  const AuthResult({
    required this.userId,
    required this.name,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Sends an OTP to [email]. Returns the dev OTP if included in the response.
  Future<String?> sendOtp({
    required String email,
    required String fullName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.sendOtp,
        data: {'email': email, 'fullName': fullName},
      );
      final data = response.data;
      if (data is Map) {
        return data['otp']?.toString() ?? data['devOtp']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Verifies the OTP and saves tokens on success.
  Future<AuthResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      final data = response.data as Map<String, dynamic>;
      final result = AuthResult(
        userId: data['userId']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        email: data['email']?.toString() ?? email,
        accessToken: data['accessToken']?.toString() ?? '',
        refreshToken: data['refreshToken']?.toString() ?? '',
      );
      await StorageHelper.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await StorageHelper.saveUserInfo(
        userId: result.userId,
        email: result.email,
        name: result.name,
      );
      return result;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() async {
    await StorageHelper.clearAll();
  }

  Exception _mapError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response!.data['message'] ??
            e.response!.data['error'] ??
            'Request failed')
        : e.message ?? 'Request failed';
    return Exception(msg.toString());
  }
}
