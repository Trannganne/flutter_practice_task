import 'package:shared_preferences/shared_preferences.dart';
import '../model/activitymodel.dart';
import 'dart:convert';

class CacheService {
  static const String _preKey = 'cached_activity';

  static Future<void> saveActivity(Activitymodel activity) async {
    // Lưu activityText vào cache
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(activity.toJson());

    await prefs.setString(_preKey, jsonString);
  }

  static Future<Activitymodel?> getLastActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preKey);

    if (jsonString == null) return null;

    return Activitymodel.fromJson(jsonDecode(jsonString));
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_preKey);
  }
}
