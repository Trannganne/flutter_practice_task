import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_state.dart';

class WeatherCountrySection extends StatelessWidget {
  final WeatherStatus status;
  final String? weatherDesc;
  final double? temp;
  final String? countryGuess;
  final String? icon;
  final String? flagUrl;

  const WeatherCountrySection({
    super.key,
    required this.status,
    required this.weatherDesc,
    required this.temp,
    required this.countryGuess,
    required this.icon,
    required this.flagUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather & Country',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (status) {
      case WeatherStatus.loading:
        return const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Đang lấy thời tiết...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        );

      case WeatherStatus.failure:
        return const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
            SizedBox(width: 10),
            Text(
              'Không lấy được thời tiết',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        );

      case WeatherStatus.success:
        return Row(
          children: [
            _buildWeatherIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$weatherDesc, ${temp?.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      flagUrl != null
                          ? SvgPicture.network(
                              flagUrl!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.flag,
                                size: 40,
                                color: Colors.red,
                              ), // fal
                            )
                          : const Icon(
                              Icons.flag,
                              size: 40,
                              color: Colors.grey,
                            ),
                      const SizedBox(width: 4),
                      Text(
                        countryGuess ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

      case WeatherStatus.initial:
        return const Text(
          'Lấy vị trí trước để xem thời tiết & quốc gia',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        );
    }
  }

  Widget _buildWeatherIcon() {
    return Image.network(
      'https://openweathermap.org/img/wn/$icon@2x.png',
      height: 28,
      width: 28,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.cloud_off, color: Colors.grey, size: 28);
      },
    );
  }
}
