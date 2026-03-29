import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/wellbeing/wellbeing_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/mood_config.dart';

class LatestEntriesSection extends StatelessWidget {
  final List<WellbeingEntry> entries;

  const LatestEntriesSection({
    super.key,
    required this.entries,
  });

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return "😢";
      case 2:
        return "😕";
      case 3:
        return "😐";
      case 4:
        return "😊";
      case 5:
        return "😍";
      default:
        return "😊";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = entries.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 30),

        const Text(
          "Recent Entries",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        ...latest.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 2,
              shadowColor: AppColors.softPinkShadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [

                    // Emoji
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MoodConfig.getBackgroundColor(entry.mood),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        MoodConfig.getIcon(entry.mood),
                        size: 20,
                        color: MoodConfig.getIconColor(entry.mood),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          Text(
                            DateFormat('MMM d, yyyy')
                                .format(entry.date),
                            style: const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Energy ${entry.energy}/5 · Stress ${entry.stress}/5 · Sleep ${entry.sleepQuality}/5",
                            style: const TextStyle(
                              fontSize: 13,
                              color:
                              AppColors.textSecondary,
                            ),
                          ),

                          if (entry.notes.isNotEmpty)
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 6),
                              child: Text(
                                "\"${entry.notes}\"",
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle:
                                  FontStyle.italic,
                                  color: AppColors
                                      .textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}