import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopicService {
  static String _prefKey(String category) => 'notify_$category';

  static const Map<String, String> categoryTopics = {
    'technology': 'tech-news',
    'business': 'business-news',
    'sports': 'sports-news',
    'health': 'health-news',
    'science': 'science-news',
    'entertainment': 'entertainment-news',
    'general': 'general-news',
  };

  /// Subscribe 1 topic + lưu vào SharedPreferences
  static Future<void> subscribe(String category) async {
    final topic = categoryTopics[category];
    if (topic == null) return;

    await FirebaseMessaging.instance.subscribeToTopic(topic);

    // Lưu lại để hiển thị trạng thái trong UI
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey(category), true);

    print('Subscribed: $topic');
  }

  // Unsubscribe 1 topic
  static Future<void> unsubscribe(String category) async {
    final topic = categoryTopics[category];
    if (topic == null) return;

    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey(category), false);
    print('Unsubscribed: $topic');
  }

  /// Lấy danh sách category đang subscribe
  static Future<List<String>> getSubscribed() async {
    final prefs = await SharedPreferences.getInstance();
    return categoryTopics.keys
        .where((category) => prefs.getBool(_prefKey(category)) ?? false)
        .toList();
  }

  /// Kiểm tra 1 category có đang subscribe không
  static Future<bool> isSubscribed(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey(category)) ?? false;
  }
}
