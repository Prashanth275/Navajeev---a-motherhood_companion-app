import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingRemindersSection extends StatelessWidget {
  final List<Map<String, dynamic>> reminders;

  const UpcomingRemindersSection({
    super.key,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Reminders",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        ...reminders.map(
              (r) => _ReminderTile(reminder: r),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Map<String, dynamic> reminder;

  const _ReminderTile({
    required this.reminder,
  });

  @override
  Widget build(BuildContext context) {
    final isVaccine = reminder["type"] == "vaccine";
    final DateTime date = reminder["date"] as DateTime;

    final bgColor = isVaccine
        ? const Color(0xFFFFF1EC)
        : const Color(0xFFEFF8F3);

    final iconColor = isVaccine
        ? Colors.orange
        : Colors.green;

    final badgeColor = isVaccine
        ? Colors.orange.shade100
        : Colors.green.shade100;

    final badgeText = isVaccine ? "Vaccine" : "Checkup";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVaccine
                  ? Icons.vaccines
                  : Icons.medical_information,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder["title"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat("MMM d, yyyy • h:mm a")
                      .format(date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}