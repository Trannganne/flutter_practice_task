import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/notificationhistory.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/planner_history_cacheservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Thêm 2 hằng số ID cho action( hiển cùng heads up)
const String _actionIdDone = 'planner_done';
const String _actionIdSnooze = 'planner_snooze';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static const int _scheduleId = 1;
  static const int _testId = 2;
  static const int _snoozeId = 3;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Khởi tạo timezone để hiển thị notification đúng giờ
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notification.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    // Xin quyền notification trên Android 13 trở lên
    await _notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  static void _onResponse(NotificationResponse response) {
    _handleAction(response);
  }

  @pragma('vm:entry-point')
  static void _onBackgroundResponse(NotificationResponse response) async {
    WidgetsFlutterBinding.ensureInitialized();
    await _handleAction(response);
  }

  static Future<void> _handleAction(NotificationResponse response) async {
    print('=== TAP: id=${response.id}, actionId=${response.actionId} ===');
    final content = response.payload ?? '';

    switch (response.actionId) {
      case _actionIdDone:
        await _notification.cancel(id: response.id ?? _scheduleId);
        await PlannerHistoryCacheservice.savePlannerHistory(
          NotificationHistory(
            title: 'Đã hoàn thành',
            body: content,
            time: DateTime.now(),
            type: 'planner',
            status: 'done',
          ),
        );
        break;

      case _actionIdSnooze:
        await _notification.cancel(id: response.id ?? _scheduleId);
        await _scheduleSnooze(content);
        await PlannerHistoryCacheservice.savePlannerHistory(
          NotificationHistory(
            title: 'Đã hoãn 10 phút',
            body: content,
            time: DateTime.now(),
            type: 'planner',
            status: 'snoozed',
          ),
        );
        break;

      default:
        break; // Tap vào thân notification, không phải nút action
    }
  }

  static Future<void> showTestNotification(Forecast forecast) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'Weather_channel',
          'Umbrella Notifications',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notification.show(
      id: _testId,
      title: 'Umbrella Reminder',
      body:
          "12 giờ tới có xác suất mưa là ${forecast.maxRainProbabilityNext12h}%. Nhớ mang ô nhé!",
      payload: null,
      notificationDetails: notificationDetails,
    );
  }

  static NotificationDetails _plannerDetailsWithActions() {
    const androidDetails = AndroidNotificationDetails(
      'Planner_channel',
      'Umbrella Notifications',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',

      // Action cho nút bấm ở heads up
      actions: [
        AndroidNotificationAction(
          _actionIdDone,
          'Done',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          _actionIdSnooze,
          'Snooze 10m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );
    return const NotificationDetails(android: androidDetails);
  }

  // Schedule 8:00AM hằng ngày
  static Future<void> schedulePlanner(
    String content, {
    int hour = 11,
    int minute = 25,
  }) async {
    _notification.cancel(id: _scheduleId);
    final android = _notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.requestExactAlarmsPermission();

    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    final now = tz.TZDateTime.now(location);

    // Tính thời điểm tiếp theo
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    // Nếu đã qua thời gian hôm nay, đặt lịch cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final NotificationDetails notificationDetails =
        _plannerDetailsWithActions();

    await _notification.zonedSchedule(
      id: _scheduleId,
      title: 'Planner Reminder',
      body: content,
      scheduledDate: scheduledDate,
      payload: content,
      notificationDetails: notificationDetails,
      // Lặp lại hằng ngày cùng giờ
      matchDateTimeComponents: DateTimeComponents
          .time, // Không quan trọng ngày/ tháng => cứ đúng giờ là gửi thông báo thôi nhe
      androidScheduleMode: AndroidScheduleMode
          .inexactAllowWhileIdle, // Cố gắng hiển thị đúng giờ nhất có thể
    );
    final androidImplementation = _notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final canSchedule = await androidImplementation
        ?.canScheduleExactNotifications();

    print("Can schedule exact: $canSchedule");
    print("Đã lên lịch cho cả planner: ${scheduledDate.toString()}");
  }

  static Future<void> _scheduleSnooze(String content) async {
    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    final now = tz.TZDateTime.now(location);
    // Demo để 2 phút
    final snoozeDate = now.add(const Duration(minutes: 2));

    await _notification.zonedSchedule(
      id: _snoozeId,
      title: 'Planner Reminder (đã hoãn 10 phút)',
      body: content,
      scheduledDate: snoozeDate,
      payload: content,
      notificationDetails: _plannerDetailsWithActions(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Không set matchDateTimeComponents -> chỉ bắn 1 lần, khác với bản lặp hằng ngày
    );
  }

  // Hủy lịch nhắc
  static Future<void> cancelScheduleNotification() async {
    _notification.cancel(id: _scheduleId);
    _notification.cancel(id: _snoozeId);
  }
}
