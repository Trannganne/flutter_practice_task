import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

// Load trạng thái từ sharepreferences
class FetchSubscriptionsEvent extends SettingEvent {}

// User toggle 1 category
class ToggleSubscriptionEvent extends SettingEvent {
  final String category;
  final bool value;

  ToggleSubscriptionEvent({required this.category, required this.value});
}
