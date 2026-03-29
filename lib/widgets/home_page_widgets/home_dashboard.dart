import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment_model.dart';
import '../../providers/Sleep/sleep_providers.dart';
import '../../providers/feeding/feeding_provider.dart';
import '../../providers/growth/growth_provider.dart';
import '../../providers/wellbeing/wellbeing_provider.dart';
import '../../theme/app_colors.dart';
import '../../../services/auth_service.dart';
import 'package:navajeev_m/providers/vaccine_providers.dart';

import '../app_widgets/primary_card.dart';
import 'baby_info.dart';
import 'package:navajeev_m/widgets/home_page_widgets/quick_actions_section.dart';
import 'package:navajeev_m/widgets/home_page_widgets/today_summary_card.dart';
import 'package:navajeev_m/widgets/home_page_widgets/reminders_section.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    final isPregnancy = user?.isPregnancy ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: isPregnancy
          ? _buildPregnancyDashboard(context, user)
          : _buildPostpartumDashboard(context, user),
    );
  }

  // POSTPARTUM DASHBOARD

  Widget _buildPostpartumDashboard(
      BuildContext context,
      dynamic user,
      ) {
    final baby = user?.babyDetails;
    final babyId = user?.activeBabyId;
    final dob = baby?.dateOfBirth;

    final feedingProvider = context.watch<FeedingProvider>();
    final sleepProvider = context.watch<SleepProvider>();
    final growthProvider = context.watch<GrowthProvider>();
    final vaccineProvider = context.watch<VaccineProvider>();
    final wellbeingProvider = context.watch<WellbeingProvider>();
    final auth = context.watch<AuthService>();

    final todayFeedCount =
        feedingProvider.filteredFeedings.length;

    final todaySleepHours =
        sleepProvider.todayTotal.inMinutes / 60;

    final moodText = wellbeingProvider.todayEntry != null
        ? _mapMoodToText(
        wellbeingProvider.todayEntry!.mood)
        : "Not logged";

    final latestRecord =
        growthProvider.latestRecord;

    final weight = latestRecord != null
        ? "${latestRecord.weightKg} kg"
        : "--";

    final height = latestRecord != null
        ? "${latestRecord.lengthCm} cm"
        : "--";

    final head = latestRecord != null
        ? "${latestRecord.headCircumferenceCm} cm"
        : "--";

    final ageText = _calculateAgeText(baby);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 24),

        BabySummaryCard(
          babyName: baby?.name ?? "Baby",
          ageText: ageText,
          weight: weight,
          height: height,
          head: head,
          birthDate: baby != null
              ? "${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}"
              : "--",
        ),

        const SizedBox(height: 24),

        _buildDailyWisdom(context),

        const SizedBox(height: 24),

        QuickActionsSection(
          actions: [
            QuickActionItem(
              icon: Icons.restaurant,
              label: "Feeding",
              onTap: () => Navigator.pushNamed(context, '/feeding'),
            ),
            QuickActionItem(
              icon: Icons.bedtime,
              label: "Sleep",
              onTap: () => Navigator.pushNamed(context, '/sleep'),
            ),
            QuickActionItem(
              icon: Icons.show_chart,
              label: "Growth",
              onTap: () => Navigator.pushNamed(context, '/growth'),
            ),
            QuickActionItem(
              icon: Icons.favorite,
              label: "Wellbeing",
              onTap: () => Navigator.pushNamed(context, '/wellbeing'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        TodayOverviewCard(
          feeds: todayFeedCount,
          sleepHours: todaySleepHours,
          mood: moodText,
        ),

        const SizedBox(height: 24),

        if (babyId != null)
          StreamBuilder<List<Appointment>>(
            stream: auth.getAppointments(babyId),
            builder: (context, snapshot) {
              final appointments =
                  snapshot.data ?? [];

              final reminders = _buildReminders(
                appointments: appointments,
                nextVaccine:
                vaccineProvider.nextUpcomingVaccine,
                dob: dob,
              );

              return UpcomingRemindersSection(
                reminders: reminders,
              );
            },
          ),

        const SizedBox(height: 24),

        Center(
          child: Text(
            "You're doing amazing",
            style:
            Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  // PREGNANCY DASHBOARD

  Widget _buildPregnancyDashboard(
      BuildContext context,
      dynamic user,
      ) {

    final pregnancy = user?.pregnancyDetails;
    final wellbeingProvider =
    context.watch<WellbeingProvider>();
    final auth = context.watch<AuthService>();
    final babyId = user?.activeBabyId;
    final sleepProvider = context.watch<SleepProvider>();

    final todaySleepHours =
        sleepProvider.todayTotal.inMinutes / 60;

    final moodText =
    wellbeingProvider.todayEntry != null
        ? _mapMoodToText(
        wellbeingProvider.todayEntry!.mood)
        : "Not logged";

    final dueDate =
        pregnancy?.expectedDueDate;

    final week =
    _calculatePregnancyWeek(dueDate);

    final trimester =
    _getTrimester(week);

    final weeksLeft =
    dueDate != null
        ? dueDate.difference(DateTime.now()).inDays ~/ 7
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 24),

        /// Pregnancy Progress Card
        PrimaryCard(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              Text(
                "Pregnancy Progress",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  _progressItem(
                      "Week",
                      week != null
                          ? "$week / 40"
                          : "--"),

                  _progressItem(
                      "Trimester",
                      trimester ?? "--"),

                  _progressItem(
                      "Weeks Left",
                      weeksLeft != null
                          ? "$weeksLeft"
                          : "--"),
                ],
              ),

              const SizedBox(height: 12),

              if (dueDate != null)
                Text(
                  "Due Date: "
                      "${dueDate.day}/${dueDate.month}/${dueDate.year}",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildDailyWisdom(context),

        const SizedBox(height: 24),

        QuickActionsSection(
          actions: [
            QuickActionItem(
              icon: Icons.bedtime,
              label: "Sleep",
              onTap: () => Navigator.pushNamed(context, '/sleep'),
            ),
            QuickActionItem(
              icon: Icons.calendar_today,
              label: "Appointments",
              onTap: () => Navigator.pushNamed(context, '/appointments'),
            ),
            QuickActionItem(
              icon: Icons.favorite,
              label: "Wellbeing",
              onTap: () => Navigator.pushNamed(context, '/wellbeing'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        TodayOverviewCard(
          feeds: 0,
          sleepHours: todaySleepHours,
          mood: moodText,
        ),

        const SizedBox(height: 24),

        if (babyId != null)
          StreamBuilder<List<Appointment>>(
            stream: auth.getAppointments(babyId),
            builder: (context, snapshot) {

              final appointments =
                  snapshot.data ?? [];

              final reminders =
              _buildPregnancyReminders(
                appointments,
              );

              return UpcomingRemindersSection(
                reminders: reminders,
              );
            },
          ),

        const SizedBox(height: 24),

        Center(
          child: Text(
            "Take care of yourself",
            style:
            Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  // HELPERS

  static int? _calculatePregnancyWeek(
      DateTime? dueDate) {
    if (dueDate == null) return null;

    final now = DateTime.now();
    final totalWeeks = 40;

    final weeksLeft =
        dueDate.difference(now).inDays ~/ 7;

    return totalWeeks - weeksLeft;
  }

  static String? _getTrimester(int? week) {
    if (week == null) return null;

    if (week <= 13) {
      return "1st";
    } else if (week <= 27) {
      return "2nd";
    } else {
      return "3rd";
    }
  }

  static Widget _progressItem(
      String label,
      String value,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
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

  static Widget _buildDailyWisdom(
      BuildContext context) {
    return PrimaryCard(
      backgroundColor:
      AppColors.tipCardBackground
          .withValues(alpha: 0.7),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.tipIcon,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Wisdom',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Stay hydrated and prioritize rest.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }

  static String _calculateAgeText(baby) {
    if (baby == null) return "No baby";

    final now = DateTime.now();
    final days =
        now.difference(baby.dateOfBirth).inDays;

    final months = (days / 30).floor();
    final remainingDays = days % 30;

    return months > 0
        ? "$months months, $remainingDays days old"
        : "$days days old";
  }

  static List<Map<String, dynamic>> _buildReminders({
    required List<Appointment> appointments,
    required dynamic nextVaccine,
    required DateTime? dob,
  }) {
    final reminders =
    <Map<String, dynamic>>[];

    if (nextVaccine != null && dob != null) {
      reminders.add({
        "title": nextVaccine.name,
        "date": nextVaccine.getDueDate(dob),
        "type": "vaccine",
      });
    }

    for (final appt in appointments) {
      if (!appt.isCompleted &&
          appt.scheduledAt
              .isAfter(DateTime.now())) {
        reminders.add({
          "title": appt.doctorName,
          "date": appt.scheduledAt,
          "type": "checkup",
        });
      }
    }

    reminders.sort(
          (a, b) =>
          (a["date"] as DateTime)
              .compareTo(
              b["date"] as DateTime),
    );

    return reminders;
  }

  static List<Map<String, dynamic>>
  _buildPregnancyReminders(
      List<Appointment> appointments) {
    final reminders =
    <Map<String, dynamic>>[];

    for (final appt in appointments) {
      if (!appt.isCompleted &&
          appt.scheduledAt
              .isAfter(DateTime.now())) {
        reminders.add({
          "title": appt.doctorName,
          "date": appt.scheduledAt,
          "type": "checkup",
        });
      }
    }

    reminders.sort(
          (a, b) =>
          (a["date"] as DateTime)
              .compareTo(
              b["date"] as DateTime),
    );

    return reminders;
  }

  static String _mapMoodToText(int mood) {
    switch (mood) {
      case 1:
        return "Very Low";
      case 2:
        return "Low";
      case 3:
        return "Okay";
      case 4:
        return "Good";
      case 5:
        return "Great";
      default:
        return "Not logged";
    }
  }
}