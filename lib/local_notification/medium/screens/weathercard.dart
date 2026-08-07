import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';

class WeatherCard extends StatelessWidget {
  final Forecast forecast;

  const WeatherCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bên trái: Thông tin văn bản
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${forecast.current.temp.round()}',
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${forecast.current.description}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Feels like ${forecast.current.feelsLike!.round()}°',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Bên phải: Icon đám mây mưa lớn
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${forecast.cityName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Image.network(
                    'https://openweathermap.org/img/wn/${forecast.current.icon}@2x.png',
                  ),
                ],
              ),
            ],
          ),
          // Hàng thông số Độ ẩm & Tốc độ gió
          Row(
            children: [
              Icon(
                Icons.opacity,
                size: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 4),
              Text(
                'Humidity ${forecast.current.humidity}%',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Icon(Icons.air, size: 16, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 4),
              Text(
                'Wind ${forecast.current.windSpeed!.round()} km/h',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
