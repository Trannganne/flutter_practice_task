import 'package:flutterpractisetasks/local_notification/easy/model/activitymodel.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';

class PlannerUimodel {
  final Activitymodel activity;
  final Forecast forecast;

  final bool willRain;
  final double rainProbability;
  final double rainThreshold;
  final String notificationText;

  final bool activityEnabled;
  final bool forecastEnabled;
  final bool syncEnabled;

  PlannerUimodel({
    required this.activity,
    required this.forecast,
    required this.willRain,
    required this.rainProbability,
    required this.rainThreshold,
    required this.notificationText,
    required this.activityEnabled,
    required this.forecastEnabled,
    required this.syncEnabled,
  });

  PlannerUimodel copyWith({
    Activitymodel? activity,
    Forecast? forecast,
    bool? willRain,
    double? rainProbability,
    double? rainThreshold,
    String? notificationText,
    bool? activityEnabled,
    bool? forecastEnabled,
    bool? syncEnabled,
  }) {
    return PlannerUimodel(
      activity: activity ?? this.activity,
      forecast: forecast ?? this.forecast,
      willRain: willRain ?? this.willRain,
      rainProbability: rainProbability ?? this.rainProbability,
      rainThreshold: rainThreshold ?? this.rainThreshold,
      notificationText: notificationText ?? this.notificationText,
      activityEnabled: activityEnabled ?? this.activityEnabled,
      forecastEnabled: forecastEnabled ?? this.forecastEnabled,
      syncEnabled: syncEnabled ?? this.syncEnabled,
    );
  }
}
