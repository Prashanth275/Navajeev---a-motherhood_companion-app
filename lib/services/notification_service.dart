import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/vaccine_model.dart';

class NotificationService {
  static final NotificationService _instance =
  NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ─────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      macOS: iosInit,
    );

    await _plugin.initialize(settings: initSettings);

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.requestNotificationsPermission();
  }

  // ─────────────────────────────────────────
  // Schedule vaccine reminders
  // ─────────────────────────────────────────
  Future<void> scheduleVaccineReminders({
    required Vaccine vaccine,
    required DateTime babyDob,
  }) async {
    final status = vaccine.getStatus(babyDob);

    if (status == VaccineStatus.done) return;

    final dueDate = vaccine.getDueDate(babyDob);
    final baseId = _baseId(vaccine.id);

    await cancelReminders(vaccine);

    // 7 days before
    await _scheduleIfFuture(
      id: baseId + 1,
      title: 'Upcoming Vaccination',
      body: '${vaccine.name} is due in 7 days',
      dateTime: dueDate.subtract(const Duration(days: 7)),
    );

    // 1 day before
    await _scheduleIfFuture(
      id: baseId + 2,
      title: 'Vaccination Tomorrow',
      body: '${vaccine.name} is due tomorrow',
      dateTime: dueDate.subtract(const Duration(days: 1)),
    );

    // Due day morning
    await _scheduleIfFuture(
      id: baseId + 3,
      title: 'Vaccination Due Today',
      body: 'Today is the day for ${vaccine.name}',
      dateTime: DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        8,
      ),
    );
  }

  // ─────────────────────────────────────────
  // Cancel reminders
  // ─────────────────────────────────────────
  Future<void> cancelReminders(Vaccine vaccine) async {
    final baseId = _baseId(vaccine.id);
    await _plugin.cancel(id: baseId + 1);
    await _plugin.cancel(id: baseId + 2);
    await _plugin.cancel(id: baseId + 3);
  }

  // ─────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────
  int _baseId(String id) =>
      id.codeUnits.fold(0, (a, b) => a + b);

  Future<void> _scheduleIfFuture({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id, // Fixed: Named parameter
      title: title, // Fixed: Named parameter
      body: body, // Fixed: Named parameter
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local), // Fixed: Named parameter
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccination_channel',
          'Vaccination Reminders',
          channelDescription: 'Reminders for child vaccinations',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Fixed: Removed uiLocalNotificationDateInterpretation
    );
  }
}