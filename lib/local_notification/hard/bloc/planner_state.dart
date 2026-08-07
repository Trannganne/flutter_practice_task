import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/planner_uimodel.dart';

sealed class PlannerState extends Equatable {
  const PlannerState();

  @override
  List<Object?> get props => [];
}

class PlannerInitial extends PlannerState {}

class PlannerLoading extends PlannerState {}

class PlannerLoadSuccess extends PlannerState {
  final PlannerUimodel planner;
  final bool isSyncing;
  final bool isOffline;
  final String? actionMessage;

  PlannerLoadSuccess({
    required this.planner,
    this.isSyncing = false,
    this.isOffline = false, // Có đang dùng cache không
    this.actionMessage,
  });

  PlannerLoadSuccess copyWith({
    PlannerUimodel? planner,
    bool? isOffline,
    bool? isSyncing,
    String? actionMessage,
    double? rainThreshold,
  }) {
    return PlannerLoadSuccess(
      planner: planner ?? this.planner,
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [planner, isOffline, isSyncing, actionMessage];
}

class PlannerLoadFailure extends PlannerState {
  final String message;
  final PlannerUimodel? cachedActivity;

  const PlannerLoadFailure({required this.message, this.cachedActivity});

  @override
  List<Object?> get props => [message, cachedActivity];
}

class PlannerNeedLocationPermission extends PlannerState {}
