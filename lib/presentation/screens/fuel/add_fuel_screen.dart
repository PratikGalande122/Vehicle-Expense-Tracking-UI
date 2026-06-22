import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/selected_vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class AddFuelScreen extends StatefulWidget {
  const AddFuelScreen({super.key});

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _priceController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedVehicleId;
  DateTime _selectedDate = DateTime.now();

  double get _totalCost {
    final liters = double.tryParse(_litersController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return liters * price;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vp = context.read<VehicleProvider>();
      if (vp.vehicles.isEmpty) vp.loadVehicles();
      final svp = context.read<SelectedVehicleProvider>();
      if (svp.selectedVehicle != null) {
        setState(() => _selectedVehicleId = svp.selectedVehicle!.id);
      }
    });
  }

  @override
  void dispose() {
    _litersController.dispose();
    _priceController.dispose();
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final liters = double.parse(_litersController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final provider = context.read<FuelProvider>();
    final success = await provider.addFuelLog({
      'vehicleId': int.parse(_selectedVehicleId!),  // API expects int
      'filledAt': _selectedDate.toIso8601String(),   // API field name
      'litresFilled': liters,                         // API field name
      'pricePerLitre': price,                         // API field name (British spelling)
      'odometerReading': _odometerController.text.trim().isNotEmpty
          ? double.parse(_odometerController.text.trim())
          : 0.0,                                      // API requires this field
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fuel log added successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add fuel log'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currencyFormat;
    final df = DateFormat(settings.datePattern);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Fuel Log'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle picker
                Consumer<VehicleProvider>(
                  builder: (context, vp, _) {
                    if (vp.isLoading && vp.vehicles.isEmpty) {
                      return const LoadingIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedVehicleId,
                      decoration: InputDecoration(
                        labelText: 'Vehicle *',
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: theme.colorScheme.outline),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      hint: const Text('Select a vehicle'),
                      items: vp.vehicles
                          .map((v) => DropdownMenuItem(
                              value: v.id, child: Text(v.displayName)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedVehicleId = v),
                      validator: (v) =>
                          v == null ? 'Please select a vehicle' : null,
                    );
                  },
                ),
                const SizedBox(height: 14),
                // Date picker
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date *',
                      prefixIcon:
                          const Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.colorScheme.outline),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    child: Text(df.format(_selectedDate)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Liters *',
                        hint: '40.00',
                        controller: _litersController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: Icon(Icons.opacity_outlined),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,3}'))
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if ((double.tryParse(v.trim()) ?? 0) <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: '${settings.currencySymbol}/${settings.volumeAbbr} *',
                        hint: '1.50',
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: const Icon(Icons.attach_money_outlined),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,4}'))
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required';
                          }
                          if ((double.tryParse(v.trim()) ?? 0) <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Total cost display
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Cost',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500)),
                      Text(
                        currency.format(_totalCost),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Odometer (${settings.odometerAbbr})',
                  hint: 'e.g. 50000',
                  controller: _odometerController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.speed_outlined),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Notes',
                  hint: 'Optional notes',
                  controller: _notesController,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                Consumer<FuelProvider>(
                  builder: (context, provider, _) => CustomButton(
                    text: 'Add Fuel Log',
                    isLoading: provider.isLoading,
                    onPressed: _submit,
                    icon: Icons.local_gas_station,
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
