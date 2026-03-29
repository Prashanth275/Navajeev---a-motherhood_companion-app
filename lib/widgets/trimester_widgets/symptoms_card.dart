import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SymptomsCard extends StatelessWidget {
  final List<String> symptoms;
  final int weekNumber;

  const SymptomsCard({
    super.key,
    required this.symptoms,
    required this.weekNumber,
  });

  int _getTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  Color _getTint(int trimester) {
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

  @override
  Widget build(BuildContext context) {
    final trimester = _getTrimester(weekNumber);
    final tint = _getTint(trimester);
    final accent = _getAccent(trimester);

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "What You May Experience",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: accent),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Symptoms List
            ...symptoms.map(
                  (symptom) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Dot
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        symptom,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}