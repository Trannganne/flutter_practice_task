import 'package:dio/dio.dart';
import 'package:flutterpractisetasks/push_notification/easy/models/post.dart';

class ApiService {
  // Tạo Dio instance với cấu hình sẵn
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('/posts');

      // Dio tự parse JSON, response.data đã là list
      return (response.data as List)
          .map((json) => Post.fromJson(json))
          .toList();
    } on DioException catch (e) {
      // Dio có DioException riêng, chi tiết hơn
      throw Exception('Lỗi: ${e.message}');
    }
  }

  static Future<Post> getPostById(int id) async {
    try {
      final response = await _dio.get('/posts/$id');

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Lỗi không tìm thấy post có id $id: ${e.message}');
    }
  }
}
