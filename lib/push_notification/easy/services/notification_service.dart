import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterpractisetasks/push_notification/easy/router/app_router.dart';

class NotificationService {
  // Singleton - chỉ có 1 instance duy nhất
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  //===================================

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Xin quyền
    await _requestPermission();
    await _getFCMToken();
    await _setupLocalNotifications();
    _setupMessageHandlers();

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    print('Initial message: $initialMessage');
    if (initialMessage != null) {
      print(initialMessage.data);
      _openPost(initialMessage);
    }

    _isInitialized = true;
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      sound: true,
      badge: true,
      criticalAlert: false,
      provisional: false,
      carPlay: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Quyền notification đã được cấp!');
    } else {
      print('Người dùng từ chối cấp notification!');
    }
  }

  static Future<void> _getFCMToken() async {
    String? token = await _messaging.getToken();
    print('FCM token: $token');

    // Lắng nghe khi token thay đổi
    _messaging.onTokenRefresh.listen((newToken) {
      print('Token mới: $newToken');
    });
  }

  // Cấu hình flutter_local_notifications
  static Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final id = response.payload;
        print("Tới đây rồi nheee");
        if (id != null) {
          AppRouter.router.push('/post/$id');
        }
      },
    );
  }

  // Lắng nghe message trong các trạng thái khác nhau
  static void _setupMessageHandlers() {
    // Foreground: app đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message); // Phải tự hiện vì FCM không tự hiện
    });

    // Opened app: user tap notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tap notification: ${message.notification?.title}');
      // TODO: điều hướng đến PostDetail
      final postId = int.parse(message.data['postId'] ?? '');
      if (postId != null) {
        _openPost(message);
      }
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'post_alert_channel',
          'Post Alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? "Bài đăng mới",
      body: message.notification?.body ?? 'Có bài đăng mới được thêm!',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: message.data['postId'],
    );
  }

  static void _openPost(RemoteMessage message) {
    final postId = int.parse(message.data['postId'] ?? '');
    if (postId == null) return;

    AppRouter.router.push('/post/$postId');
  }
}
