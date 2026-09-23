import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';
import 'package:flutterpractisetasks/push_notification/hard/router/app_routes.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/notification_model.dart';
import 'package:flutterpractisetasks/push_notification/hard/services/cache_service.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
//import 'package:flutterpractisetasks/router/main_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler phải top-level function
  // Không thể gọi UI ở đây nhưng CÓ THỂ lưu cache
  print('Background: ${message.notification?.title}');

  // Lưu notification vào cache ngay cả khi app background
  await _saveNotificationToCache(message);
}

// Tách ra top-level vì background handler cần gọi được
Future<void> _saveNotificationToCache(RemoteMessage message) async {
  final item = NotificationItem(
    id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: message.notification?.title ?? 'Tin tức mới',
    body: message.notification?.body ?? '',
    url: message.data['url'],
    sourceName: message.data['sourceName'] ?? 'Unknown',
    receivedAt: DateTime.now(),
  );
  await CacheService.saveNotification(item);
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static Map<String, dynamic>? pendingNavigationPayload;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await _getFCMToken();
    await _setupLocalNotifications();
    _setupMessageHandlers();
    await _handleInitialMessage();
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
      print('Người dùng từ chối notification!');
    }
  }

  static Future<void> _getFCMToken() async {
    String? token = await _messaging.getToken();
    print('FCM token: $token');
    _messaging.onTokenRefresh.listen((newToken) {
      print('Token mới: $newToken');
    });
  }

  static Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null) return;

        // Decode payload để lấy data điều hướng
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateFromPayload(data);
      },
    );
  }

  static void _setupMessageHandlers() {
    // Foreground — app đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.data['type'] != 'fcm_hard') return;
      print('Foreground: ${message.notification?.title}');

      // 1. Lưu vào NotificationItem cache — bài Hard yêu cầu
      await _saveNotificationToCache(message);

      // 2. Hiện in-app banner
      final context = AppRoutes.navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text('${message.notification?.title ?? 'Bảng tin mới'}\n${message.notification?.body ?? ''}'),
            leading: const Icon(Icons.notifications_active),
            actions: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: const Text('ĐÓNG'),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  _navigateFromPayload({
                    'url': message.data['url'],
                    'title': message.notification?.title,
                    'sourceName': message.data['sourceName'],
                    'urlToImage': message.data['urlToImage'],
                  });
                },
                child: const Text('XEM'),
              ),
            ],
          ),
        );
        // Tự động ẩn banner sau 4 giây
        Future.delayed(const Duration(seconds: 4), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          }
        });
      } else {
        await _showLocalNotification(message);
      }
    });

    // Background — user tap notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] != 'fcm_hard') return;
      print('Tap: ${message.notification?.title}');
      final url = message.data['url'] ?? '';
      if (url.isNotEmpty) {
        _navigateToDetail(
          url: url,
          title: message.notification?.title,
          sourceName: message.data['sourceName'],
          urlToImage: message.data['urlToImage'],
        );
      }
    });
  }

  // Terminated — app bị tắt hoàn toàn
  static Future<void> _handleInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage == null) return;
    if (initialMessage.data['type'] != 'fcm_hard') return;
    print('Initial message: ${initialMessage.notification?.title}');

    final url = initialMessage.data['url'] ?? '';
    if (url.isNotEmpty) {
      pendingNavigationPayload = initialMessage.data;
      pendingNavigationPayload!['title'] = initialMessage.notification?.title;
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'news_hub_channel',
          'NewsHub Alerts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        );

    // Gộp data cần thiết vào payload để dùng khi tap
    final payloadData = {
      'url': message.data['url'],
      'title': message.notification?.title ?? 'Tin tức mới',
      'sourceName': message.data['sourceName'] ?? 'Unknown',
      'urlToImage': message.data['urlToImage'],
    };

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? 'Bảng tin mới',
      body: message.notification?.body ?? 'Có nội dung mới được cập nhật!',
      notificationDetails: const NotificationDetails(android: androidDetails),
      payload: jsonEncode(payloadData),
    );
  }

  // Dùng khi tap notification từ local (payload đã decode sẵn)
  static void _navigateFromPayload(Map<String, dynamic> data) {
    final url = data['url'] ?? '';
    if (url.isEmpty) return;
    _navigateToDetail(
      url: url,
      title: data['title'],
      sourceName: data['sourceName'],
      urlToImage: data['urlToImage'],
    );
  }

  static void consumePendingNavigation() {
    if (pendingNavigationPayload != null) {
      final data = pendingNavigationPayload!;
      pendingNavigationPayload = null;
      _navigateFromPayload(data);
    }
  }

  // Điều hướng sang ArticleDetailScreen
  static void _navigateToDetail({
    required String url,
    String? title,
    String? sourceName,
    String? urlToImage,
    String? body,
    String? description,
  }) {
    final feedItem = FeedItem(
      id: 'article_$url', // Tạo ID duy nhất theo URL giống factory của model
      title: title ?? 'Bảng tin mới',
      body:
          body ??
          description ??
          'Nhấn vào nút bên dưới để xem chi tiết bài gốc.',
      description: description,
      url: url,
      imageUrl: urlToImage,
      sourceName: sourceName ?? 'Tin tức',
      publishedAt: DateTime.now(),
      type:
          'article', // Đặt mặc định loại 'article' vì có chứa link điều hướng gốc
      category: 'general',
    );

    AppRoutes.router.pushNamed('feedItemDetail', extra: feedItem);
  }
}
