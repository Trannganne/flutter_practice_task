import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherRequestPermission extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  final Forecast forecast;
  final bool isScheduled;
  final String? actionMessage;
  final bool hasRainSoon;
  final double rainThreshold;
  final int rainPercentage;

  WeatherLoadSuccess({
    required this.forecast,
    required this.hasRainSoon,
    required this.rainPercentage,
    this.isScheduled = false,
    this.rainThreshold = 0.5,
    this.actionMessage,
  });

  WeatherLoadSuccess copyWith({
    Forecast? forecast,
    bool? hasRainSoon,
    int? rainPercentage,
    bool? isScheduled,
    double? rainThreshold,
    String? actionMessage,
  }) {
    return WeatherLoadSuccess(
      forecast: forecast ?? this.forecast,
      hasRainSoon: hasRainSoon ?? this.hasRainSoon,
      rainPercentage: rainPercentage ?? this.rainPercentage,
      isScheduled: isScheduled ?? this.isScheduled,
      rainThreshold: rainThreshold ?? this.rainThreshold,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [forecast, isScheduled, actionMessage];
}

// Không có mưa → hiện empty state
class WeatherNoRain extends WeatherState {
  final Forecast forecast;
  const WeatherNoRain({required this.forecast});
}

class WeatherLoadFailure extends WeatherState {
  final String message;

  const WeatherLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
