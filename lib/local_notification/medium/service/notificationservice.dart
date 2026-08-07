import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static const int _scheduleId = 1;
  static const int _testId = 2;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notification.initialize(settings: initSettings);

    await _notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  static Future<void> showTestNotification(String activityText) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'weather_channel',
          'Umbrella Notifications',
          channelDescription: 'Nhắc nhở thời tiết hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_notification',
        );

    await _notification.show(
      id: _testId,
      title: 'Umbrella Reminder',
      body: activityText,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> scheduleUmbrella(
    double pop, {
    int hour = 17,
    int minute = 30,
  }) async {
    await _notification.cancel(id: _scheduleId);

    final android = _notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestExactAlarmsPermission();

    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    final now = tz.TZDateTime.now(location);

    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'weather_channel',
          'Umbrella Notifications',
          channelDescription: 'Nhắc nhở thời tiết hàng ngày',
          importance: Importance.max,
          priority: Priority.max,
        );

    await _notification.zonedSchedule(
      id: _scheduleId,
      title: '☔ Nhớ mang ô hôm nay!',
      body: 'Trong 12 giờ tới, dự đoán mưa lên đến ${pop * 100}%',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // lặp hàng ngày
    );
    //await NotificationService.showTestNotification('Test ?');
    // Debug
    final canExact = await android?.canScheduleExactNotifications();
    print('Can schedule exact: $canExact');
    final channels = await android?.getNotificationChannels();
    print('Channels: ${channels?.map((c) => c.id).toList()}');
    print('Scheduled: $scheduledDate');
    print('Còn: ${scheduledDate.difference(now).inMinutes} phút nữa');
  }

  static Future<void> cancelScheduleNotification() async {
    await _notification.cancel(id: _scheduleId);
  }
}
