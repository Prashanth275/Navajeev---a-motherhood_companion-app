import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:navajeev_m/theme/app_colors.dart';
import 'package:navajeev_m/routes.dart';
import 'package:navajeev_m/widgets/app_widgets/glass_container.dart'; // Ensure correct path
import 'package:navajeev_m/widgets/app_widgets/glass_text_field.dart';
import 'package:provider/provider.dart';

class PostpartumSetupPage extends StatefulWidget {
  const PostpartumSetupPage({super.key});

  @override
  State<PostpartumSetupPage> createState() => _PostpartumSetupPageState();
}

class _PostpartumSetupPageState extends State<PostpartumSetupPage>
    with TickerProviderStateMixin {
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
    _parentNameController.dispose();
    _babyNameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bgShape1Controller.dispose();
    _bgShape2Controller.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 730)), // 2 years
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().savePostpartumProfile(
        parentName: _parentNameController.text.trim(),
        role: ParentRole.mother,
        baby: BabyDetails(
          name: _babyNameController.text.trim(),
          dateOfBirth: _selectedDob!,
          gender: _selectedGender,
          birthWeight: _weightController.text.trim().isNotEmpty
              ? double.tryParse(_weightController.text.trim())
              : null,
          birthHeight: _heightController.text.trim().isNotEmpty
              ? double.tryParse(_heightController.text.trim())
              : null,
          deliveryType: _selectedDeliveryType,
          feedingType: _selectedFeedingType,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Postpartum setup error: $e');
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
                              'Welcome to the world!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Let’s set up your baby’s profile to track growth and milestones.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Parent Name
                            GlassTextField(
                              controller: _parentNameController,
                              hintText: 'Parent Name',
                              icon: Icons.person_outline,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Baby Name
                            GlassTextField(
                              controller: _babyNameController,
                              hintText: 'Baby Name',
                              icon: Icons.child_care,
                              textCapitalization: TextCapitalization.words,
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Baby DOB
                            GlassTextField(
                              controller: _dobController,
                              hintText: 'Date of Birth',
                              icon: Icons.cake_outlined,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) =>
                              _selectedDob == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),

                            // Gender Selection
                            const Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
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
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Skip for now if you don’t have this handy.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Weight & Height Row
                            Row(
                              children: [
                                Expanded(
                                  child: GlassTextField(
                                    controller: _weightController,
                                    hintText: 'Weight (kg)',
                                    icon: Icons.monitor_weight_outlined,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GlassTextField(
                                    controller: _heightController,
                                    hintText: 'Height (cm)',
                                    icon: Icons.height,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildGlassDropdown(
                              value: _selectedDeliveryType,
                              hint: 'Delivery Type (Optional)',
                              items: _deliveryTypes,
                              onChanged: (val) =>
                                  setState(() => _selectedDeliveryType = val),
                            ),
                            const SizedBox(height: 16),

                            _buildGlassDropdown(
                              value: _selectedFeedingType,
                              hint: 'Feeding Preference (Optional)',
                              items: _feedingTypes,
                              onChanged: (val) =>
                                  setState(() => _selectedFeedingType = val),
                            ),

                            const SizedBox(height: 40),

                            SizedBox(
                              height: 50,
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
              ? AppColors.primaryAccent.withOpacity(0.9)
              : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.black54),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          dropdownColor: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}