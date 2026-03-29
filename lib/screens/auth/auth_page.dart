import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets/glass_text_field.dart';
import '../../widgets/app_widgets/glass_container.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _entryAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _bgAnimationController;
  late Animation<Offset> _bgShape1Animation;
  late Animation<Offset> _bgShape2Animation;

  @override
  void initState() {
    super.initState();

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entryAnimationController.forward();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Slow 25s loop
    )..repeat(reverse: true);

    _bgShape1Animation =
        Tween<Offset>(
          begin: const Offset(-0.2, -0.2),
          end: const Offset(0.2, 0.1),
        ).animate(
          CurvedAnimation(
            parent: _bgAnimationController,
            curve: Curves.easeInOutSine,
          ),
        );

    _bgShape2Animation =
        Tween<Offset>(
          begin: const Offset(0.2, 0.2),
          end: const Offset(-0.1, -0.2),
        ).animate(
          CurvedAnimation(
            parent: _bgAnimationController,
            curve: Curves.easeInOutSine,
          ),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _entryAnimationController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        if (isLogin) {
          await context.read<AuthService>().signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await context.read<AuthService>().signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    final outerPadding = isSmallScreen ? 24.0 : 24.0;
    final cardPaddingHorizontal = isSmallScreen ? 24.0 : 32.0;
    final cardPaddingVertical = isSmallScreen ? 24.0 : 40.0;

    final cardMaxWidth = isSmallScreen
        ? (size.width * 0.9).clamp(300.0, 400.0)
        : 400.0;

    final cardBorderRadius = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          ),

          SlideTransition(
            position: _bgShape1Animation,
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withValues(alpha: 0.08),
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

          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(outerPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: GlassContainer(
                          borderRadius: cardBorderRadius,
                          padding: EdgeInsets.symmetric(
                            horizontal: cardPaddingHorizontal,
                            vertical: cardPaddingVertical,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital_rounded,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  'Navajeev',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),

                                Text(
                                  'Your Health, Simplified',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                GlassTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  hintText: 'Email Address',
                                  icon: Icons.email_outlined,
                                  validator: Validators.email,
                                ),
                                const SizedBox(height: 16),

                                GlassTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  hintText: 'Password',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  toggleVisibility: _togglePasswordVisibility,
                                  isLast: isLogin,
                                  validator: Validators.password,
                                ),

                                if (!isLogin) ...[
                                  const SizedBox(height: 16),
                                  GlassTextField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocus,
                                    hintText: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    isLast: true,
                                    validator: (val) =>
                                        Validators.confirmPassword(
                                          val,
                                          _passwordController.text,
                                        ),
                                  ),
                                ],

                                if (isLogin) ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Feature coming soon!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: AppColors.primaryAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 24),
                                ],

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
                                        : Text(
                                      isLogin
                                          ? 'LOGIN'
                                          : 'CREATE ACCOUNT',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isLogin
                                          ? "Don't have an account? "
                                          : "Already have an account? ",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _isLoading
                                          ? null
                                          : _toggleAuthMode,
                                      child: Text(
                                        isLogin ? 'Register' : 'Login',
                                        style: const TextStyle(
                                          color: AppColors.primaryAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                          AppColors.primaryAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        ],
      ),
    );
  }
}
