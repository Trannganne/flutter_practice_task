import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/downloads/downloads_event.dart';
import 'package:flutterpractisetasks/video_player/bloc/downloads/downloads_state.dart';
import 'package:flutterpractisetasks/video_player/data/repository/cache_metadata_repository.dart';
import 'package:flutterpractisetasks/video_player/data/repository/download_repository.dart';

/// Liệt kê mọi video đã có file thật trên máy (localFilePath != null) và
/// xử lý xoá. Dùng ở home_page (thay Watch History lúc offline) và màn
/// Saved Videos.
/// Note: Gắn ở 1 màn hình
class DownloadsBloc extends Bloc<DownloadsEvent, DownloadsState> {
  final VideoMetadataCacheRepository _metadataRepo;
  final DownloadRepository _downloadRepo;

  DownloadsBloc({
    VideoMetadataCacheRepository? metadataRepo,
    DownloadRepository? downloadRepo,
  }) : _metadataRepo = metadataRepo ?? VideoMetadataCacheRepository(),
       _downloadRepo = downloadRepo ?? DownloadRepository(),
       super(const DownloadsState()) {
    on<DownloadsLoadRequested>(_onLoadRequested);
    on<DownloadRemoveRequested>(_onRemoveRequested);
  }

  Future<void> _onLoadRequested(
    DownloadsLoadRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    emit(state.copyWith(status: DownloadsStatus.loading));
    try {
      final videos = await _metadataRepo.getAllDownloaded();
      emit(
        state.copyWith(
          status: videos.isEmpty
              ? DownloadsStatus.empty
              : DownloadsStatus.loaded,
          videos: videos,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DownloadsStatus.error,
          errorMessage: 'Không tải được danh sách video đã lưu.',
        ),
      );
    }
  }

  Future<void> _onRemoveRequested(
    DownloadRemoveRequested event,
    Emitter<DownloadsState> emit,
  ) async {
    final index = state.videos.indexWhere(
      (v) => v.id == event.videoId && v.source == event.source,
    );
    if (index == -1) return;
    final target = state.videos[index];

    final updated = List.of(state.videos)..removeAt(index);
    emit(
      state.copyWith(
        status: updated.isEmpty
            ? DownloadsStatus.empty
            : DownloadsStatus.loaded,
        videos: updated,
      ),
    );

    await _downloadRepo.deleteDownload(target);
  }
}
