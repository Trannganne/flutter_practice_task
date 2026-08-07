import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/medium/bloc/forecast_bloc.dart';
import 'package:flutterpractisetasks/local_notification/medium/bloc/forecast_event.dart';
import 'package:flutterpractisetasks/local_notification/medium/bloc/forecast_state.dart';
import 'package:flutterpractisetasks/local_notification/medium/screens/hourlyforecastrow.dart';
import 'package:flutterpractisetasks/local_notification/medium/screens/rainprobabilitycard.dart';
import 'package:flutterpractisetasks/local_notification/medium/screens/weathercard.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherBloc()..add(FetchWeatherEvent()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Umbrella Reminder'),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
          ),
          body: BlocConsumer<WeatherBloc, WeatherState>(
            listener: (context, state) {
              if (state is WeatherLoadSuccess && state.actionMessage != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.actionMessage!)));
              }
            },
            builder: (context, state) {
              return switch (state) {
                WeatherInitial() => const SizedBox.shrink(),

                WeatherRequestPermission() => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Đang xin quyền...'),
                    ],
                  ),
                ),

                WeatherLoading() => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Đang tải dự báo thời tiết...'),
                    ],
                  ),
                ),

                WeatherLoadFailure(:final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.read<WeatherBloc>().add(
                          RetryWeatherEvent(),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),

                // Empty state — không có mưa
                WeatherNoRain(:final forecast) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wb_sunny,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có mưa trong 12 giờ tới!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${forecast.cityName} — ${forecast.current.temp.round()}°C',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.read<WeatherBloc>().add(
                          RetryWeatherEvent(),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Cập nhật'),
                      ),
                    ],
                  ),
                ),

                WeatherLoadSuccess() => _buildLoaded(
                  context,
                  state as WeatherLoadSuccess,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, WeatherLoadSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // WeatherCard — nhiệt độ + thành phố
          WeatherCard(forecast: state.forecast),
          const SizedBox(height: 16),

          // HourlyForecastRow — cuộn ngang
          HourlyForecastRow(
            hourlyList: state.forecast.hourlyList.take(8).toList(),
          ),
          const SizedBox(height: 16),

          // RainProbabilityCard — % mưa + toggle notification
          RainProbabilityCard(
            percentage: state.rainPercentage,
            isScheduled: state.isScheduled,
            threshold: state.rainThreshold,
            onThresholdChanged: (value) => context.read<WeatherBloc>().add(
              UpdateRainThresholdEvent(value),
            ),
          ),
        ],
      ),
    );
  }
}
