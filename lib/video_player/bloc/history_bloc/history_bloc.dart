import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/data/repository/cache_metadata_repository.dart';
import 'package:flutterpractisetasks/video_player/data/repository/watch_history_repository.dart';
import 'package:flutterpractisetasks/video_player/models/domain/history_item.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final WatchHistoryRepository _historyRepo;
  final VideoMetadataCacheRepository _metadataRepo;

  HistoryBloc({
    WatchHistoryRepository? historyRepo,
    VideoMetadataCacheRepository? metadataRepo,
  }) : _historyRepo = historyRepo ?? WatchHistoryRepository(),
       _metadataRepo = metadataRepo ?? VideoMetadataCacheRepository(),
       super(const HistoryState()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryEntryDeleted>(_onEntryDeleted);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    try {
      final entries = await _historyRepo.getAll();
      final items = <HistoryItem>[];

      for (final entry in entries) {
        final video = await _metadataRepo.getById(entry.videoId, entry.source);
        // Video có thể đã bị xoá khỏi cache metadata (vượt giới hạn 100)
        // — bỏ qua entry đó thay vì crash hoặc hiện item rỗng.
        if (video != null) {
          items.add(HistoryItem(video: video, progress: entry));
        }
      }

      emit(
        state.copyWith(
          status: items.isEmpty ? HistoryStatus.empty : HistoryStatus.loaded,
          items: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HistoryStatus.error,
          errorMessage: 'Không tải được lịch sử xem.',
        ),
      );
    }
  }

  Future<void> _onEntryDeleted(
    HistoryEntryDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    // Optimistic update: xoá khỏi UI ngay, không đợi ghi xong SharedPreferences,
    // để thao tác xoá cảm giác tức thời (đúng UX, không cần loading spinner).
    final updatedItems = state.items
        .where(
          (item) =>
              !(item.video.id == event.videoId &&
                  item.video.source == event.source),
        )
        .toList();
    emit(
      state.copyWith(
        status: updatedItems.isEmpty
            ? HistoryStatus.empty
            : HistoryStatus.loaded,
        items: updatedItems,
      ),
    );

    await _historyRepo.remove(event.videoId, event.source);
  }
}
