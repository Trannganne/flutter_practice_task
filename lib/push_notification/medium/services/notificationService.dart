import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
import 'package:flutterpractisetasks/push_notification/medium/router/approute.dart';

class NotificationService {
  // Singleton - chỉ có 1 instance duy nhất
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Tạo một callback để thông báo cho bên ngoài biết khi có tin nhắn Foreground về

  static Function(RemoteMessage)? onForegroundMessageReceived;
  static bool _isInitialized = false;
  //===================================

  static Future<void> initialize() async {
    if (_isInitialized) return;
    // 1. Đăng ký background handler

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
        if (response.payload != null) {
          final Map<String, dynamic> data = jsonDecode(response.payload!);
          final article = Article(
            sourceName: data['sourceName'],
            title: data['title'],
            url: data['url'],
            urlToImage: data['urlToImage'],
            publishedAt: DateTime.now(),
          );
          AppRouter.router.pushNamed('articleDetail', extra: article);
        }
      },
    );
  }

  // Lắng nghe message trong các trạng thái khác nhau
  static void _setupMessageHandlers() {
    // Foreground: app đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      //_showLocalNotification(message); // Phải tự hiện vì FCM không tự hiện

      //Chỉ truyền dữ liệu đi, không code UI ở đây
      if (onForegroundMessageReceived != null) {
        onForegroundMessageReceived!(message);
      }
    });

    // Opened app: user tap notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tap notification: ${message.notification?.title}');
      // TODO: điều hướng đến ArticleDetail
      final url = message.data['url'] ?? '';
      if (url.isNotEmpty) {
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
    final payloadData = {
      'url': message.data['url'],
      'title': message.notification?.title ?? "Tin tức mới",
      'sourceName': message.data['sourceName'] ?? 'Unknown',
      'urlToImage': message.data['urlToImage'],
    };
    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? "Tin tức mới",
      body: message.notification?.body ?? 'Có tin tức mới được cập nhật!',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: jsonEncode(payloadData),
    );
  }

  // Thay vì dùng local notification => bottom sheet

  static void _openPost(RemoteMessage message) {
    final url = message.data['url'] ?? '';
    final title = message.notification?.title ?? 'Tin tức mới';
    final sourceName = message.data['sourceName'] ?? 'Unknown';
    final urlToImage = message.data['urlToImage'];

    if (url == null) return;

    _navigateToDetail(
      url: url,
      title: title,
      sourceName: sourceName,
      urlToImage: urlToImage,
    );
  }

  static void _navigateToDetail({
    required String url,
    String? title,
    String? sourceName,
    String? urlToImage,
  }) {
    final article = Article(
      sourceName: sourceName ?? 'Unknown',
      title: title ?? 'Tin tức mới',
      url: url,
      publishedAt: DateTime.now(),
      urlToImage: urlToImage,
    );

    //pushNamed dùng name không có dấu /
    AppRouter.router.pushNamed('articleDetail', extra: article);
  }
}
