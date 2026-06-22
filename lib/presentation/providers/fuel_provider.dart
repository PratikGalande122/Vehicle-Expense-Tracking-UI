import 'package:flutter/foundation.dart';
import '../../data/models/fuel_log_model.dart';
import '../../data/repositories/fuel_repository.dart';

class FuelProvider extends ChangeNotifier {
  final FuelRepository _repository;

  FuelProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<FuelLogModel> _fuelLogs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FuelLogModel> get fuelLogs => _fuelLogs;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadFuelLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fuelLogs = await _repository.getFuelLogs();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFuelLog(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final log = await _repository.addFuelLog(data);
      _fuelLogs = [log, ..._fuelLogs];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFuelLog(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateFuelLog(id, data);
      _fuelLogs = _fuelLogs.map((f) => f.id == id ? updated : f).toList();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFuelLog(String id) async {
    _error = null;

    try {
      await _repository.deleteFuelLog(id);
      _fuelLogs = _fuelLogs.where((f) => f.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
