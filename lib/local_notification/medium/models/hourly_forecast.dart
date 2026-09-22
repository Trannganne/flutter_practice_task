class HourlyForecast {
  final DateTime dateTime;
  final double temp;
  final String weatherMain; // "Rain", "Clear", "Clouds"...
  final String description;
  final double rainProbability; // pop = probability of precipitation (0-1)
  final double? humidity;
  final double? windSpeed;
  final String? icon;
  final double? feelsLike; // Cảm giác nhiệt độ (°C)

  const HourlyForecast({
    required this.dateTime,
    required this.temp,
    required this.weatherMain,
    required this.description,
    required this.rainProbability,
    this.humidity,
    this.windSpeed,
    required this.icon,
    this.feelsLike,
  });

  Map<String, dynamic> toJson() {
    return {
      // Ghi Unix timestamp (seconds) — giữ đúng contract với OpenWeatherMap API
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {'temp': temp, 'feels_like': feelsLike, 'humidity': humidity},
      'weather': [
        {'main': weatherMain, 'description': description, 'icon': icon},
      ],
      'wind': {'speed': windSpeed},
      'pop': rainProbability,
    };
  }

  /// Parse trường dt: chấp nhận int (Unix seconds từ API) hoặc
  /// String ISO-8601 (cache cũ đã lưu trước khi sửa).
  static DateTime _parseDt(dynamic dt) {
    if (dt is int) {
      return DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    }
    if (dt is String) {
      return DateTime.parse(dt); // ISO-8601
    }
    throw FormatException(
      'HourlyForecast.fromJson: dt phải là int hoặc String ISO-8601, '
      'nhận được ${dt.runtimeType}: $dt',
    );
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      // Hỗ trợ cả Unix timestamp (API) và ISO-8601 string (cache cũ)
      dateTime: _parseDt(json['dt']),
      temp: (json['main']['temp'] as num).toDouble(),
      weatherMain: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      // pop có thể null → mặc định 0
      rainProbability: (json['pop'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['main']['humidity'] as num?)?.toDouble(),
      windSpeed: (json['wind']['speed'] as num?)?.toDouble(),
      icon: json['weather'][0]['icon'] as String?,
      feelsLike: (json['main']['feels_like'] as num?)?.toDouble(),
    );
  }

  // Kiểm tra có mưa không
  bool get hasRain => ['Rain', 'Drizzle', 'Thunderstorm'].contains(weatherMain);
}
