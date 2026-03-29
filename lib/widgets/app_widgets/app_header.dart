import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppHeader extends StatelessWidget
    implements PreferredSizeWidget {

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final LinearGradient? gradient;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.brandGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),

              if (actions != null)
                Row(children: actions!),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle != null ? 80 : 60);
}