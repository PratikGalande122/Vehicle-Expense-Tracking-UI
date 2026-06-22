import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final ApiClient _apiClient;

  ExpenseRepository(this._apiClient);

  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.expenses);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ExpenseModel> addExpense(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiClient.dio.post(ApiConstants.expenses, data: data);
      return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<ExpenseModel> updateExpense(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio
          .put(ApiConstants.expenseById(id), data: data);
      return ExpenseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _apiClient.dio.delete(ApiConstants.expenseById(id));
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
