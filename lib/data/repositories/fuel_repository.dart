import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/fuel_log_model.dart';

class FuelRepository {
  final ApiClient _apiClient;

  FuelRepository(this._apiClient);

  Future<List<FuelLogModel>> getFuelLogs() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.fuel);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => FuelLogModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<FuelLogModel> addFuelLog(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiClient.dio.post(ApiConstants.fuel, data: data);
      return FuelLogModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<FuelLogModel> updateFuelLog(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _apiClient.dio.put(ApiConstants.fuelById(id), data: data);
      return FuelLogModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteFuelLog(String id) async {
    try {
      await _apiClient.dio.delete(ApiConstants.fuelById(id));
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
