import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  final ApiClient _apiClient;

  VehicleRepository(this._apiClient);

  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.vehicles);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => VehicleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<VehicleModel> addVehicle(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.vehicles,
        data: data,
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<VehicleModel> updateVehicle(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.vehicleById(id),
        data: data,
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      await _apiClient.dio.delete(ApiConstants.vehicleById(id));
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
