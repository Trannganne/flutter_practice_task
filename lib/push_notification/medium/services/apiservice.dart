import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

class Apiservice {
  // Tạo dio instance
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://newsapi.org/v2',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Future<List<Article>> getArticles({
    String country = 'us',
    String category = 'technology',
  }) async {
    try {
      // Lấy API key từ .env
      final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'country': country,
          'category': category,
          'apiKey': apiKey,
        },
      );

      if (response.data['status'] != 'ok') {
        throw Exception('Lỗi newsApi:${response.data['message']} ');
      }

      final List<dynamic> articlesJson = response.data['articles'];
      print('Lấy được rồi nhe');

      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tải danh sách articles: $e');
    }
  }
}
