import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/Sleep/sleep_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_widgets/page_container.dart';
import '../../../widgets/sleep_widgets/weekly_sleep_chart.dart';
import 'sleep_log_screen.dart';

class SleepDashboard extends StatelessWidget {
  const SleepDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),

              if (!provider.isPregnancyMode)
                _buildModeToggle(provider),

              if (!provider.isPregnancyMode)
                const SizedBox(height: 20),

              _buildSummaryCards(context, provider),
              const SizedBox(height: 24),

              _buildWeeklySection(context, provider),
            ],
          ),
        );

      },
    );
  }

  bool _shouldShowToggle(SleepProvider provider) {
    return !provider.isPregnancyMode;
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
                  MaterialPageRoute(
                    builder: (_) => const SleepLogScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Log Sleep"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sleep,
                foregroundColor: Colors.white,
                elevation: 4,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
  Widget _buildModeToggle(SleepProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            title: "Mother",
            selected: provider.isMotherSelected,
            onTap: () => provider.toggleMode(true),
          ),
          _buildToggleItem(
            title: "Baby",
            selected: !provider.isMotherSelected,
            onTap: () => provider.toggleMode(false),
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
  // summary cards
  Widget _buildSummaryCards(
      BuildContext context,
      SleepProvider provider,
      ) {
    if (provider.isMotherSelected) {
      //Mother Layout
      return Row(
        children: [
          _buildCard(
            context,
            icon: Icons.access_time,
            title: "Total",
            value: _formatDuration(provider.todayTotal),
            subtitle: "${provider.statusOrQuality} quality",
          ),
          const SizedBox(width: 12),
          _buildCard(
            context,
            icon: Icons.nightlight_round,
            title: "Night",
            value: _formatDuration(provider.todayNight),
            subtitle: "Last 24 hours"
          ),
          const SizedBox(width: 12),
          _buildCard(
            context,
            icon: Icons.wb_sunny,
            title: "Naps",
            value: provider.todayNaps.toString(),
            subtitle: "Last 24 hours"
          ),
        ],
      );
    } else {
      // Baby Layout
      return Row(
        children: [
          _buildCard(
            context,
            icon: Icons.access_time,
            title: "Total",
            value: _formatDuration(provider.todayTotal),
          ),
          const SizedBox(width: 12),
          _buildCard(
            context,
            icon: Icons.wb_sunny,
            title: "Naps",
            value: provider.todayNaps.toString(),
          ),
          const SizedBox(width: 12),
          _buildCard(
            context,
            icon: Icons.emoji_emotions_outlined,
            title: "Status",
            value: provider.statusOrQuality,
          ),
        ],
      );
    }
  }
  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        String? subtitle,
      }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.sleep.withOpacity(0.1),
                child: Icon(icon, color: AppColors.sleep),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  color: AppColors.sleep,
                  fontSize: 18,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: _getQualityColor(subtitle),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildWeeklySection(
      BuildContext context,
      SleepProvider provider,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This Week",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            WeeklySleepChart(
              weeklyHours: provider.weeklyHours,
            ),
          ],
        ),
      ),
    );
  }
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return "${hours}h ${minutes}m";
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case "Needs More Rest":
        return Colors.red;
      case "Good":
        return Colors.green;
      case "Excellent":
        return Colors.teal;
      default:
        return AppColors.sleep;
    }
  }

  Color _getQualityColor(String text) {
    if (text.contains("Poor")) return Colors.red;
    if (text.contains("Fair")) return Colors.amber;
    if (text.contains("Good")) return Colors.green;
    if (text.contains("Excellent")) return Colors.blue;
    return AppColors.textSecondary;
  }
}