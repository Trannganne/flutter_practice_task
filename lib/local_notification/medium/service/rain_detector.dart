import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/hourly_forecast.dart';

class RainDetector {
  static const double defaultThreshold = 0.5;

  static bool hasRainComingSoon(
    final Forecast forecast, {
    double threshold = defaultThreshold,
  }) {
    final nextHour = forecast.nextHours(12);
    return nextHour.any((h) => h.hasRain || h.rainProbability >= threshold);
  }

  // Tìm giờ đầu tiên có mưa
  static HourlyForecast? findFirstRainHour(
    Forecast forecast, {
    double threshold = defaultThreshold,
  }) {
    return forecast
        .nextHours(12)
        .firstWhere(
          (h) => h.hasRain || h.rainProbability >= threshold,
          orElse: () => forecast.hourlyList.first,
        );
  }

  // Tính xác suất mưa cao nhất và trả về % để hiện UI
  static int getRainPercentage(Forecast forecast) {
    return (forecast.maxRainProbabilityNext12h * 100).round();
  }
}
