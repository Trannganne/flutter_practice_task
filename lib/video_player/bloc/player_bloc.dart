import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/playerevent.dart';
import 'package:flutterpractisetasks/video_player/bloc/playerstate.dart';
import 'package:flutterpractisetasks/video_player/data/repository/playerrepository.dart';

class PlayerBloc extends Bloc<PlayerEvent, Playerstate> {
  PlayerBloc() : super(Playerstate()) {
    on<LoadVideoEvent>(_onLoadVideo);
    on<DeleteHistoryEvent>(_onDeleteHistory);
  }
  Future<void> _onDeleteHistory(
    DeleteHistoryEvent event,
    Emitter<Playerstate> emit,
  ) async {}

  Future<void> _onLoadVideo(
    LoadVideoEvent event,
    Emitter<Playerstate> emit,
  ) async {
    try {
      final videos = await PlayerRepository().getVideo(event.page);

      emit(
        state.copyWith(videos: videos, actionMessage: 'Tải videos thành công!'),
      );
    } catch (e) {
      debugPrint("Lỗi tải video: $e");
      emit(
        state.copyWith(
          actionMessage: 'Lỗi khi tải video. Vui lòng đợi trong giây lát',
        ),
      );
    }
  }
}
