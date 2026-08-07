import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/notificationmodel.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {}

class MarkAsReadEvent extends NotificationEvent {
  final String id;
  MarkAsReadEvent({required this.id});
}

class ClearAllNotificationsEvent extends NotificationEvent {}

class NewNotificationsReceivedEvent extends NotificationEvent {
  NotificationItem item;
  NewNotificationsReceivedEvent({required this.item});
}
