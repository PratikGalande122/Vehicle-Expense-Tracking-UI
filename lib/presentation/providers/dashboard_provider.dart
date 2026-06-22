import 'package:flutter/foundation.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  DashboardModel? _dashboard;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardModel? get dashboard => _dashboard;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _repository.getDashboard();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
