import 'package:dio/dio.dart';
import 'package:flutterpractisetasks/local_notification/easy/model/activitymodel.dart';

class ApiService {
  // Tạo Dio instance với cấu hình sẵn
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://bored-api.appbrewery.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<Activitymodel> getRandomActivity() async {
    try {
      final response = await _dio.get('/random');

      // Dio tự parse JSON, response.data đã là list
      return Activitymodel.fromJson(response.data);
    } on DioException catch (e) {
      // Dio có DioException riêng, chi tiết hơn
      throw Exception('Lỗi: ${e.message}');
    }
  }

  static Future<Activitymodel> getActivityByKey(String key) async {
    try {
      final response = await _dio.get('/activity/$key');

      return Activitymodel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Lỗi không tìm thấy activity có key $key: ${e.message}');
    }
  }
}
