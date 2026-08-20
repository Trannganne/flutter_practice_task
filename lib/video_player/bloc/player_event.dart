import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoEvent extends PlayerEvent {
  final int page;
  const LoadVideoEvent(this.page);
  @override
  List<Object?> get props => [];
}

class DeleteHistoryEvent extends PlayerEvent {
  final String id;
  DeleteHistoryEvent(this.id);

  @override
  List<Object?> get props => [];
}

class LoadVideoHistory extends PlayerEvent {}

class LoadMore extends PlayerEvent {}
