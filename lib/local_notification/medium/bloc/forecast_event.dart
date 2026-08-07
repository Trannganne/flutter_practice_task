import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

// Load lần đầu
class WeatherStarted extends WeatherEvent {}

class FetchWeatherEvent extends WeatherEvent {}

class RetryWeatherEvent extends WeatherEvent {}

// User thay đổi ngưỡng % mưa trong Settings
class UpdateRainThresholdEvent extends WeatherEvent {
  final double threshold; // 0.0 đến 1.0
  UpdateRainThresholdEvent(this.threshold);
}

class ToggleScheduleEvent extends WeatherEvent {
  final bool isEnabled;

  const ToggleScheduleEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}
