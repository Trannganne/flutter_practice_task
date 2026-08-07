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
    // Tránh khởi tạo lại nhiều lần (đăng ký trùng listener) khi người dùng
    // quay lại module này nhiều lần trong 1 phiên.
    if (_isInitialized) return;

    // Khởi tạo timezone để hiển thị notification đúng giờ
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notification.initialize(settings: initSettings);

    // Xin quyền notification trên Android 13 trở lên
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
          'activity_channel',
          'Daily Activity Notifications',
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
      title: 'Activity Reminder',
      body: activityText,
      payload: null,
      notificationDetails: notificationDetails,
    );
  }

  // Schedule 8:00AM hằng ngày
  static Future<void> scheduleDailyAt8AM(String activityText) async {
    _notification.cancel(id: _scheduleId);

    final location = tz.getLocation('Asia/Ho_Chi_Minh');
    final now = tz.TZDateTime.now(location);

    // Tính thời điểm 8:00 tiếp theo
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      11,
      25,
      0,
    );

    // Nếu đã qua 8:00AM hôm nay, đặt lịch cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'activity_channel',
          'Daily Activity Notifications',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notification.zonedSchedule(
      id: _scheduleId,
      title: 'Activity Reminder',
      body: activityText,
      scheduledDate: scheduledDate,
      payload: null,
      notificationDetails: notificationDetails,
      // Lặp lại hằng ngày cùng giờ
      matchDateTimeComponents: DateTimeComponents
          .time, // Không quan trọng ngày/ tháng => cứ đúng 8 giờ là gửi thông báo thôi nhe
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // Cố gắng hiển thị đúng giờ nhất có thể
    );
    print("Đã lên lịch activity: ${scheduledDate.toString()}");
  }

  // Hủy lịch nhắc
  static Future<void> cancelScheduleNotification() async {
    _notification.cancel(id: _scheduleId);
  }
}
