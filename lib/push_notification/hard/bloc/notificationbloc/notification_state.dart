import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/notificationmodel.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationEmpty extends NotificationState {}

class NotificationLoadSuccess extends NotificationState {
  final List<NotificationItem> notifications;
  final int countUnRead;
  final String? actionMessage;

  NotificationLoadSuccess({
    required this.notifications,
    required this.countUnRead,
    this.actionMessage,
  });
}

class NotificationLoadFailure extends NotificationState {
  final String message;

  NotificationLoadFailure({required this.message});

  @override
  List<Object?> get props => [];
}
