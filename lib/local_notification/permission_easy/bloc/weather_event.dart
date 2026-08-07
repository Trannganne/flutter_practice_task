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
