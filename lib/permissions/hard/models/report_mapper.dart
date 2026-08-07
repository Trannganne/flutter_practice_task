import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/permissionmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';

extension DraftMapper on Draftmodel {
  String get cardTitle => draftId ?? 'Bản nháp chưa đặt tên';
  String get cardLocation => siteLocation ?? 'Chưa chọn vị trí';
  DateTime get cardDate => dateTime ?? DateTime.now();
  ReportStatus get cardStatus => status;
  Color get cardStatusColor => const Color(0xFFEAB308); // Vàng

  List<Permissionmodel> get cardPermission => permissions ?? [];
  List<String> get cardPhotoUrl => photoUrls ?? [];
  int get cardPhotoCountr => photoCount ?? 0;
  double get cardLongitude => longitude ?? 0.0;
  double get cardLatitude => latitude ?? 0.0;
  double get cardAccuracy => accuracy ?? 0;
  String get cardNote => notes ?? '';
  String get cardWeather => weatherDesc ?? 'Chưa xác định';
  double get cardTemp => temp ?? 0;
  String get cardIconWeather => iconWeather ?? '';
  String get cardCountry => country ?? 'Chưa xác định';
  String get cardFlagUrl => flagUrl ?? 'flag';

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true; // không gõ gì thì hiện tất cả
    final q = query.toLowerCase().trim();
    return cardTitle.toLowerCase().contains(q) ||
        cardLocation.toLowerCase().contains(q) ||
        cardNote.toLowerCase().contains(q);
  }
}

extension ReportMapper on ReportModel {
  String get cardTitle => reportId;
  String get cardLocation => siteLocation;
  DateTime get cardDate => dateTime;
  ReportStatus get cardStatus => status; // Submitted / Exported
  Color get cardStatusColor => const Color(0xFF16A34A); // Xanh lá

  List<Permissionmodel> get cardPermission => permissions;
  List<String> get cardPhotoUrl => photoUrls;
  int get cardPhotoCountr => photoCount;
  double get cardLongitude => longitude;
  double get cardLatitude => latitude;
  double get cardAccuracy => accuracy;
  String get cardNote => notes;
  String get cardWeather => weatherDesc;
  double get cardTemp => temp;
  String get cardIconWeather => iconWeather;
  String get cardCountry => country;
  String get cardFlagUrl => flagUrl;

  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final q = query.toLowerCase().trim();
    return cardTitle.toLowerCase().contains(q) ||
        cardLocation.toLowerCase().contains(q) ||
        cardNote.toLowerCase().contains(q);
  }
}
