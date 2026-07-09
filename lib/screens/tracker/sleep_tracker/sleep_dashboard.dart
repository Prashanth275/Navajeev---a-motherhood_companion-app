import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/sleep/sleep_session.dart';
import '../../../providers/Sleep/sleep_providers.dart';
import '../../../providers/ai_insight_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/sleep_widgets/weekly_sleep_chart.dart';
import '../../../widgets/ai_insight_card.dart';
import 'sleep_log_screen.dart';

class SleepDashboard extends StatefulWidget {
  const SleepDashboard({super.key});

  @override
  State<SleepDashboard> createState() => _SleepDashboardState();
}

class _SleepDashboardState extends State<SleepDashboard> {

  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sleepProvider = context.read<SleepProvider>();
      final aiProvider = context.read<AiInsightProvider>();

      final subject = sleepProvider.isMotherSelected ? 'mother' : 'baby';

      final existing =
      aiProvider.getResult(userId, 'sleep', subject);

      if (existing == null) {
        _fetchInsight();
      }
    });
  }

  void _fetchInsight({bool forceRefresh = false}) {
    final sleepProvider = context.read<SleepProvider>();
    final aiProvider = context.read<AiInsightProvider>();

    // 🔥 Prevent race condition
    if (sleepProvider.isLoading) return;

    final allSessions = sleepProvider.sessions;
    final isMother = sleepProvider.isMotherSelected;

    final sessions = _getValidSessions(allSessions, isMother);

    if (sessions.isEmpty) return;

    final Map<String, double> dailySleep = {};

    for (final session in sessions) {
      DateTime start = session.startTime;
      DateTime end = session.endTime;

      while (start.isBefore(end)) {
        final nextMidnight = DateTime(
          start.year,
          start.month,
          start.day + 1,
        );

        final segmentEnd =
        end.isBefore(nextMidnight) ? end : nextMidnight;

        final duration =
            segmentEnd.difference(start).inMinutes / 60.0;

        final key =
            "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";

        dailySleep[key] = (dailySleep[key] ?? 0) + duration;

        start = segmentEnd;
      }
    }
    final sleepLogs = dailySleep.entries.map((e) {
      return {
        'date': e.key,
        'total_hours': e.value,
        'night_wakings': 0,
      };
    }).toList();

    sleepLogs.sort((a, b) {
      final dateA = a['date'] as String? ?? '';
      final dateB = b['date'] as String? ?? '';
      return dateB.compareTo(dateA);
    });

    final limitedLogs = sleepLogs.take(5).toList();
    if (limitedLogs.length < 2) return;

    //DEBUG (optional)
     debugPrint("Sleep Logs Sent to AI:");
     debugPrint(sleepLogs.toString());

    final subject = isMother ? 'mother' : 'baby';
    final babyAgeWeeks = sleepProvider.babyAgeWeeks;

    aiProvider.fetchInsight(
      userId: userId,
      module: 'sleep',
      subject: subject,
      babyAgeWeeks: !isMother && babyAgeWeeks > 0 ? babyAgeWeeks : null,
      data: {
        'sleep_logs': limitedLogs,
        'context': isMother
            ? 'These are the mother\'s sleep logs. Analyse for postnatal sleep recovery, sleep quality, and rest adequacy for a new mother.'
            : 'These are the baby\'s sleep logs. Analyse against WHO infant sleep norms for the baby\'s age.',
      },
      forceRefresh: forceRefresh,
    );
  }

  List<SleepSession> _getValidSessions(
      List<SleepSession> allSessions,
      bool isMother,
      ) {
    final now = DateTime.now();

    return allSessions.where((s) {
      final sessionDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );

      final isRecent = now.difference(sessionDate).inDays <= 5;

      final isValid = s.startTime != null && s.endTime != null;

      return isRecent && isValid;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final subject = provider.isMotherSelected ? 'mother' : 'baby';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),

              if (!provider.isPregnancyMode)
                _buildModeToggle(provider, context),

              if (!provider.isPregnancyMode)
                const SizedBox(height: 20),

              _buildSummaryCards(context, provider),
              const SizedBox(height: 24),

              _buildWeeklySection(context, provider),
              const SizedBox(height: 8),

              Consumer<AiInsightProvider>(
                builder: (context, aiProvider, _) => AiInsightCard(
                  module: 'sleep',
                  isLoading: aiProvider.isLoading(userId, 'sleep', subject),
                  result: aiProvider.getResult(userId, 'sleep', subject),
                  onRefresh: () => _fetchInsight(forceRefresh: true),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SleepLogScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Log Sleep"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sleep,
                foregroundColor: Colors.white,
                elevation: 4,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Monitor sleep patterns and quality",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildModeToggle(SleepProvider provider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          _buildToggleItem(
            title: "Mother",
            selected: provider.isMotherSelected,
            onTap: () {
              context.read<AiInsightProvider>().clearModule(userId, 'sleep');
              provider.toggleMode(true);
              WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInsight(forceRefresh: true));
            },
          ),
          _buildToggleItem(
            title: "Baby",
            selected: !provider.isMotherSelected,
            onTap: () {
              context.read<AiInsightProvider>().clearModule(userId, 'sleep');
              provider.toggleMode(false);
              WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInsight(forceRefresh: true));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.sleep : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, SleepProvider provider) {
    final bool isMother = provider.isMotherSelected;

    final cards = isMother
        ? [
            _buildCard(
              context,
              icon: Icons.access_time,
              title: "Total",
              value: _formatDuration(provider.todayTotal),
              subtitle: "${provider.statusOrQuality} quality",
            ),
            _buildCard(
              context,
              icon: Icons.nightlight_round,
              title: "Night",
              value: _formatDuration(provider.todayNight),
              subtitle: "Last 24 hours",
            ),
            _buildCard(
              context,
              icon: Icons.wb_sunny,
              title: "Naps",
              value: provider.todayNaps.toString(),
              subtitle: "Last 24 hours",
            ),
          ]
        : [
            _buildCard(
              context,
              icon: Icons.access_time,
              title: "Total",
              value: _formatDuration(provider.todayTotal),
            ),
            _buildCard(
              context,
              icon: Icons.wb_sunny,
              title: "Naps",
              value: provider.todayNaps.toString(),
            ),
            _buildCard(
              context,
              icon: Icons.emoji_emotions_outlined,
              title: "Status",
              value: provider.statusOrQuality,
            ),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;

        return isNarrow
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: cards.map((card) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 120,
                      child: card,
                    ),
                  )).toList(),
                ),
              )
            : Row(
                children: cards.map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: card,
                  ),
                )).toList(),
              );
      },
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
        required String title,
        required String value,
        String? subtitle}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.sleep.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.sleep),
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.sleep, fontSize: 18),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getQualityColor(subtitle),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySection(
      BuildContext context, SleepProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This Week",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            WeeklySleepChart(weeklyHours: provider.weeklyHours),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
  }

  Color _getQualityColor(String text) {
    if (text.contains("Poor")) return Colors.red;
    if (text.contains("Fair")) return Colors.amber;
    if (text.contains("Good")) return Colors.green;
    if (text.contains("Excellent")) return Colors.blue;
    return AppColors.textSecondary;
  }
}