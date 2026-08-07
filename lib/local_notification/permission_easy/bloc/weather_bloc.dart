import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/permission_easy/bloc/weather_state.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/locationservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/weather_api.dart';
import 'package:flutterpractisetasks/local_notification/permission_easy/bloc/weather_event.dart';
import 'package:flutterpractisetasks/local_notification/permission_easy/repository/weather_repository.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<FetchWeatherEvent>(_onLoad);
    on<RetryWeatherEvent>(_onRetry);
  }

  final repository = WeatherRepository(WeatherApi());

  Future<void> _onLoad(
    FetchWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    // Bước 1 — xin permission
    emit(WeatherRequestPermission());
    final granted = await LocationService.requestLocationPermission();

    if (!granted) {
      emit(
        WeatherLoadFailure(
          message: 'Cần quyền vị trí và thông báo để sử dụng tính năng này.',
        ),
      );
      return;
    }

    // Bước 2 — lấy vị trí + gọi API
    emit(WeatherLoading());
    try {
      final position = await LocationService.getCurrentLocation();
      final forecast = await repository.getCurrentWeather(
        position.latitude,
        position.longitude,
      );
      print('Tới đây rồi nè');
      print('Lat nè: ${position.latitude}');
      print('Long nè: ${position.longitude}');

      emit(WeatherLoadSuccess(weather: forecast));
    } catch (e) {
      emit(WeatherLoadFailure(message: e.toString()));
    }
  }

  Future<void> _onRetry(
    RetryWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    add(FetchWeatherEvent());
  }
}
