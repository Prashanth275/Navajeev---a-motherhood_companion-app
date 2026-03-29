import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../app_widgets/primary_card.dart';

class TodayOverviewCard extends StatelessWidget {
  final int feeds;
  final double sleepHours;
  final String mood;

  const TodayOverviewCard({
    super.key,
    required this.feeds,
    required this.sleepHours,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Overview",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Item(icon: Icons.restaurant, value: "$feeds", label: "Feeds"),
              _Item(icon: Icons.bedtime, value: "${sleepHours.toStringAsFixed(1)}h", label: "Sleep"),
              _Item(icon: Icons.favorite, value: mood, label: "Mood"),
            ],
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Item({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}