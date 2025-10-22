import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  /// Called when a notification is tapped
  static void onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      onClickNotification.add(response.payload!);
    }
  }

  /// Initialize notifications
  static Future init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    tz.initializeTimeZones();

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  /// Show a simple notification
  static Future showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_simple',
        'Simple Notifications',
        channelDescription: 'Simple notifications channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(0, title, body, details, payload: payload);
  }

  /// Show periodic notification
  static Future showPeriodicNotification({
    required String title,
    required String body,
    required String payload,
    bool exact = false,
    RepeatInterval interval = RepeatInterval.everyMinute,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_periodic',
        'Periodic Notifications',
        channelDescription: 'Periodic notifications channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexact;

    if (exact && Platform.isAndroid) {
      final intent = AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
      await intent.launch();
      scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    }

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      1,
      title,
      body,
      interval,
      details,
      androidScheduleMode: scheduleMode,
      payload: payload,
    );
  }

  /// Schedule a one-time notification
  static Future showScheduledNotification({
    required String title,
    required String body,
    required String payload,
    bool exact = false,
    Duration delay = const Duration(seconds: 5),
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_scheduled',
        'Scheduled Notifications',
        channelDescription: 'Scheduled notifications channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
    AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexact;

    if (exact && Platform.isAndroid) {
      final intent = AndroidIntent(action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM');
      await intent.launch();
      scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: scheduleMode,
      payload: payload,
    );
  }

  /// Cancel a notification
  static Future cancel(int id) async => _flutterLocalNotificationsPlugin.cancel(id);

  /// Cancel all notifications
  static Future cancelAll() async => _flutterLocalNotificationsPlugin.cancelAll();
}
