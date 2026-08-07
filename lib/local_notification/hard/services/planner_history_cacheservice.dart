import 'dart:convert';

import 'package:flutterpractisetasks/local_notification/hard/models/notificationhistory.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerHistoryCacheservice {
  static const String _preKey = 'notification_history_key';
  static Future<void> savePlannerHistory(NotificationHistory item) async {
    final prefs = await SharedPreferences.getInstance();

    final histories = await getPlannerHistory();

    histories.insert(0, item);

    final jsonList = histories.map((e) => e.toJson()).toList();

    await prefs.setString(_preKey, jsonEncode(jsonList));
  }

  static Future<List<NotificationHistory>> getPlannerHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_preKey);

    if (jsonString == null) {
      return [];
    }

    final List data = jsonDecode(jsonString);

    return data.map((e) => NotificationHistory.fromJson(e)).toList();
  }

  static Future<void> clearCache() async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.remove(_preKey);
  }
}
