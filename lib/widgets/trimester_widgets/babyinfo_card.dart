import 'package:flutter/material.dart';
import '../../models/trimester/trimester_week_model.dart';
import '../../theme/app_colors.dart';

class BabyInfocard extends StatelessWidget {
  final TrimesterWeekModel data;

  const BabyInfocard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final trimester = _getTrimester(data.weekNumber);
    final tint = _getCardTint(trimester);
    final accent = _getAccent(trimester);

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.face_2_rounded,
                color: accent,
                size: 32,
              ),
            ),

            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Baby",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Size: ${data.babySizeCm.toStringAsFixed(1)} cm",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "About the size of a ${data.fruitName}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Trimester Helpers

  int _getTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  Color _getCardTint(int trimester) {
    switch (trimester) {
      case 1:
        return const Color(0xFFFCE4EC);
      case 2:
        return const Color(0xFFFFF3E0);
      case 3:
        return const Color(0xFFF3E5F5);
      default:
        return Colors.white;
    }
  }

  Color _getAccent(int trimester) {
    switch (trimester) {
      case 1:
        return Colors.pinkAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return AppColors.primaryAccent;
    }
  }
}