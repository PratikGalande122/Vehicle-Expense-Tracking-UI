import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.userProfile);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.userProfile,
        data: data,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _apiClient.dio.delete(ApiConstants.userAccount);
    } on DioException catch (e) {
      throw _mapError(e);
    }
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
