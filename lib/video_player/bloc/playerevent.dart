import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideoEvent extends PlayerEvent {}

class ShowVideoEvent extends PlayerEvent {}

class DeleteHistoryEvent extends PlayerEvent {}

class LoadVideoHistory extends PlayerEvent {}
