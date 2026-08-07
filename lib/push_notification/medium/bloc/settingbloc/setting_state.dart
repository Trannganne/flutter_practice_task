import 'package:equatable/equatable.dart';

sealed class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingLoadSuccess extends SettingState {
  final Map<String, bool> subscriptions;
  final String? actionMessage;

  SettingLoadSuccess({required this.subscriptions, this.actionMessage});

  // Tạo bản copy với 1 category thay đổi
  // Dùng khi toggle để không thay đổi state cũ
  SettingLoadSuccess copyWith(String category, bool value) {
    final newMap = Map<String, bool>.from(subscriptions);
    newMap[category] = value;
    return SettingLoadSuccess(subscriptions: newMap);
  }

  @override
  List<Object?> get props => [subscriptions, actionMessage];
}

class SettingLoadFailure extends SettingState {
  final String message;

  SettingLoadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
