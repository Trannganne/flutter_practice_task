import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/video_player/models/pixa_search_result.dart';

class PixabayApi {
  static final apiKey = dotenv.env['PIXABAY_API_KEY'];
  static final Dio _dio = Dio();

  // Load videos
  Future<PixabaySearchResult> loadVideos({
    required int page,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        'https://pixabay.com/api/',
        queryParameters: {'key': apiKey, 'page': page, 'per_page': perPage},
      );

      return PixabaySearchResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }

  /// Tìm video theo từ khóa, có phân trang (page bắt đầu từ 1).
  Future<PixabaySearchResult> searchVideos({
    required String query,
    required int page,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        'https://pixabay.com/api/videos/',
        queryParameters: {
          'key': apiKey,
          'q': query,
          'page': page,
          'per_page': perPage,
        },
      );

      return PixabaySearchResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
