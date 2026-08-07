import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/local_notification/easy/model/activitymodel.dart';

sealed class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {}

class ActivityLoadSuccess extends ActivityState {
  final Activitymodel activity;
  final bool isScheduled;
  final bool isOffline;
  final String? actionMessage;

  ActivityLoadSuccess({
    required this.activity,
    this.isScheduled = false, // Lịch 8h có đang bật không
    this.isOffline = false, // Có đang dùng cache không
    this.actionMessage,
  });

  ActivityLoadSuccess copyWith({
    Activitymodel? activity,
    bool? isScheduled,
    bool? isOffline,
    String? actionMessage,
  }) {
    return ActivityLoadSuccess(
      activity: activity ?? this.activity,
      isScheduled: isScheduled ?? this.isScheduled,
      isOffline: isOffline ?? this.isOffline,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [activity, isScheduled, isOffline, actionMessage];
}

class ActivityLoadFailure extends ActivityState {
  final String message;
  final Activitymodel? cachedActivity;

  const ActivityLoadFailure({required this.message, this.cachedActivity});

  @override
  List<Object?> get props => [message, cachedActivity];
}
