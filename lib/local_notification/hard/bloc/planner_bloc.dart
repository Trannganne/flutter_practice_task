import 'package:bloc/bloc.dart';
import 'package:flutterpractisetasks/local_notification/easy/model/activitymodel.dart';
import 'package:flutterpractisetasks/local_notification/easy/services/apiservice.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/notificationhistory.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/planner_notification.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/notificationservice.dart'
    as local_planner_notifi;
import 'package:flutterpractisetasks/local_notification/easy/services/notification_service.dart'
    as local_act_notifi;
import 'package:flutterpractisetasks/local_notification/hard/services/planner_history_cacheservice.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/weather_background_service.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/notificationservice.dart'
    as local_weather_notifi;
import 'package:flutterpractisetasks/local_notification/easy/services/cache_service.dart ';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_event.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_state.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/weather_cacheservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/models/forecast.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/locationservice.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/rain_detector.dart';
import 'package:flutterpractisetasks/local_notification/medium/service/weather_api.dart';
import '../models/planner_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlannerBloc extends Bloc<PlannerEvent, PlannerState> {
  PlannerBloc() : super(PlannerInitial()) {
    on<FetchPlannerEvent>(_onFetchPlanner);
    //on<ShowNotificationEvent>(_onTestNotification);
    on<RetryPlannerEvent>(_onRetryPlanner);
    on<ToggleActivityReminderEvent>(_onToggleActivityReminder);
    on<ToggleUmbrellaReminderEvent>(_onToggleUmbrellaReminder);
    on<UpdateRainThresholdEvent>(_onUpdateThreshold);
    on<ToggleBackgroundSyncEvent>(_onToggleBackgroundSync);
  }

  // Khai báo key cho share prefs
  final String _actKey = 'isActivityEnabled';
  final String _forecastKey = 'isForecastEnabled';
  final String _backgroundKey = 'isSyncingEnabled';
  final String _thresholdKey = 'threshold';

  Future<void> _onFetchPlanner(
    FetchPlannerEvent event,
    Emitter<PlannerState> emit,
  ) async {
    emit(PlannerNeedLocationPermission());

    final granted = await LocationService.requestLocationPermission();
    if (!granted) {
      emit(
        PlannerLoadFailure(message: 'Cần cấp quyền để sử dụng chức năng này!'),
      );
    }
    try {
      emit(PlannerLoading());
      final position = await LocationService.getCurrentLocation();
      final activity = await ApiService.getRandomActivity();
      final forecast = await WeatherApi.getForecast(
        position.latitude,
        position.longitude,
      );

      // Đọc dữ liệu bật/ tắt switch từ share prefs
      final prefs = await SharedPreferences.getInstance();
      final threshold = prefs.getDouble('threshold') ?? 0.5;

      final isActivityEnabled = prefs.getBool(_actKey) ?? false;
      final isForecastEnabled = prefs.getBool(_forecastKey) ?? false;
      final isSyncingEnabled = prefs.getBool(_backgroundKey) ?? false;

      // Tính các thông số cần thiết cho việc chuyển đổi sang plannerdata
      final value = forecast.maxRainProbabilityNext12h;
      final result = value >= threshold;
      final text = _buildNotification(activity, forecast, result);

      final planner = PlannerHelper().convertToPlanner(
        forecast,
        activity,
        threshold,
        text,
        isActivityEnabled,
        isForecastEnabled,
        isSyncingEnabled,
      );

      // Lưu vào cache
      await CacheService.saveActivity(activity);
      await WeatherCacheservice.saveForecast(forecast);

      emit(
        PlannerLoadSuccess(
          planner: planner,
          actionMessage: "Tải planner thành công!",
        ),
      );
    } catch (e) {
      final activityCached = await CacheService.getLastActivity();
      final forecastCached = await WeatherCacheservice.getForecast();

      // Lấy isScheduled từ share pref
      final prefs = await SharedPreferences.getInstance();
      final isActivityEnabled = prefs.getBool(_actKey) ?? false;
      final isForecastEnabled = prefs.getBool(_forecastKey) ?? false;
      final isSyncingEnabled = prefs.getBool(_backgroundKey) ?? false;
      final threshold = prefs.getDouble(_thresholdKey) ?? 0.5;

      if (activityCached != null && forecastCached != null) {
        final text = _buildNotification(
          activityCached,
          forecastCached,
          forecastCached.maxRainProbabilityNext12h >= 50,
        );
        final convert = PlannerHelper();
        final planner = convert.convertToPlanner(
          forecastCached,
          activityCached,
          threshold,
          text,
          isActivityEnabled,
          isForecastEnabled,
          isSyncingEnabled,
        );

        emit(
          PlannerLoadSuccess(
            planner: planner,
            actionMessage: 'Tải planner thành công!',
          ),
        );
      } else {
        emit(PlannerLoadFailure(message: 'Tải planner thất bại: $e'));
      }
    }
  }

  // Future<void> _onTestNotification(
  //   ShowNotificationEvent event,
  //   Emitter<PlannerState> emit,
  // ) async {
  //   if (state is! PlannerLoadSuccess) return;
  //   final current = state as PlannerLoadSuccess;

  //   await NotificationService.showTestNotification(
  //     current.planner.notificationText,
  //   );
  //   emit(current.copyWith(actionMessage: 'Đã gửi thông báo thử nghiệm!'));
  // }

  Future<void> _onRetryPlanner(
    RetryPlannerEvent event,
    Emitter<PlannerState> emit,
  ) async {
    add(FetchPlannerEvent());
  }

  //==================== QUẢN LÝ CÁC SWITCH ====================

  Future<void> _onToggleActivityReminder(
    ToggleActivityReminderEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoadSuccess) return;
    final current = state as PlannerLoadSuccess;

    // Lấy trạng thái của switch forecast từ share pref
    final prefs = await SharedPreferences.getInstance();
    final isForecastEnabled = prefs.getBool(_forecastKey) ?? false;
    final threshold = prefs.getDouble(_thresholdKey) ?? 0.5;

    if (event.isEnabled) {
      final result =
          current.planner.forecast.maxRainProbabilityNext12h >= threshold;

      _pushNotification(
        current.planner.activity,
        current.planner.forecast,
        true,
        isForecastEnabled,
        result,
      );

      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_actKey, true);

      emit(
        current.copyWith(
          planner: current.planner.copyWith(activityEnabled: true),
          actionMessage: 'Đã bật thông báo hằng ngày lúc 8:00AM',
        ),
      );
    } else {
      await local_act_notifi.NotificationService.cancelScheduleNotification();
      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_actKey, false);
      emit(
        current.copyWith(
          planner: current.planner.copyWith(activityEnabled: false),
          actionMessage: 'Đã hủy lịch nhắc lúc 8:00AM',
        ),
      );
    }
  }

  Future<void> _onToggleUmbrellaReminder(
    ToggleUmbrellaReminderEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoadSuccess) return;
    final current = state as PlannerLoadSuccess;

    // Lấy trạng thái của switch forecast từ share pref
    final prefs = await SharedPreferences.getInstance();
    final isActivityEnabled = prefs.getBool(_actKey) ?? false;
    final threshold = prefs.getDouble(_thresholdKey) ?? 0.5;

    if (event.isEnabled) {
      final result =
          current.planner.forecast.maxRainProbabilityNext12h >= threshold;

      _pushNotification(
        current.planner.activity,
        current.planner.forecast,
        isActivityEnabled,
        true,
        result,
      );

      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_forecastKey, true);

      emit(
        current.copyWith(
          planner: current.planner.copyWith(forecastEnabled: true),
          actionMessage: 'Đã bật thông báo nhắc nhở khi trời mưa!',
        ),
      );
    } else {
      await local_weather_notifi
          .NotificationService.cancelScheduleNotification();
      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_forecastKey, false);
      emit(
        current.copyWith(
          planner: current.planner.copyWith(forecastEnabled: false),
          actionMessage: 'Đã hủy lịch nhắc khi trời mưa!',
        ),
      );
    }
  }

  // Bật switch chạy ngầm
  Future<void> _onToggleBackgroundSync(
    ToggleBackgroundSyncEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoadSuccess) return;

    final current = state as PlannerLoadSuccess;

    final prefs = await SharedPreferences.getInstance();

    final service = WeatherBackgroundService();

    if (event.isEnabled) {
      // Khởi tạo WorkManager
      await service.initBackgroundTask();

      // Đăng ký chạy nền
      await service.startPeriodicTask();

      // Lưu trạng thái
      await prefs.setBool(_backgroundKey, true);

      emit(
        current.copyWith(
          planner: current.planner.copyWith(syncEnabled: true),
          actionMessage: 'Đã bật Background Sync',
        ),
      );
    } else {
      // Hủy WorkManager
      await service.stopBackgroundTask();

      // Lưu trạng thái
      await prefs.setBool(_backgroundKey, false);

      emit(
        current.copyWith(
          planner: current.planner.copyWith(syncEnabled: false),
          actionMessage: 'Đã tắt Background Sync',
        ),
      );
    }
  }

  String _buildNotification(
    Activitymodel activity,
    Forecast forecast,
    bool willRain,
  ) {
    if (willRain) {
      return '''${activity.activity}\nDự báo mưa lên đến ${forecast.maxRainProbabilityNext12h * 100}%. Đừng quên mang ô khi ra ngoài nha!
       ''';
    }
    return '''${activity.activity}
Have a nice day!       ''';
  }

  void _pushNotification(
    Activitymodel activity,
    Forecast forecast,
    bool isAct,
    bool isForecast,
    bool result,
  ) async {
    if (isAct && isForecast) {
      final body = _buildNotification(activity, forecast, result);
      local_planner_notifi.NotificationService.schedulePlanner(
        body,
        hour: 13,
        minute: 53,
      );
      await PlannerHistoryCacheservice.savePlannerHistory(
        NotificationHistory(
          title: 'Daily Planner',
          body: body,
          time: DateTime.now(),
          type: 'planner',
        ),
      );
    } else {
      if (!isAct && isForecast) {
        local_weather_notifi.NotificationService.scheduleUmbrella(
          forecast.maxRainProbabilityNext12h,
          hour: 13,
          minute: 53,
        );
        await PlannerHistoryCacheservice.savePlannerHistory(
          NotificationHistory(
            title: 'Rain Umbrella Reminder',
            body:
                ' Dựa báo mưa lên đến ${forecast.maxRainProbabilityNext12h * 100}%.\n Đừng quên mang ô khi ra ngoài!',
            time: DateTime.now(),
            type: 'weather',
          ),
        );
      } else {
        local_act_notifi.NotificationService.scheduleDailyAt8AM(
          activity.activity,
        );
        await PlannerHistoryCacheservice.savePlannerHistory(
          NotificationHistory(
            title: 'Daily Activity',
            body: activity.activity,
            time: DateTime.now(),
            type: 'activity',
          ),
        );
      }
    }
  }

  Future<void> _onUpdateThreshold(
    UpdateRainThresholdEvent event,
    Emitter<PlannerState> emit,
  ) async {
    if (state is! PlannerLoadSuccess) return;

    final current = state as PlannerLoadSuccess;

    // lưu threshold
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_thresholdKey, event.threshold);

    final forecast = current.planner.forecast;

    final willRain = forecast.maxRainProbabilityNext12h >= event.threshold;

    final text = _buildNotification(
      current.planner.activity,
      forecast,
      willRain,
    );

    final planner = current.planner.copyWith(
      rainThreshold: event.threshold,
      willRain: willRain,
      notificationText: text,
    );

    emit(
      current.copyWith(
        planner: planner,
        actionMessage: 'Đã cập nhật ngưỡng ${(event.threshold * 100).round()}%',
      ),
    );
  }
}
