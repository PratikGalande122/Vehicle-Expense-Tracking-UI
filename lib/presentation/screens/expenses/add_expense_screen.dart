import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/selected_vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../../../data/models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _placeController = TextEditingController();
  final _driverController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _selectedVehicleId;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

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
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _placeController.dispose();
    _driverController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  int _categoryToInt(String category) {
    switch (category) {
      case 'Fuel':        return 1;
      case 'Service':     return 2;
      case 'Insurance':   return 3;
      case 'Parking':     return 4;
      case 'Toll':        return 5;
      case 'Repair':      return 6;
      case 'Accessories': return 7;
      case 'Washing':     return 8;
      default:            return 9;
    }
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime get _combinedDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final provider = context.read<ExpenseProvider>();
    final success = await provider.addExpense({
      'vehicleId': int.parse(_selectedVehicleId!),
      'expenseType': _categoryToInt(_selectedCategory!),
      'description': _descriptionController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'expenseDate': _combinedDateTime.toIso8601String(),
      if (_placeController.text.trim().isNotEmpty)
        'place': _placeController.text.trim(),
      if (_driverController.text.trim().isNotEmpty)
        'driver': _driverController.text.trim(),
      if (_selectedPaymentMethod != null)
        'paymentMethod': _selectedPaymentMethod,
      if (_reasonController.text.trim().isNotEmpty)
        'reason': _reasonController.text.trim(),
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!'), behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add expense'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  InputDecoration _dec(String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.outline),
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final tf = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // â”€â”€ Vehicle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Consumer<VehicleProvider>(
                  builder: (context, vp, _) {
                    if (vp.isLoading && vp.vehicles.isEmpty) return const LoadingIndicator();
                    return DropdownButtonFormField<String>(
                      value: _selectedVehicleId,
                      decoration: _dec('Vehicle *', Icons.directions_car_outlined),
                      hint: const Text('Select a vehicle'),
                      items: vp.vehicles
                          .map((v) => DropdownMenuItem(value: v.id, child: Text(v.displayName)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedVehicleId = v),
                      validator: (v) => v == null ? 'Please select a vehicle' : null,
                    );
                  },
                ),
                const SizedBox(height: 14),
                // â”€â”€ Date + Time â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: _dec('Date *', Icons.calendar_today_outlined),
                          child: Text(df.format(_selectedDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: _dec('Time', Icons.access_time_outlined),
                          child: Text(tf),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // â”€â”€ Category â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _dec('Type of Expense *', Icons.category_outlined),
                  hint: const Text('Select category'),
                  items: ExpenseModel.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 14),
                // â”€â”€ Description â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                CustomTextField(
                  label: 'Description *',
                  hint: 'e.g. Oil change at ABC garage',
                  controller: _descriptionController,
                  prefixIcon: const Icon(Icons.description_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                // â”€â”€ Amount â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                CustomTextField(
                  label: 'Amount *',
                  hint: '150.00',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if ((double.tryParse(v.trim()) ?? 0) <= 0) return 'Amount must be > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                // â”€â”€ Place â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                CustomTextField(
                  label: 'Place',
                  hint: 'e.g. Andheri Service Centre',
                  controller: _placeController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                // â”€â”€ Driver â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                CustomTextField(
                  label: 'Driver',
                  hint: 'Driver name (optional)',
                  controller: _driverController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                // â”€â”€ Payment method â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    final methods = settings.paymentMethods;
                    return DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: _dec('Payment Method', Icons.credit_card_outlined),
                      hint: const Text('Select payment method'),
                      items: methods
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedPaymentMethod = v),
                    );
                  },
                ),
                const SizedBox(height: 14),
                // â”€â”€ Reason â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                CustomTextField(
                  label: 'Reason',
                  hint: 'Why was this expense incurred?',
                  controller: _reasonController,
                  prefixIcon: const Icon(Icons.help_outline),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                // â”€â”€ Notes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                CustomTextField(
                  label: 'Notes',
                  hint: 'Additional notes',
                  controller: _notesController,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                Consumer<ExpenseProvider>(
                  builder: (context, provider, _) => CustomButton(
                    text: 'Add Expense',
                    isLoading: provider.isLoading,
                    onPressed: _submit,
                    icon: Icons.receipt_long,
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

