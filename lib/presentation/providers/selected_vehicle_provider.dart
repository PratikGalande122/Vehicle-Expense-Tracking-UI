import 'package:flutter/foundation.dart';
import '../../data/models/vehicle_model.dart';

/// Holds the currently selected vehicle across the app.
/// Null means "All Vehicles" (show aggregate data).
class SelectedVehicleProvider extends ChangeNotifier {
  VehicleModel? _selectedVehicle;

  VehicleModel? get selectedVehicle => _selectedVehicle;

  bool get hasSelection => _selectedVehicle != null;

  void select(VehicleModel vehicle) {
    if (_selectedVehicle?.id == vehicle.id) return;
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedVehicle == null) return;
    _selectedVehicle = null;
    notifyListeners();
  }
}
