import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feeditemmodel.dart';
import '../models/notificationmodel.dart';

class CacheService {
  static const String _feedKey = 'cached_feed_items';
  static const String _notifKey = 'cached_notifications';
  static const int _maxNotifications = 20;

  // ===== FEED =====

  // Lưu toàn bộ feed — gộp thành 1 JSON array string
  static Future<void> saveFeedItems(List<FeedItem> items) async {
    final prefs = await SharedPreferences.getInstance();

    // Đọc cache cũ để dedupe theo id
    final existing = await getCachedFeed();
    final Map<String, FeedItem> merged = {
      for (final item in existing) item.id: item,
    };

    // Ghi đè/thêm item mới — id giống nhau sẽ tự thay thế (dedupe)
    for (final item in items) {
      merged[item.id] = item;
    }

    final jsonList = merged.values.map((i) => i.toJson()).toList();
    await prefs.setString(_feedKey, jsonEncode(jsonList));
  }

  // Đọc toàn bộ feed từ cache
  static Future<List<FeedItem>> getCachedFeed() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_feedKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    final items = jsonList.map((j) => FeedItem.fromJson(j)).toList();

    // Sắp xếp mới nhất trước
    items.sort(
      (a, b) => (b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
    return items;
  }

  // ===== NOTIFICATION =====

  static Future<void> saveNotification(NotificationItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();

    // Dedupe theo id — nếu trùng thì không thêm nữa
    if (notifications.any((n) => n.id == item.id)) return;

    notifications.insert(0, item); // thêm vào đầu — mới nhất trước

    // Giữ tối đa 20 item
    final limited = notifications.take(_maxNotifications).toList();

    final jsonList = limited.map((n) => n.toJson()).toList();
    await prefs.setString(_notifKey, jsonEncode(jsonList));
  }

  static Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notifKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((j) => NotificationItem.fromJson(j)).toList();
  }

  // Đánh dấu đã đọc — phải đọc toàn bộ, sửa, ghi lại
  static Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getNotifications();

    final updated = notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();

    final jsonList = updated.map((n) => n.toJson()).toList();
    await prefs.setString(_notifKey, jsonEncode(jsonList));
  }

  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notifKey);
  }
}
