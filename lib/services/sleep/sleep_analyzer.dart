import '../../models/sleep/sleep_session.dart';

class SleepAnalyzer {
  static Map<DateTime, Duration> splitByDay(SleepSession session) {
    final Map<DateTime, Duration> result = {};

    DateTime currentStart = session.startTime;
    final end = session.endTime;

    while (currentStart.isBefore(end)) {
      final nextMidnight = DateTime(
        currentStart.year,
        currentStart.month,
        currentStart.day + 1,
      );

      final segmentEnd =
      end.isBefore(nextMidnight) ? end : nextMidnight;

      final dayKey = DateTime(
        currentStart.year,
        currentStart.month,
        currentStart.day,
      );

      final duration = segmentEnd.difference(currentStart);

      result.update(dayKey, (value) => value + duration,
          ifAbsent: () => duration);

      currentStart = segmentEnd;
    }

    return result;
  }
  static Duration getTodayTotal(List<SleepSession> sessions) {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    Duration total = Duration.zero;

    for (final session in sessions) {
      final split = splitByDay(session);
      if (split.containsKey(todayKey)) {
        total += split[todayKey]!;
      }
    }

    return total;
  }
  //TOTAL NIGHT
  static Duration getTodayNightTotal(List<SleepSession> sessions) {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    Duration total = Duration.zero;

    for (final session in sessions.where((s) => s.isNight)) {
      final split = splitByDay(session);
      if (split.containsKey(todayKey)) {
        total += split[todayKey]!;
      }
    }

    return total;
  }
  //TOTAL NAPS
  static int getTodayNapCount(List<SleepSession> sessions) {
    final today = DateTime.now();

    return sessions.where((s) {
      return !s.isNight &&
          s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day;
    }).length;
  }
  //WEEK DATA
  static List<double> getWeeklyHours(List<SleepSession> sessions) {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1

    final monday = DateTime(
      now.year,
      now.month,
      now.day - (weekday - 1),
    );

    final Map<DateTime, Duration> dailyTotals = {};

    for (final session in sessions) {
      final split = splitByDay(session);

      split.forEach((day, duration) {
        dailyTotals.update(day, (value) => value + duration,
            ifAbsent: () => duration);
      });
    }

    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      final key = DateTime(day.year, day.month, day.day);

      final duration = dailyTotals[key] ?? Duration.zero;

      return duration.inMinutes / 60.0;
    });
  }
  // MOTHER QUALITY
  static String getMotherQuality(Duration total) {
    final hours = total.inMinutes / 60.0;

    if (hours < 6) return "Poor";
    if (hours < 7) return "Fair";
    if (hours <= 9) return "Good";
    return "Excellent";
  }
  // BABY STATUS
  static String getBabyStatus({
    required Duration total,
    required int ageMonths,
  }) {
    final hours = total.inMinutes / 60.0;

    double min;
    double max;

    if (ageMonths <= 3) {
      min = 14; max = 17;
    } else if (ageMonths <= 11) {
      min = 12; max = 15;
    } else if (ageMonths <= 24) {
      min = 11; max = 14;
    } else {
      min = 10; max = 13;
    }

    if (hours < min) return "Needs More Rest";
    if (hours <= max) return "Good";
    return "Excellent";
  }
}