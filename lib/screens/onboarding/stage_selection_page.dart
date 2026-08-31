import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:navajeev_m/screens/onboarding/postpartum_setup_page.dart';
import 'package:navajeev_m/screens/onboarding/pregnancy_setup_page.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_widgets/glass_container.dart';

class StageSelectionPage extends StatefulWidget {
  const StageSelectionPage({super.key});

  @override
  State<StageSelectionPage> createState() => _StageSelectionPageState();
}

class _StageSelectionPageState extends State<StageSelectionPage>
    with TickerProviderStateMixin {
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
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _bgShape1Animation =
        Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(0.1, 0.1),
        ).animate(
          CurvedAnimation(parent: _bgShape1Controller, curve: Curves.easeInOut),
        );

    _bgShape2Controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _bgShape2Animation =
        Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: const Offset(-0.1, -0.1),
        ).animate(
          CurvedAnimation(parent: _bgShape2Controller, curve: Curves.easeInOut),
        );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _contentController.forward();
  }

  @override
  void dispose() {
    _bgShape1Controller.dispose();
    _bgShape2Controller.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;
    final double cardMaxWidth = isWideScreen ? 500 : double.infinity;
    final double cardPaddingHorizontal = isWideScreen ? 40 : 24;
    final double cardPaddingVertical = isWideScreen ? 40 : 32;
    final double cardBorderRadius = 24.0;

    return Scaffold(
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

          Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardMaxWidth),
                    child: GlassContainer(
                      borderRadius: cardBorderRadius,
                      padding: EdgeInsets.symmetric(
                        horizontal: cardPaddingHorizontal,
                        vertical: cardPaddingVertical,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.family_restroom_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Welcome to Navajeev',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'To get started, please tell us where you are in your journey.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.black54, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          _buildSelectionCard(
                            context,
                            title: "I'm Pregnant",
                            subtitle: 'Track my pregnancy & baby growth',
                            icon: Icons.pregnant_woman,
                            color: AppColors.primaryAccent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const PregnancySetupPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildSelectionCard(
                            context,
                            title: 'Baby is Born',
                            subtitle: 'Track growth, vaccination & milestones',
                            icon: Icons.child_care,
                            color: const Color(0xFF59A2EC),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const PostpartumSetupPage(),
                                ),
                              );
                            },
                          ),
                        ],
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

  Widget _buildSelectionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryAccent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
