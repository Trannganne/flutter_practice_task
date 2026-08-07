import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PiscumApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://picsum.photos/v2',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  static Future<List<Map<String, dynamic>>> getPiscum_Map({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _dio.get(
        '/list',
        queryParameters: {'page': page, 'limit': limit},
      );
      final photosList = response.data;
      debugPrint('Dữ liệu piscum nè: $photosList');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
