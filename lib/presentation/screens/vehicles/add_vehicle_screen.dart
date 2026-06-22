import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/vehicle_model.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();       // vehicle name (e.g. "My Bike")
  final _brandController = TextEditingController();      // brand â†’ API 'brand'
  final _modelController = TextEditingController();      // model â†’ API 'model'
  final _yearController = TextEditingController();
  final _regController = TextEditingController();        // registration number
  String? _selectedFuelType;
  String? _selectedVehicleType;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regController.dispose();
    super.dispose();
  }

  int _fuelTypeToInt(String v) {
    switch (v) {
      case 'Petrol':   return 1;
      case 'Diesel':   return 2;
      case 'Electric': return 3;
      case 'CNG':      return 4;
      case 'Hybrid':   return 5;
      default:         return 1;
    }
  }

  int _vehicleTypeToInt(String v) {
    switch (v) {
      case 'Bike':    return 1;
      case 'Car':     return 2;
      case 'Scooter': return 3;
      case 'Truck':   return 4;
      default:        return 5;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFuelType == null || _selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select vehicle type and fuel type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<VehicleProvider>();
    final success = await provider.addVehicle({
      'name': _nameController.text.trim(),
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
      'year': int.parse(_yearController.text.trim()),
      'registrationNumber': _regController.text.trim(),
      'vehicleType': _vehicleTypeToInt(_selectedVehicleType!),
      'fuelType': _fuelTypeToInt(_selectedFuelType!),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add vehicle'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Vehicle Name
                CustomTextField(
                  label: 'Vehicle Name *',
                  hint: 'e.g. My Bike, Family Car',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                // Brand + Model
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Brand *',
                        hint: 'Honda, Toyota',
                        controller: _brandController,
                        prefixIcon: const Icon(Icons.business_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Model *',
                        hint: 'CBR, Camry',
                        controller: _modelController,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Year + Registration Number
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Year *',
                        hint: '2023',
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        prefixIcon:
                            const Icon(Icons.calendar_today_outlined),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final y = int.tryParse(v.trim());
                          if (y == null ||
                              y < 1900 ||
                              y > DateTime.now().year + 1) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Reg. Number *',
                        hint: 'MH12AB1234',
                        controller: _regController,
                        prefixIcon: const Icon(Icons.badge_outlined),
                        textInputAction: TextInputAction.done,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Vehicle Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  decoration: _dropdownDecoration(
                      'Vehicle Type *', Icons.two_wheeler_outlined),
                  hint: const Text('Select vehicle type'),
                  items: VehicleModel.vehicleTypes
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedVehicleType = v),
                  validator: (v) =>
                      v == null ? 'Please select a vehicle type' : null,
                ),
                const SizedBox(height: 14),
                // Fuel Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedFuelType,
                  decoration: _dropdownDecoration(
                      'Fuel Type *', Icons.local_gas_station_outlined),
                  hint: const Text('Select fuel type'),
                  items: VehicleModel.fuelTypes
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedFuelType = v),
                  validator: (v) =>
                      v == null ? 'Please select a fuel type' : null,
                ),
                const SizedBox(height: 28),
                Consumer<VehicleProvider>(
                  builder: (context, provider, _) => CustomButton(
                    text: 'Add Vehicle',
                    isLoading: provider.isLoading,
                    onPressed: _submit,
                    icon: Icons.add,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
