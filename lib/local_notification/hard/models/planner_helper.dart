import 'package:flutterpractisetasks/local_notification/easy/model/activitymodel.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/planner_uimodel.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';

class PlannerHelper {
  PlannerUimodel convertToPlanner(
    Forecast forecast,
    Activitymodel activity,
    double threshold,
    String notificationText,
    bool isActEnabled,
    bool isAForecastEnabled,
    bool isSyncEnabled,
  ) {
    return PlannerUimodel(
      activity: activity,
      forecast: forecast,
      willRain: forecast.maxRainProbabilityNext12h >= threshold,
      rainProbability: forecast.maxRainProbabilityNext12h,
      notificationText: notificationText,
      activityEnabled: isActEnabled,
      forecastEnabled: isAForecastEnabled,
      syncEnabled: isSyncEnabled,
      rainThreshold: threshold,
    );
  }
}
