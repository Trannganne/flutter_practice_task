import 'package:flutterpractisetasks/permissions/hard/models/permissionmodel.dart';

enum ReportStatus { draft, submitted }

class ReportModel {
  final List<Permissionmodel> permissions;
  final String reportId;
  final String siteLocation;
  final DateTime dateTime;
  final List<String> photoUrls;
  final double longitude;
  final double latitude;
  final double accuracy;
  final String notes;
  final int photoCount;
  final ReportStatus status;

  // Thông tin thời tiết
  final String weatherDesc;
  final double temp;
  final String iconWeather;

  // Thông tin quốc gia
  final String country;
  final String flagUrl;

  ReportModel({
    required this.permissions,
    required this.reportId,
    required this.siteLocation,
    required this.dateTime,
    required this.photoUrls,
    required this.photoCount,
    required this.longitude,
    required this.latitude,
    this.accuracy = 8,
    required this.notes,
    required this.status,
    required this.weatherDesc,
    required this.temp,
    required this.iconWeather,
    required this.country,
    required this.flagUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'permissions': permissions.map((p) => p.toJson()).toList(),
      'reportId': reportId,
      'siteLocation': siteLocation,
      'dateTime': dateTime.toIso8601String(),
      'photoUrls': photoUrls,
      'photoCount': photoCount,
      'longitude': longitude,
      'latitude': latitude,
      'accuracy': accuracy,
      'notes': notes,
      'status': status.name,
      'weatherDesc': weatherDesc,
      'temp': temp,
      'country': country,
      'flagUrl': flagUrl,
      'iconWeather': iconWeather,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      permissions: (json['permissions'] as List)
          .map((e) => Permissionmodel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reportId: json['reportId'] as String,
      siteLocation: json['siteLocation'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      photoUrls: (json['photoUrls'] as List).cast<String>(),
      photoCount: json['photoCount'] as int,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      notes: json['notes'] as String,
      status: ReportStatus.values.byName(json['status'] as String),
      weatherDesc: json['weatherDesc'] as String,
      temp: (json['temp'] as num).toDouble(),
      iconWeather: json['iconWeather'] as String,
      country: json['country'] as String,
      flagUrl: json['flagUrl'] as String,
    );
  }
}
