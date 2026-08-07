import 'package:flutterpractisetasks/permissions/hard/models/permissionmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';

class Draftmodel {
  final List<Permissionmodel>? permissions;
  final String? draftId;
  final String? siteLocation;
  final DateTime? dateTime;
  final List<String>? photoUrls;
  final double? longitude;
  final double? latitude;
  final double? accuracy;
  final String? notes;
  final int? photoCount;
  final ReportStatus status;

  // Thông tin thời tiết
  final String? weatherDesc;
  final double? temp;
  final String? iconWeather;

  // Thông tin quốc gia
  final String? country;
  final String? flagUrl;

  Draftmodel({
    this.permissions,
    this.draftId, //
    this.siteLocation, //
    this.dateTime, //
    this.photoUrls,
    this.photoCount,
    this.longitude,
    this.latitude,
    this.accuracy,
    this.notes,
    this.status = ReportStatus.draft, //
    this.weatherDesc,
    this.temp,
    this.iconWeather,
    this.country,
    this.flagUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'permissions': permissions!.map((p) => p.toJson()).toList(),
      'draftId': draftId,
      'siteLocation': siteLocation,
      'dateTime': dateTime?.toIso8601String(),
      'photoUrls': photoUrls,
      'photoCount': photoCount,
      'longitude': longitude,
      'latitude': latitude,
      'accuracy': accuracy,
      'notes': notes,
      'status': status.name,
      'weatherDesc': weatherDesc,
      'temp': temp,
      'iconWeather': iconWeather,
      'country': country,
      'flagUrl': flagUrl,
    };
  }

  factory Draftmodel.fromJson(Map<String, dynamic> json) {
    return Draftmodel(
      permissions: (json['permissions'] as List)
          .map((e) => Permissionmodel.fromJson(e as Map<String, dynamic>))
          .toList(),
      draftId: json['draftId'] as String?,
      siteLocation: json['siteLocation'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : null,
      photoUrls: (json['photoUrls'] as List?)?.cast<String>(),
      photoCount: json['photoCount'] as int?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      status: ReportStatus.values.byName(json['status'] as String),
      weatherDesc: json['weatherDesc'] as String?,
      temp: (json['temp'] as num?)?.toDouble(),
      iconWeather: json['iconWeather'],
      country: json['country'] as String?,
      flagUrl: json['flagUrl'],
    );
  }
}
