import 'package:bloc/bloc.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/settingbloc/setting_event.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/settingbloc/setting_state.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/topicservice.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingInitial()) {
    on<FetchSubscriptionsEvent>(_onFetchSubscriptions);
    on<ToggleSubscriptionEvent>(_onToggleSubscription);
  }

  Future<void> _onFetchSubscriptions(
    FetchSubscriptionsEvent event,
    Emitter<SettingState> emit,
  ) async {
    emit(SettingLoading());

    try {
      final subscribed = await TopicService.getSubscribed();

      // Tạo map với tất cả category, đánh dấu cái nào đang bật
      final Map<String, bool> subscriptions = {
        for (final category in TopicService.categoryTopics.keys)
          category: subscribed.contains(category),
      };
      emit(
        SettingLoadSuccess(
          subscriptions: subscriptions,
          actionMessage: "Tải thành công!",
        ),
      );
    } catch (e) {
      emit(SettingLoadFailure(message: 'Tải trạng thái không thành công!'));
    }
  }

  Future<void> _onToggleSubscription(
    ToggleSubscriptionEvent event,
    Emitter<SettingState> emit,
  ) async {
    if (state is SettingLoading) return;
    final current = state as SettingLoadSuccess;

    // Cập nhật UI ngay lập tức không chờ Firebase
    emit(current.copyWith(event.category, event.value));

    try {
      if (event.value) {
        await TopicService.subscribe(event.category);
      } else {
        await TopicService.unsubscribe(event.category);
      }
    } catch (e) {
      // Nếu lỗi rollback lại trạng thái cũ
      emit(current.copyWith(event.category, !event.value));
    }
  }
}
