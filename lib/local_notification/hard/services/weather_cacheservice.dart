import 'dart:convert';

import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherCacheservice {
  static const String _preKey = 'weather_cache';

  static Future<void> saveForecast(Forecast forecast) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(forecast.toJson());

    await prefs.setString(_preKey, jsonString);
  }

  static Future<Forecast?> getForecast() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_preKey);

    if (jsonString == null) return null;
    return Forecast.fromJson(jsonDecode(jsonString));
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_preKey);
  }
}
