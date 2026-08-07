import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/weather.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherRequestPermission extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  final Weather weather;
  final String? actionMessage;

  WeatherLoadSuccess({required this.weather, this.actionMessage});

  WeatherLoadSuccess copyWith({Weather? weather, String? actionMessage}) {
    return WeatherLoadSuccess(
      weather: weather ?? this.weather,

      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [weather, actionMessage];
}

class WeatherLoadFailure extends WeatherState {
  final String message;

  const WeatherLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
