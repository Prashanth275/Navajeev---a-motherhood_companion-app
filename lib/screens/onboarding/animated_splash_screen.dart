import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../wrapper.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Orbiting phase
  late Animation<double> _rotation;
  late Animation<double> _radius;
  late Animation<double> _orbitOpacity;
  
  // Logo reveal
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  
  // Background ripple animation
  late Animation<double> _rippleScale;
  
  // Text reveal
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _rotation = Tween<double>(begin: 0.0, end: 3.0 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeInOutCubic),
      ),
    );

    _radius = Tween<double>(begin: 75.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.60, curve: Curves.easeInBack),
      ),
    );

    _orbitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.53, 0.60, curve: Curves.easeOut),
      ),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.76, curve: Curves.easeOutBack),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.72, curve: Curves.easeIn),
    );

    _rippleScale = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.94, curve: Curves.easeInOutCubic),
      ),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.76, 0.95, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Wrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOrbitingIcon(IconData icon, Color color) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: AppColors.primaryAccent,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> orbitingItems = [
      Icons.child_care_rounded,
      Icons.medical_services_rounded,
      Icons.smart_toy_rounded,
      Icons.favorite_rounded,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double currentRotation = _rotation.value;
          final double currentRadius = _radius.value;
          final double currentOrbitOpacity = _orbitOpacity.value;

          return Stack(
            children: [
              Center(
                child: ScaleTransition(
                  scale: _rippleScale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (currentOrbitOpacity > 0.0)
                Center(
                  child: Opacity(
                    opacity: currentOrbitOpacity,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: List.generate(4, (index) {
                          final double angle = currentRotation + (index * math.pi / 2.0);
                          final double x = currentRadius * math.cos(angle);
                          final double y = currentRadius * math.sin(angle);

                          final icon = orbitingItems[index];

                          return Transform.translate(
                            offset: Offset(x, y),
                            child: _buildOrbitingIcon(
                              icon,
                              AppColors.primaryAccent,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),

              Center(
                child: FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.primaryAccent.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            children: [
                              const Text(
                                'Navajeev',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryAccent,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your Motherhood Companion',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Watermark tag at bottom
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Text(
                      'Nurturing New Beginnings',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
