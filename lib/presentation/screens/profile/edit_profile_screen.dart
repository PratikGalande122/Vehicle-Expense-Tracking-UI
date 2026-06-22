import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _selectedBloodGroup;

  static const _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  // Map display names to API enum ints (BloodGroup enum order)
  static const _bloodGroupInts = {
    'A+': 0, 'A-': 1, 'B+': 2, 'B-': 3,
    'AB+': 4, 'AB-': 5, 'O+': 6, 'O-': 7,
  };

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      helpText: 'Select Date of Birth',
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your blood group'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<UserProvider>();
    final success = await provider.updateProfile({
      if (_nameController.text.trim().isNotEmpty)
        'fullName': _nameController.text.trim(),
      'mobileNumber': _phoneController.text.trim(),
      'dateOfBirth': _dateOfBirth!.toIso8601String(),
      'bloodGroup': _bloodGroupInts[_selectedBloodGroup!],
      'emergencyContactName': _emergencyNameController.text.trim(),
      'emergencyContactNumber': _emergencyNumberController.text.trim(),
      'emergencyContactRelation': _emergencyRelationController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'address': _addressController.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to update profile'),
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
    final df = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Basic Info'),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                // Mobile Number (REQUIRED by API)
                CustomTextField(
                  label: 'Mobile Number *',
                  hint: '9876543210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().length < 7 || v.trim().length > 15) {
                      return '7â€“15 digits required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                // Date of Birth (REQUIRED)
                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _dropdownDecoration(
                        'Date of Birth *', Icons.cake_outlined),
                    child: Text(
                      _dateOfBirth != null
                          ? df.format(_dateOfBirth!)
                          : 'Select date of birth',
                      style: _dateOfBirth != null
                          ? null
                          : TextStyle(
                              color: Theme.of(context).hintColor),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Blood Group (REQUIRED)
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: _dropdownDecoration(
                      'Blood Group *', Icons.bloodtype_outlined),
                  hint: const Text('Select blood group'),
                  items: _bloodGroups
                      .map((g) =>
                          DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                  validator: (v) =>
                      v == null ? 'Please select blood group' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Address',
                  hint: '123 Main St, City',
                  controller: _addressController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                _sectionTitle('Emergency Contact (Required)'),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Contact Name *',
                  hint: 'Jane Doe',
                  controller: _emergencyNameController,
                  prefixIcon: const Icon(Icons.contact_emergency_outlined),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Contact Number *',
                  hint: '9876543210',
                  controller: _emergencyNumberController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_in_talk_outlined),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.trim().length < 7 || v.trim().length > 15) {
                      return '7â€“15 digits required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Relation *',
                  hint: 'Father, Spouse, Friend',
                  controller: _emergencyRelationController,
                  prefixIcon: const Icon(Icons.family_restroom_outlined),
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                Consumer<UserProvider>(
                  builder: (context, provider, _) => CustomButton(
                    text: 'Save Changes',
                    isLoading: provider.isLoading,
                    onPressed: _save,
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

  Widget _sectionTitle(String title) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}
