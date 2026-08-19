import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/playerevent.dart';
import 'package:flutterpractisetasks/video_player/bloc/playerstate.dart';

class PlayerBloc extends Bloc<PlayerEvent, Playerstate> {
  PlayerBloc() : super(Playerstate()) {
    on<LoadVideoEvent>(_onLoadVideo);
    on<ShowVideoEvent>(_onShowVideo);
    on<DeleteHistoryEvent>(_onDeleteHistory);
  }
  Future<void> _onDeleteHistory(
    DeleteHistoryEvent event,
    Emitter<Playerstate> emit,
  ) async {}

  Future<void> _onLoadVideo(
    LoadVideoEvent event,
    Emitter<Playerstate> emit,
  ) async {}

  Future<void> _onShowVideo(
    ShowVideoEvent event,
    Emitter<Playerstate> emit,
  ) async {}
}
