import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../theme/app_colors.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
      }
    });
  }


  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navColor = AppColors.brandGradient.colors.first;
    final scaffoldBg = AppColors.background;

    return CurvedNavigationBar(
      index: widget.currentIndex,
      height: 65.0,
      items: widget.items.asMap().entries.map((entry) {
        int idx = entry.key;
        Widget icon = entry.value.icon;

        if (idx == 2) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 28),
              child: icon,
            ),
          );
        }

        return IconTheme(
          data: const IconThemeData(color: Colors.white, size: 28),
          child: icon,
        );
      }).toList(),
      color: navColor,
      buttonBackgroundColor: navColor,
      backgroundColor: scaffoldBg,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 400),
      onTap: widget.onTap,
    );
  }
}
