import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class PostService {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: 'https://jsonplaceholder.typicode.com',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )
        ..interceptors.add(
          RetryInterceptor(
            dio: Dio(),
            retries: 3,
            // Exponential backoff: 1s, 2s, 4s
            retryDelays: const [
              Duration(seconds: 1),
              Duration(seconds: 2),
              Duration(seconds: 4),
            ],
          ),
        );

  // Phân trang 10 item/lần
  static Future<List<Map<String, dynamic>>> getPosts({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {'_page': page, '_limit': limit},
      );
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Lỗi JSONPlaceholder: ${e.message}');
    }
  }
}
