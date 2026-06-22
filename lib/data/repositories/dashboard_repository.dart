import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboard);
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
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
