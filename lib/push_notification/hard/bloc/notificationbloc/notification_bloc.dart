import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/notificationbloc/notification_event.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/notificationbloc/notification_state.dart';
import 'package:flutterpractisetasks/push_notification/hard/services/cache_service.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<ClearAllNotificationsEvent>(_ClearAllNotifications);
    on<NewNotificationsReceivedEvent>(_NewNotificationsReceived);
    on<LoadNotificationsEvent>(_onLoadNotifications);
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    await CacheService.markAsRead(event.id);
    try {} catch (e) {
      emit(NotificationLoadFailure(message: 'Đánh dấu đọc thất bại!'));
    }
  }

  Future<void> _ClearAllNotifications(
    ClearAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await CacheService.clearAll();
    } catch (e) {
      emit(NotificationLoadFailure(message: 'Xóa thất bại!'));
    }
  }

  Future<void> _NewNotificationsReceived(
    NewNotificationsReceivedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await CacheService.saveNotification(event.item);
      add(LoadNotificationsEvent());
    } catch (e) {
      emit(NotificationLoadFailure(message: 'Nhận thông báo mới thất bại!'));
    }
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await CacheService.getNotifications();
      final count = await CacheService.getUnreadCount();
      emit(
        NotificationLoadSuccess(
          notifications: notifications,
          countUnRead: count,
        ),
      );
    } catch (e) {
      emit(NotificationLoadFailure(message: 'Tải thông báo thất bại!'));
    }
  }
}
