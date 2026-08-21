import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/video_player/models/pixa_search_result.dart';

class PixabayApi {
  static final apiKey = dotenv.env['PIXABAY_API_KEY'];
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Tìm video theo từ khóa, có phân trang (page bắt đầu từ 1).
  /// query để trống ('') sẽ trả kết quả mặc định của Pixabay (editor's choice),
  /// nhưng theo đề bài Pixabay chỉ dùng cho tab Search nên UI không nên
  /// gọi hàm này khi chưa có từ khóa — validate ở Bloc trước khi gọi.
  Future<PixabaySearchResult> searchVideos({
    required String query,
    required int page,
    int perPage = 20,
  }) {
    return _fetch(query: query, page: page, perPage: perPage);
  }

  Future<PixabaySearchResult> _fetch({
    required String query,
    required int page,
    required int perPage,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception(
        'Thiếu PIXABAY_API_KEY. Kiểm tra file .env đã load chưa.',
      );
    }

    try {
      final response = await _dio.get(
        'https://pixabay.com/api/videos/',
        queryParameters: {
          'key': apiKey,
          if (query.isNotEmpty) 'q': query,
          'page': page,
          'per_page': perPage,
        },
      );

      return PixabaySearchResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint("URI: ${e.requestOptions.uri}");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
