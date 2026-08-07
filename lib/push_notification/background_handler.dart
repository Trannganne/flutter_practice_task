import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterpractisetasks/push_notification/hard/services/cache_service.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/notificationmodel.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final type = message.data['type'];
  print('[BG] type=$type, data=${message.data}');

  switch (type) {
    case 'fcm_easy':
      // Easy: hiện tại chưa cache gì, có thể để trống hoặc log lại
      // nếu sau này muốn Easy cũng có "inbox" giống Hard thì thêm ở đây
      break;

    case 'fcm_medium':
    case 'fcm_hard':
      // Medium + Hard dùng chung cấu trúc cache của Hard luôn,
      // vì cùng là dạng "bài viết có url"
      await _saveNotificationToCache(message);
      break;

    default:
      print('[BG] Unknown type: $type');
  }
}

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
