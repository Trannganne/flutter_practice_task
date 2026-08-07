import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/permissions/hard/models/draftmodel.dart';
import 'package:flutterpractisetasks/permissions/hard/models/report_mapper.dart';
import 'package:flutterpractisetasks/permissions/hard/models/reportmodel.dart';

class _Unset {
  const _Unset();
}

const _unSet = _Unset();

enum PermissionState { initial, granted, denied, permanentlyDenied }

enum GpsStatus {
  initial,
  loading,
  success,
  permissionDenied,
  serviceDisabled,
  failure,
}

enum WeatherStatus { initial, loading, success, failure }

enum SaveStatus { initial, saving, success, failure }

enum ListStatus { initial, loading, loaded, failure }

enum SaveActionType { draftSaved, reportExported, none }

class ReportState extends Equatable {
  final PermissionState cameraPermission;
  final PermissionState locationPermission;
  final PermissionState storagePermission;
  final SaveActionType? saveType;

  final ListStatus listStatus;
  final List<ReportModel> reports;
  final List<Draftmodel> drafts;
  final String? listErrorMessage;
  final String? actionMessage;

  final String reportId;
  final DateTime? createdAt;
  final String? siteLocation;
  final String notes;

  final List<String> photoPaths;
  int get photoCount => photoPaths.length;

  final GpsStatus gpsStatus;
  final double? latitude;
  final double? longitude;
  final double? accuracy;

  final WeatherStatus status;
  // Country info
  final String? countryGuess;
  final String? flagUrl;

  // Weather info
  final String? weatherDesc;
  final double? temp;

  final SaveStatus saveStatus;
  final String? saveErrorMessage;

  // Icon weather
  final String? icon;

  // Export part
  final String? exportPath;

  final DateTime? lastSavedAt;
  final String searchQuery;

  const ReportState({
    this.cameraPermission = PermissionState.initial,
    this.locationPermission = PermissionState.initial,
    this.storagePermission = PermissionState.initial,
    this.saveType,
    this.listStatus = ListStatus.initial,
    this.reports = const [],
    this.drafts = const [],
    this.listErrorMessage,
    this.actionMessage,
    this.reportId = '',
    this.createdAt,
    this.siteLocation,
    this.notes = '',
    this.photoPaths = const [],
    this.gpsStatus = GpsStatus.initial,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.status = WeatherStatus.initial,
    this.countryGuess,
    this.flagUrl,
    this.weatherDesc,
    this.temp,
    this.saveStatus = SaveStatus.initial,
    this.saveErrorMessage,

    this.icon,
    this.exportPath,
    this.lastSavedAt,
    this.searchQuery = '',
  });

  ReportState copyWith({
    PermissionState? cameraPermission,
    PermissionState? locationPermission,
    PermissionState? storagePermission,
    SaveActionType? saveType,
    ListStatus? listStatus,

    List<ReportModel>? reports,
    List<Draftmodel>? drafts,

    String? listErrorMessage,
    Object? actionMessage = _unSet,
    String? reportId,
    DateTime? createdAt,
    String? siteLocation,
    String? notes,
    List<String>? photoPaths,
    int? photoCount,
    GpsStatus? gpsStatus,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? countryGuess,
    String? flagUrl,
    WeatherStatus? status,
    String? weatherDesc,
    double? temp,
    SaveStatus? saveStatus,
    String? saveErrorMessage,

    // Icon weather
    String? icon,
    // ExportPath
    String? exportPath,
    DateTime? lastSavedAt,
    String? searchQuery,
  }) {
    return ReportState(
      cameraPermission: cameraPermission ?? this.cameraPermission,
      saveType: saveType ?? this.saveType,
      locationPermission: locationPermission ?? this.locationPermission,
      storagePermission: storagePermission ?? this.storagePermission,
      listStatus: listStatus ?? this.listStatus,
      reports: reports ?? this.reports,
      drafts: drafts ?? this.drafts,
      listErrorMessage: listErrorMessage ?? this.listErrorMessage,
      actionMessage: identical(actionMessage, _unSet)
          ? this.actionMessage
          : actionMessage as String?,
      reportId: reportId ?? this.reportId,
      createdAt: createdAt ?? this.createdAt,
      siteLocation: siteLocation ?? this.siteLocation,
      notes: notes ?? this.notes,
      photoPaths: photoPaths ?? this.photoPaths,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      countryGuess: countryGuess ?? this.countryGuess,
      flagUrl: flagUrl ?? this.flagUrl,
      status: status ?? this.status,
      weatherDesc: weatherDesc ?? this.weatherDesc,
      temp: temp ?? this.temp,
      saveStatus: saveStatus ?? this.saveStatus,
      saveErrorMessage: saveErrorMessage ?? this.saveErrorMessage,
      icon: icon ?? this.icon,
      exportPath: exportPath ?? this.exportPath,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Draftmodel> get filteredDrafts =>
      drafts.where((d) => d.matchesSearch(searchQuery)).toList();

  List<ReportModel> get filteredReports =>
      reports.where((r) => r.matchesSearch(searchQuery)).toList();

  @override
  List<Object?> get props => [
    cameraPermission,
    locationPermission,
    storagePermission,
    saveType,
    listStatus,
    reports,
    drafts,
    listErrorMessage,
    actionMessage,
    reportId,
    createdAt,
    siteLocation,
    notes,
    photoPaths,
    photoCount,
    gpsStatus,
    latitude,
    longitude,
    accuracy,
    countryGuess,
    flagUrl,
    status,
    weatherDesc,
    temp,
    saveStatus,
    saveErrorMessage,
    icon,
    exportPath,
    lastSavedAt,
    searchQuery,
  ];
}
