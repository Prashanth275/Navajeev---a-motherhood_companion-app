import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../app_widgets/primary_card.dart';

class BabySummaryCard extends StatelessWidget {
  final String babyName;
  final String ageText;
  final String weight;
  final String height;
  final String head;
  final String birthDate;

  const BabySummaryCard({
    super.key,
    required this.babyName,
    required this.ageText,
    required this.weight,
    required this.height,
    required this.head,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.child_care,
                  color: AppColors.primaryAccent,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    babyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ageText,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricChip(
                value: weight,
                label: "Weight",
                bgColor: Colors.green.withValues(alpha: 0.1),
                textColor: Colors.green,
              ),
              _MetricChip(
                value: height,
                label: "Height",
                bgColor: Colors.orange.withValues(alpha: 0.1),
                textColor: Colors.orange,
              ),
              _MetricChip(
                value: head,
                label: "Head",
                bgColor: Colors.purple.withValues(alpha: 0.1),
                textColor: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.cake, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Born on $birthDate",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String value;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _MetricChip({
    required this.value,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}