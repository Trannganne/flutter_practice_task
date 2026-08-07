import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CountryApi {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.restcountries.com/countries',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );
  static final apiKey = dotenv.env['COUNTRY_API_KEY'] ?? '';
  static Future<Map<String, dynamic>> getCountry_Map() async {
    try {
      final response = await _dio.get(
        '/v5',
        queryParameters: {'api-key': apiKey},
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCountryByCode(String code) async {
    try {
      final response = await _dio.get(
        '/v5/codes.alpha_2/$code',
        queryParameters: {'api-key': apiKey},
      );
      print(response.data);
      return response.data;
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
