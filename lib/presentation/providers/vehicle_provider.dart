import 'package:flutter/foundation.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleRepository _repository;

  VehicleProvider(this._repository);

  bool _isLoading = false;
  String? _error;
  List<VehicleModel> _vehicles = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<VehicleModel> get vehicles => _vehicles;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _repository.getVehicles();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVehicle(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vehicle = await _repository.addVehicle(data);
      _vehicles = [vehicle, ..._vehicles];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVehicle(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateVehicle(id, data);
      _vehicles = [
        for (final v in _vehicles) v.id == id ? updated : v,
      ];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteVehicle(String id) async {
    _error = null;

    try {
      await _repository.deleteVehicle(id);
      _vehicles = _vehicles.where((v) => v.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
