import 'package:equatable/equatable.dart';

abstract class PlannerEvent extends Equatable {
  const PlannerEvent();

  @override
  List<Object?> get props => [];
}

// Load lần đầu
class PlannerStarted extends PlannerEvent {}

class FetchPlannerEvent extends PlannerEvent {}

class ShowNotificationEvent extends PlannerEvent {}

class ToggleActivityReminderEvent extends PlannerEvent {
  final bool isEnabled;

  const ToggleActivityReminderEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class RetryPlannerEvent extends PlannerEvent {}

// User thay đổi ngưỡng % mưa trong Settings
class UpdateRainThresholdEvent extends PlannerEvent {
  final double threshold; // 0.0 đến 1.0
  UpdateRainThresholdEvent(this.threshold);

  @override
  List<Object?> get props => [];
}

class ToggleUmbrellaReminderEvent extends PlannerEvent {
  final bool isEnabled;

  const ToggleUmbrellaReminderEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleBackgroundSyncEvent extends PlannerEvent {
  final bool isEnabled;

  const ToggleBackgroundSyncEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}
