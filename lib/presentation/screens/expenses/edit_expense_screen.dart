import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../data/models/expense_model.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _placeController;
  late final TextEditingController _driverController;
  late final TextEditingController _reasonController;
  late final TextEditingController _notesController;
  late String? _selectedVehicleId;
  late String? _selectedCategory;
  late String? _selectedPaymentMethod;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

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

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _descriptionController = TextEditingController(text: e.description);
    _amountController = TextEditingController(text: e.amount.toStringAsFixed(2));
    _placeController = TextEditingController(text: e.place ?? '');
    _driverController = TextEditingController(text: e.driver ?? '');
    _reasonController = TextEditingController(text: e.reason ?? '');
    _notesController = TextEditingController(text: e.notes ?? '');
    _selectedVehicleId = e.vehicleId;
    _selectedCategory = e.category;
    _selectedPaymentMethod = e.paymentMethod;
    _selectedDate = e.date;
    _selectedTime = TimeOfDay(hour: e.date.hour, minute: e.date.minute);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vp = context.read<VehicleProvider>();
      if (vp.vehicles.isEmpty) vp.loadVehicles();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _placeController.dispose();
    _driverController.dispose();
    _reasonController.dispose();
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime get _combinedDateTime => DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      );

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVehicleId == null || _selectedCategory == null) return;

    final provider = context.read<ExpenseProvider>();
    final success = await provider.updateExpense(widget.expense.id, {
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
        const SnackBar(content: Text('Expense updated!'), behavior: SnackBarBehavior.floating),
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
    final df = DateFormat('dd/MM/yyyy');
    final tf = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<VehicleProvider>(
                  builder: (context, vp, _) {
                    if (vp.vehicles.isEmpty) return const SizedBox.shrink();
                    return DropdownButtonFormField<String>(
                      value: _selectedVehicleId,
                      decoration: _dec('Vehicle *', Icons.directions_car_outlined),
                      items: vp.vehicles
                          .map((v) => DropdownMenuItem(value: v.id, child: Text(v.displayName)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedVehicleId = v),
                      validator: (v) => v == null ? 'Please select a vehicle' : null,
                    );
                  },
                ),
                const SizedBox(height: 14),
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
                DropdownButtonFormField<String>(
                  value: ExpenseModel.categories.contains(_selectedCategory)
                      ? _selectedCategory
                      : null,
                  decoration: _dec('Type of Expense *', Icons.category_outlined),
                  hint: const Text('Select category'),
                  items: ExpenseModel.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Description *',
                  controller: _descriptionController,
                  prefixIcon: const Icon(Icons.description_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Amount *',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if ((double.tryParse(v.trim()) ?? 0) <= 0) return 'Must be > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Place',
                  controller: _placeController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Driver',
                  controller: _driverController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    final methods = settings.paymentMethods;
                    final validValue = methods.contains(_selectedPaymentMethod)
                        ? _selectedPaymentMethod
                        : null;
                    return DropdownButtonFormField<String>(
                      value: validValue,
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
                CustomTextField(
                  label: 'Reason',
                  controller: _reasonController,
                  prefixIcon: const Icon(Icons.help_outline),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Notes',
                  controller: _notesController,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                Consumer<ExpenseProvider>(
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

