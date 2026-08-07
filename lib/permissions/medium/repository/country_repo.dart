import 'dart:convert';

import 'package:flutterpractisetasks/permissions/medium/model/country.dart';
import 'package:flutterpractisetasks/permissions/medium/service/country_api.dart';

class CountryRepository {
  static Future<List<Map<String, dynamic>>> _getRawCountryList() async {
    final json = await CountryApi.getCountry_Map();

    final dataMap = json['data'] as Map<String, dynamic>?;
    final rawList = dataMap?['objects'] as List<dynamic>?;

    if (rawList == null) {
      throw Exception(
        'Không tìm thấy danh sách quốc gia trong response. '
        'Key hiện có: ${json.keys.toList()} — kiểm tra lại tên key đúng.',
      );
    }

    return rawList.cast<Map<String, dynamic>>();
  }

  static Future<List<Country>> getCountry() async {
    final rawList = await _getRawCountryList();

    return rawList.map((item) => Country.fromJson(item)).toList();
  }

  static Future<Country> getCountryByCode(String code) async {
    final country = await CountryApi.getCountryByCode(code);

    final dataMap = country['data'] as Map<String, dynamic>?;
    final rawList = dataMap?['objects'] as List<dynamic>?;

    if (rawList == null) {
      throw Exception(
        'Không tìm thấy danh sách quốc gia trong response. '
        'Key hiện có: ${country.keys.toList()} — kiểm tra lại tên key đúng.',
      );
    }

    return Country.fromJson(rawList.first as Map<String, dynamic>);
  }
}
