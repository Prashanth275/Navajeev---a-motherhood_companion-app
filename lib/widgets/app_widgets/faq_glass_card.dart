import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FaqGlassCard extends StatelessWidget {
  final String question;
  final VoidCallback? onTap;
  final bool isBusy;

  const FaqGlassCard({
    super.key,
    required this.question,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isBusy ? null : onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.primaryAccent.withValues(alpha: 0.12),
              highlightColor: AppColors.primaryAccent.withValues(alpha: 0.06),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.75),
                      const Color(0xFFFFF0F5).withValues(alpha: 0.55),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isBusy ? AppColors.textMuted : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
