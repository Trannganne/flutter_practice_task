import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/notificationservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/locationservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/rain_detector.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/weather_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forecast_event.dart';
import 'forecast_state.dart';
import 'package:dio/dio.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<FetchWeatherEvent>(_onLoad);
    on<RetryWeatherEvent>(_onRetry);
    on<UpdateRainThresholdEvent>(_onUpdateThreshold);
    on<ToggleScheduleEvent>(_onToggleSchedule);
  }

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
      final forecast = await WeatherApi.getForecast(
        position.latitude,
        position.longitude,
      );
      print('Lat nè: ${position.latitude}');
      print('Long nè: ${position.longitude}');

      // Bước 3 — detect mưa
      final prefs = await SharedPreferences.getInstance();
      final threshold = prefs.getDouble('rain_threshold') ?? 0.5;
      final isScheduled = prefs.getBool('umbrella_scheduled') ?? false;
      final hasRain = RainDetector.hasRainComingSoon(
        forecast,
        threshold: threshold,
      );
      final rainPct = RainDetector.getRainPercentage(forecast);

      if (!hasRain) {
        // Không có mưa → hủy lịch nếu đang bật
        if (isScheduled) {
          await NotificationService.cancelScheduleNotification();
          await prefs.setBool('umbrella_scheduled', false);
        }
        emit(WeatherNoRain(forecast: forecast));
        return;
      }

      // Bước 4 — có mưa → tự động schedule notification
      if (!isScheduled) {
        await NotificationService.scheduleUmbrella(
          forecast.maxRainProbabilityNext12h,
        );
        await prefs.setBool('umbrella_scheduled', true);
      }

      emit(
        WeatherLoadSuccess(
          forecast: forecast,
          hasRainSoon: true,
          rainPercentage: rainPct,
          isScheduled: true,
          rainThreshold: threshold,
        ),
      );
        } on DioException catch (e) {
      final isConnectionError =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;

      emit(
        WeatherLoadFailure(
          message: isConnectionError
              ? 'Vui lòng kiểm tra kết nối mạng'
              : 'Không thể tải dự báo thời tiết. Vui lòng thử lại.',
        ),
      );
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

  Future<void> _onUpdateThreshold(
    UpdateRainThresholdEvent event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherLoadSuccess) return;
    final current = state as WeatherLoadSuccess;

    // Lưu ngưỡng mới
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('threshold', event.threshold);

    // Kiểm tra lại với ngưỡng mới
    final hasRain = RainDetector.hasRainComingSoon(
      current.forecast,
      threshold: event.threshold,
    );

    emit(
      current.copyWith(
        hasRainSoon: hasRain,
        rainThreshold: event.threshold,
        actionMessage:
            'Đã cập nhật ngưỡng: ${(event.threshold * 100).round()}%',
      ),
    );
  }

  Future<void> _onToggleSchedule(
    ToggleScheduleEvent event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherLoadSuccess) return;
    final current = state as WeatherLoadSuccess;

    if (event.isEnabled) {
      await NotificationService.scheduleUmbrella(
        current.forecast.maxRainProbabilityNext12h,
      );

      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isScheduled', true);

      emit(
        current.copyWith(isScheduled: true, actionMessage: 'Đã bật thông báo.'),
      );
    } else {
      await NotificationService.cancelScheduleNotification();
      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isScheduled', false);
      emit(
        current.copyWith(isScheduled: false, actionMessage: 'Đã hủy lịch nhắc'),
      );
    }
  }
}
