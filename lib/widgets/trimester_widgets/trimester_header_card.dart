import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'animated_progress_bar.dart';

class TrimesterDynamicHeader extends StatelessWidget {
  final int currentWeek;

  const TrimesterDynamicHeader({
    super.key,
    required this.currentWeek,
  });

  int _getTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  LinearGradient _getGradient(int trimester) {
    switch (trimester) {
      case 1:
        return const LinearGradient(
          colors: [
            Color(0xFFFBA4DD), Color(0xFFFF7BDD)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [
            Color(0xFFFFCC80), Color(0xFFFFA726)
          ],//Color(0xFFFFD3B6),Color(0xFFFFB889),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [
            Color(0xFFCE93D8), Color(0xFFBA68C8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.brandGradient;
    }
  }

  Color _getProgressColor(int trimester) {
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

  Color _getGlowColor(int trimester) {
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
    final trimester = _getTrimester(currentWeek);
    final progress = currentWeek / 40;
    final gradient = _getGradient(trimester);
    final progressColor = _getProgressColor(trimester);
    final glowColor = _getGlowColor(trimester);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Week + Pill Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Week $currentWeek of 40",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Trimester $trimester",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          AnimatedTrimesterProgress(
            progress: progress,
            progressColor: progressColor,
          ),

          const SizedBox(height: 10),

          // Week Markers
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekMarker(label: "Week 1"),
              _WeekMarker(label: "Week 13"),
              _WeekMarker(label: "Week 27"),
              _WeekMarker(label: "Week 40"),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "${(progress * 100).toStringAsFixed(0)}% completed",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekMarker extends StatelessWidget {
  final String label;

  const _WeekMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );
  }
}