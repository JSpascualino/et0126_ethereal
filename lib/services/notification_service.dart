import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings: initSettings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // Programa un recordatorio diario a la hora elegida
  Future<void> scheduleDailyHabitReminder({
    required String habitId,
    required String habitName,
    required TimeOfDay time,
  }) async {
    if (kIsWeb) return;
    await init();

    final int notificationId = habitId.hashCode.abs() % 100000;
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

    const androidDetails = AndroidNotificationDetails(
      'ethereal_habits_channel',
      'Recordatorios de Hábitos',
      channelDescription: 'Alertas diarias para mantener tu racha en Ethereal',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _notifications.zonedSchedule(
      id: notificationId,
      title: '✨ Hora de tu hábito en Ethereal',
      body: 'No olvides completar: $habitName',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancela el recordatorio si el hábito se elimina o llega a 120 días
  Future<void> cancelHabitReminder(String habitId) async {
    if (kIsWeb) return;
    await init();
    final int notificationId = habitId.hashCode.abs() % 100000;
    await _notifications.cancel(id: notificationId);
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}