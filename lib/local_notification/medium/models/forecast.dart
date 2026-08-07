import 'hourly_forecast.dart';

class Forecast {
  final String cityName;
  final List<HourlyForecast> hourlyList;

  // Nhiệt độ + thời tiết hiện tại (giờ đầu tiên)
  HourlyForecast get current => hourlyList.first;

  const Forecast({required this.cityName, required this.hourlyList});

  Map<String, dynamic> toJson() {
    return {
      'city': {'name': cityName},
      'list': hourlyList.map((item) => item.toJson()).toList(),
    };
  }

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      cityName: json['city']['name'] as String,
      hourlyList: (json['list'] as List)
          .map((item) => HourlyForecast.fromJson(item))
          .toList(),
    );
  }

  // Lấy forecast trong vòng N giờ tới
  List<HourlyForecast> nextHours(int hours) {
    final deadline = DateTime.now().add(Duration(hours: hours));
    return hourlyList.where((h) => h.dateTime.isBefore(deadline)).toList();
  }

  // Xác suất mưa cao nhất trong 6-12h tới
  double get maxRainProbabilityNext12h {
    final next = nextHours(12);
    if (next.isEmpty) return 0;
    return next.map((h) => h.rainProbability).reduce((a, b) => a > b ? a : b);
  }
}
