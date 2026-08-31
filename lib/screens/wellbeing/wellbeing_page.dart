import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/mood_config.dart';
import '../../widgets/wellbeing/latest_entries.dart';
import 'edit_mood.dart';
import '../../providers/wellbeing/wellbeing_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/wellbeing/weekly_trend_chart.dart';
import '../../widgets/wellbeing/wellbeing_summary_card.dart';

class WellbeingScreen extends StatelessWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WellbeingProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder(
        stream: provider.entriesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!;
          final today = entries.isNotEmpty ? entries.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CUSTOM HEADER
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 450;
                    final headerText = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Text(
                              "Mental Health",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text("💗", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Track your emotional wellbeing",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );

                    final logButton = ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.85),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditWellbeingScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Log Mood"),
                    );

                    return isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              headerText,
                              const SizedBox(height: 16),
                              logButton,
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: headerText),
                              const SizedBox(width: 16),
                              logButton,
                            ],
                          );
                  },
                ),

                const SizedBox(height: 32),

                // Today's Mood Card
                if (today != null)
                  _TodayMoodCard(entry: today)
                else
                  _EmptyMoodCard(),

                const SizedBox(height: 24),

                // Weekly Summary
                Row(
                  children: [
                    Expanded(
                      child: WellbeingSummaryCard(
                        title: "Avg Mood",
                        value: provider
                            .calculateWeeklyMoodAverage(entries)
                            .toStringAsFixed(1),
                        icon: Icons.emoji_emotions,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: WellbeingSummaryCard(
                        title: "Avg Stress",
                        value: provider
                            .calculateWeeklyStressAverage(entries)
                            .toStringAsFixed(1),
                        icon: Icons.favorite_border,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                WeeklyTrendChart(entries: entries),

                const SizedBox(height: 24),
                LatestEntriesSection(entries: entries),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TodayMoodCard extends StatelessWidget {
  final dynamic entry;

  const _TodayMoodCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MoodConfig.getBackgroundColor(entry.mood),
                shape: BoxShape.circle,
              ),
              child: Icon(
                MoodConfig.getIcon(entry.mood),
                size: 32,
                color: MoodConfig.getIconColor(entry.mood),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Mood: ${MoodConfig.getLabel(entry.mood)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Energy: ${entry.energy}/5 · Stress: ${entry.stress}/5",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (entry.notes.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "\"${entry.notes}\"",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
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
}

class _EmptyMoodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.sentiment_neutral, size: 28, color: AppColors.textMuted),
            SizedBox(width: 16),
            Text(
              "No mood logged today.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
