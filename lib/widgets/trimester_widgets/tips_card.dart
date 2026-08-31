import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TipsCard extends StatelessWidget {
  final List<String> tips;
  final int weekNumber;
  final String? importantNote;

  const TipsCard({
    super.key,
    required this.tips,
    required this.weekNumber,
    this.importantNote,
  });

  int _getTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  Color _getTint(int trimester) {
    switch (trimester) {
      case 1:
        return const Color(0xFFFFF0F5);
      case 2:
        return const Color(0xFFFFF8E1);
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
              color: accent.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Tips for This Week",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: accent),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...tips.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${entry.key + 1}. ",
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style:
                        Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (importantNote != null &&
                importantNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        importantNote!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}