import 'package:dio/dio.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static final apiKey = dotenv.env['NEWS_API_WEATHER_KEY'] ?? '';

  static Future<Forecast> getForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': 'metric',
          'appid': apiKey,
        },
      );
      print(response.data);
      return Forecast.fromJson(response.data);
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
      //throw Exception('Failed to fetch weather forecast: $e');
    }
  }

  // Lấy weather hiện tại
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': 'metric',
          'appid': apiKey,
        },
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print("URI current weather: ${e.requestOptions.uri}");
      print("Status current weather: ${e.response?.statusCode}");
      print("Body current weather: ${e.response?.data}");
      rethrow;
      //throw Exception('Failed to fetch weather forecast: $e');
    }
  }
}
