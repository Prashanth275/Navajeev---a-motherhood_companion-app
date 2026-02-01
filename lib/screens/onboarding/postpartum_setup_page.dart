import 'package:flutter/material.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/theme/app_colors.dart';
import 'package:navajeev_m/routes.dart';
import 'package:intl/intl.dart';


class PostpartumSetupPage extends StatefulWidget {
  const PostpartumSetupPage({super.key});

  @override
  State<PostpartumSetupPage> createState() => _PostpartumSetupPageState();
}

class _PostpartumSetupPageState extends State<PostpartumSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _parentNameController = TextEditingController();
  final _babyNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _selectedDob;
  BabyGender _selectedGender = BabyGender.boy;
  String? _selectedDeliveryType;
  String? _selectedFeedingType;
  bool _isLoading = false;

  final List<String> _deliveryTypes = ['Vaginal', 'C-Section', 'Assisted'];
  final List<String> _feedingTypes = ['Breastfeeding', 'Formula', 'Mixed'];

  @override
  void dispose() {
    _parentNameController.dispose();
    _babyNameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 5),
      ), // Up to 5 years old?
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('MMMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
        name: _parentNameController.text.trim(),
        role: ParentRole
            .mother, // Default or add field if needed, request said "Parent name" but strict role isn't emphasized here like pregnancy
        stage: UserStage.postpartum,
        babyDetails: BabyDetails(
          name: _babyNameController.text.trim(),
          dateOfBirth: _selectedDob!,
          gender: _selectedGender,
          birthWeight: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null,
          birthHeight: _heightController.text.isNotEmpty
              ? double.tryParse(_heightController.text)
              : null,
          deliveryType: _selectedDeliveryType,
          feedingType: _selectedFeedingType,
        ),
      );

      await authService.saveProfile(user);
      await authService.seedVaccinationsIfNeeded();


      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Baby Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to the world!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Let’s set up your baby’s profile to track growth and milestones.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Parent Name
                TextFormField(
                  controller: _parentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Baby Name
                TextFormField(
                  controller: _babyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Baby Name',
                    prefixIcon: Icon(Icons.child_care),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Baby DOB
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  validator: (value) =>
                  _selectedDob == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Gender
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                        BabyGender.boy,
                        'Boy',
                        Icons.male,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderCard(
                        BabyGender.girl,
                        'Girl',
                        Icons.female,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Optional Birth Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skip for now if you don’t have this handy.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                // Weight & Height Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Birth Weight (kg)',
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Birth Height (cm)',
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Delivery Type & Feeding
                DropdownButtonFormField<String>(
                  initialValue: _selectedDeliveryType,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Type (Optional)',
                  ),
                  items: _deliveryTypes
                      .map(
                        (type) =>
                        DropdownMenuItem(value: type, child: Text(type)),
                  )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedDeliveryType = val),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: _selectedFeedingType,
                  decoration: const InputDecoration(
                    labelText: 'Feeding Preference (Optional)',
                  ),
                  items: _feedingTypes
                      .map(
                        (type) =>
                        DropdownMenuItem(value: type, child: Text(type)),
                  )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedFeedingType = val),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Start My Journey'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(BabyGender gender, String label, IconData icon) {
    bool isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryAccent : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryAccent : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
