import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/fuel_log_model.dart';

class EditFuelScreen extends StatefulWidget {
  final FuelLogModel fuelLog;
  const EditFuelScreen({super.key, required this.fuelLog});

  @override
  State<EditFuelScreen> createState() => _EditFuelScreenState();
}

class _EditFuelScreenState extends State<EditFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _litersController;
  late final TextEditingController _priceController;
  late final TextEditingController _odometerController;
  late final TextEditingController _notesController;
  late String? _selectedVehicleId;
  late DateTime _selectedDate;

  double get _totalCost {
    final liters = double.tryParse(_litersController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return liters * price;
  }

  @override
  void initState() {
    super.initState();
    final log = widget.fuelLog;
    _litersController = TextEditingController(text: log.liters.toString());
    _priceController = TextEditingController(text: log.pricePerLiter.toString());
    _odometerController = TextEditingController(
        text: log.odometer != null ? log.odometer!.toString() : '');
    _notesController = TextEditingController(text: log.notes ?? '');
    _selectedVehicleId = log.vehicleId;
    _selectedDate = log.date;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vp = context.read<VehicleProvider>();
      if (vp.vehicles.isEmpty) vp.loadVehicles();
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

    final liters = double.parse(_litersController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final provider = context.read<FuelProvider>();
    final success = await provider.updateFuelLog(widget.fuelLog.id, {
      'vehicleId': int.parse(_selectedVehicleId!),
      'filledAt': _selectedDate.toIso8601String(),
      'litresFilled': liters,
      'pricePerLitre': price,
      'odometerReading': _odometerController.text.trim().isNotEmpty
          ? double.parse(_odometerController.text.trim())
          : 0.0,
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fuel log updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to update'),
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
      appBar: AppBar(title: const Text('Edit Fuel Log'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle selector
                Consumer<VehicleProvider>(
                  builder: (context, vp, _) {
                    if (vp.vehicles.isEmpty) return const SizedBox.shrink();
                    return DropdownButtonFormField<String>(
                      value: _selectedVehicleId,
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
                      items: vp.vehicles
                          .map((v) => DropdownMenuItem(
                              value: v.id,
                              child: Text(v.displayName)))
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
                        label: '${settings.volumeAbbr} *',
                        controller: _litersController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,3}'))
                        ],
                        prefixIcon: const Icon(Icons.water_drop_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if ((double.tryParse(v) ?? 0) <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: '${settings.currencySymbol}/${settings.volumeAbbr} *',
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,3}'))
                        ],
                        prefixIcon: const Icon(Icons.currency_rupee),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if ((double.tryParse(v) ?? 0) <= 0) {
                            return 'Must be > 0';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                if (_totalCost > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate_outlined,
                            color: Color(0xFFE65100), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Total: ${currency.format(_totalCost)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFE65100),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Odometer (${settings.odometerAbbr})',
                  controller: _odometerController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
                  ],
                  prefixIcon: const Icon(Icons.speed_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Notes',
                  controller: _notesController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                Consumer<FuelProvider>(
                  builder: (context, provider, _) => CustomButton(
                    text: 'Save Changes',
                    isLoading: provider.isLoading,
                    onPressed: _submit,
                    icon: Icons.save_outlined,
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
