import 'package:bloc/bloc.dart';
import 'package:flutterpractisetasks/local_notification/easy/bloc/activity_event.dart';
import 'package:flutterpractisetasks/local_notification/easy/bloc/activity_state.dart';
import 'package:flutterpractisetasks/local_notification/easy/services/apiservice.dart';
import 'package:flutterpractisetasks/local_notification/easy/services/notification_service.dart';
import 'package:flutterpractisetasks/local_notification/easy/services/cache_service.dart ';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc() : super(ActivityInitial()) {
    on<FetchActivityEvent>(_onFetchActivities);
    on<TestNotificationEvent>(_onTestNotification);
    on<ToggleScheduleEvent>(_onToggleSchedule);
  }

  Future<void> _onFetchActivities(
    FetchActivityEvent event,
    Emitter<ActivityState> emit,
  ) async {
    emit(ActivityLoading());
    try {
      final activity = await ApiService.getRandomActivity();

      // Lưu vào cache
      await CacheService.saveActivity(activity);
      // Đọc trạng thái lịch từ share pref
      final prefs = await SharedPreferences.getInstance();
      final isScheduled = prefs.getBool('isScheduled') ?? false;

      emit(
        ActivityLoadSuccess(
          activity: activity,
          isScheduled: isScheduled,
          actionMessage: "Tải Activity thành công!",
        ),
      );
    } catch (e) {
      final cached = await CacheService.getLastActivity();

      // Lấy isScheduled từ share pref
      final prefs = await SharedPreferences.getInstance();
      final isScheduled = prefs.getBool('isScheduled') ?? false;

      if (cached != null) {
        emit(
          ActivityLoadSuccess(
            activity: cached,
            actionMessage: 'Tải activity từ cache',
            isOffline: true,
            isScheduled: isScheduled,
          ),
        );
      } else {
        emit(ActivityLoadFailure(message: 'Tải Activity thất bại: $e'));
      }
    }
  }

  Future<void> _onTestNotification(
    TestNotificationEvent event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is! ActivityLoadSuccess) return;
    final current = state as ActivityLoadSuccess;
    await NotificationService.showTestNotification(current.activity.activity);
    emit(current.copyWith(actionMessage: 'Đã gửi thông báo thử nghiệm!'));
  }

  Future<void> _onToggleSchedule(
    ToggleScheduleEvent event,
    Emitter<ActivityState> emit,
  ) async {
    if (state is! ActivityLoadSuccess) return;
    final current = state as ActivityLoadSuccess;

    if (event.isEnabled) {
      await NotificationService.scheduleDailyAt8AM(current.activity.activity);

      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isScheduled', true);

      emit(
        current.copyWith(
          isScheduled: true,
          actionMessage: 'Đã bật thông báo hằng ngày lúc 8:00AM',
        ),
      );
    } else {
      await NotificationService.cancelScheduleNotification();
      // Lưu trạng thái lịch vào share pref
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isScheduled', false);
      emit(
        current.copyWith(
          isScheduled: false,
          actionMessage: 'Đã hủy lịch nhắc lúc 8:00AM',
        ),
      );
    }
  }
}
