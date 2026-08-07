import 'package:equatable/equatable.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

// Load lần đầu
class ActivityStarted extends ActivityEvent {}

class FetchActivityEvent extends ActivityEvent {}

class TestNotificationEvent extends ActivityEvent {}

class ToggleScheduleEvent extends ActivityEvent {
  final bool isEnabled;

  const ToggleScheduleEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}
