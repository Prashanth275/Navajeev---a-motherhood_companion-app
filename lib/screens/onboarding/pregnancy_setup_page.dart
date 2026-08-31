import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/theme/app_colors.dart';
import 'package:navajeev_m/widgets/app_widgets/glass_container.dart';
import 'package:navajeev_m/widgets/app_widgets/glass_text_field.dart';
import 'package:provider/provider.dart';

class PregnancySetupPage extends StatefulWidget {
  const PregnancySetupPage({super.key});

  @override
  State<PregnancySetupPage> createState() => _PregnancySetupPageState();
}

class _PregnancySetupPageState extends State<PregnancySetupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _selectedDueDate;
  ParentRole _selectedRole = ParentRole.mother;
  bool _isLoading = false;

  late AnimationController _bgShape1Controller;
  late Animation<Offset> _bgShape1Animation;

  late AnimationController _bgShape2Controller;
  late Animation<Offset> _bgShape2Animation;

  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _bgShape1Controller = AnimationController(
        duration: const Duration(seconds: 4), vsync: this)..repeat(reverse: true);
    _bgShape1Animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.1, 0.1),
    ).animate(CurvedAnimation(
      parent: _bgShape1Controller,
      curve: Curves.easeInOut,
    ));

    _bgShape2Controller = AnimationController(
        duration: const Duration(seconds: 5), vsync: this)..repeat(reverse: true);
    _bgShape2Animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.1, -0.1),
    ).animate(CurvedAnimation(
      parent: _bgShape2Controller,
      curve: Curves.easeInOut,
    ));

    _contentController = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _contentController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dueDateController.dispose();
    _bgShape1Controller.dispose();
    _bgShape2Controller.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now().subtract(const Duration(days: 280)),
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDueDate == null) return;

    setState(() => _isLoading = true);

    try {
      final pregnancy = PregnancyDetails(
        expectedDueDate: _selectedDueDate!,
        enableNotifications: true,
      );

      await context.read<AuthService>().savePregnancyProfile(
        parentName: _nameController.text.trim(),
        role: _selectedRole,
        pregnancy: pregnancy,
      );

      if (!mounted) return;
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Pregnancy profile save failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;
    final double cardMaxWidth = isWideScreen ? 500 : double.infinity;
    final double cardPadding = isWideScreen ? 40 : 24;
    final double cardBorderRadius = 24.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
            ),
          ),

          SlideTransition(
            position: _bgShape1Animation,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),
          SlideTransition(
            position: _bgShape2Animation,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const ClampingScrollPhysics(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardMaxWidth),
                    child: GlassContainer(
                      borderRadius: cardBorderRadius,
                      padding: EdgeInsets.all(cardPadding),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Tell us a bit about you',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We use this to personalize your journey and daily tips.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            GlassTextField(
                              controller: _nameController,
                              hintText: 'Your Name',
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildGlassDropdown(
                              value: _selectedRole,
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

                            GlassTextField(
                              controller: _dueDateController,
                              hintText: 'Expected Due Date',
                              icon: Icons.calendar_today,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (_selectedDueDate == null) {
                                  return 'Please select your due date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Info Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
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
                                        color: Colors.black87,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 48),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  'START MY JOURNEY',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDropdown({
    required ParentRole value,
    required List<DropdownMenuItem<ParentRole>> items,
    required ValueChanged<ParentRole?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ParentRole>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          dropdownColor: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}