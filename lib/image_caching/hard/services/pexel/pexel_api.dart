import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PexelApi {
  static final apiKey = dotenv.env['PEXEL_API_KEY'] ?? '';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.pexels.com/v1/',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Authorization': apiKey},
    ),
  );
  static Future<List<Map<String, dynamic>>> getPexelCollection_Map({
    int per_page = 20,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/collections/featured',
        queryParameters: {'page': page, 'per_page': per_page},
      );
      final List<dynamic> collectionList = response.data['collections'] ?? [];
      print("URI: ${response.requestOptions.uri}");
      debugPrint('Dữ liệu Collections: $collectionList');
      return collectionList.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPexelPhotos_Map({
    int per_page = 30,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/curated',
        queryParameters: {'page': page, 'per_page': per_page},
      );
      final List<dynamic> photosList = response.data['photos'];
      debugPrint('Dữ liệu: $photosList');
      return photosList.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }

  // Hàm lấy danh sách photos theo collection
  static Future<List<Map<String, dynamic>>> getPexelPhotos_ByCollectionId(
    String collectionId, {
    int perPage = 1,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/collections/$collectionId',
        queryParameters: {'type': 'Photo', 'page': page, 'per_page': perPage},
      );

      final List<dynamic> photosList = response.data['media'];
      debugPrint(
        'Dữ liệu photos theo collectionId ở tầng API ${photosList.length}:$collectionId: $photosList',
      );
      return photosList.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
