import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/pexel_search_result.dart';

class PexelApi {
  static final apiKey = dotenv.env['PEXELS_API_KEY'];
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  /// Tải video popular, phân trang theo page/per_page (dùng cho lần gọi đầu).
  Future<PexelSearchResult> loadPopularVideos({
    required int page,
    int perPage = 15,
  }) {
    return _fetch(
      'https://api.pexels.com/videos/popular',
      queryParameters: {'page': page, 'per_page': perPage},
    );
  }

  /// Tải trang tiếp theo bằng URL "next_page" Pexels trả sẵn — KHÔNG tự
  /// build lại query param, vì Pexels đã gói sẵn đầy đủ trong URL đó.
  Future<PexelSearchResult> loadNextPage(String nextPageUrl) {
    return _fetch(nextPageUrl);
  }

  Future<PexelSearchResult> _fetch(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('Thiếu PEXELS_API_KEY. Kiểm tra file .env đã load chưa.');
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        // Pexels dùng header Authorization, KHÁC Pixabay (key nằm trong
        // query param) — đây là lý do không thể gộp chung 1 hàm gọi API.
        options: Options(headers: {'Authorization': apiKey}),
      );

      return PexelSearchResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint("URI: ${e.requestOptions.uri}");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
