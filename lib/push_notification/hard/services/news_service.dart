import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

class NewsService {
  // Tạo dio instance
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: 'https://newsapi.org/v2',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )
        ..interceptors.add(
          RetryInterceptor(
            dio: Dio(),
            retries: 3,
            retryDelays: const [
              Duration(seconds: 1),
              Duration(seconds: 2),
              Duration(seconds: 4),
            ],
          ),
        );

  static Future<List<Article>> getArticles({
    String country = 'us',
    String category = 'technology',
    int page = 1,
    int limit = 10,
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
          'page': page,
          'pageSize': limit,
        },
      );

      if (response.data['status'] != 'ok') {
        throw Exception('Lỗi newsApi:${response.data['message']} ');
      }

      final List<dynamic> articlesJson = response.data['articles'];
      print('Lấy được rồi nhe');
      print("Items: ${articlesJson.length}");

      for (final e in articlesJson) {
        print(e['title']);
      }
      return articlesJson.map((json) => Article.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Lỗi khi tải danh sách articles: $e');
    }
  }
}
