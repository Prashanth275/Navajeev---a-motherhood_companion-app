import 'package:flutter/material.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/theme/app_colors.dart';
import 'package:navajeev_m/routes.dart';
import 'package:intl/intl.dart';

class PregnancySetupPage extends StatefulWidget {
  const PregnancySetupPage({super.key});

  @override
  State<PregnancySetupPage> createState() => _PregnancySetupPageState();
}

class _PregnancySetupPageState extends State<PregnancySetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _selectedDueDate;
  ParentRole _selectedRole = ParentRole.mother;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now().subtract(
        const Duration(days: 280),
      ), // Allowed to be late?
      lastDate: DateTime.now().add(const Duration(days: 300)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primaryAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = DateFormat('MMMM d, yyyy').format(picked);
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
        name: _nameController.text.trim(),
        role: _selectedRole,
        stage: UserStage.pregnancy,
        pregnancyDetails: PregnancyDetails(expectedDueDate: _selectedDueDate!),
      );

      await authService.saveProfile(user);

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
        title: const Text('Pregnancy Profile'),
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
                  'Tell us a bit about you',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'We use this to personalize your journey and daily tips.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'e.g. Sarah',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Role Dropdown
                DropdownButtonFormField<ParentRole>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'I am the...',
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  items: ParentRole.values.map((role) {
                    String label;
                    switch (role) {
                      case ParentRole.mother:
                        label = 'Mother';
                        break;
                      case ParentRole.partner:
                        label = 'Partner / Dad';
                        break;
                      case ParentRole.caregiver:
                        label = 'Caregiver';
                        break;
                    }
                    return DropdownMenuItem(value: role, child: Text(label));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Due Date Picker
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Expected Due Date',
                    hintText: 'Select date',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  validator: (value) {
                    if (_selectedDueDate == null) {
                      return 'Please select your due date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tipCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Don\'t worry if you\'re not sure, you can update this later in settings.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

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
}
