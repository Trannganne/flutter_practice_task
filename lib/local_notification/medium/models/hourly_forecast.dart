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
      'dt': dateTime.toIso8601String(),
      'main': {'temp': temp, 'feels_like': feelsLike, 'humidity': humidity},
      'weather': [
        {'main': weatherMain, 'description': description, 'icon': icon},
      ],
      'wind': {'speed': windSpeed},
      'pop': rainProbability,
    };
  }

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      // dt là Unix timestamp (seconds) → convert sang DateTime
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
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
