import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/data/repository/download_repository.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'download_state.dart';

/// Quản lý việc tải 1 video CỤ THỂ về máy — Cubit gắn theo instance của
/// DownloadButton (giống PlaybackCubit gắn theo instance VideoPlayerScreen),
/// KHÔNG dùng chung 1 instance cho nhiều nút vì mỗi video cần progress
/// độc lập.
class DownloadCubit extends Cubit<DownloadState> {
  final DownloadRepository _repository;
  CancelToken? _cancelToken;

  DownloadCubit({DownloadRepository? repository})
    : _repository = repository ?? DownloadRepository(),
      super(const DownloadState());

  /// Nếu video đã có localFilePath từ trước ( đã tải) thì khởi
  /// tạo Cubit thẳng ở completed — tránh hiện lại nút Download.
  factory DownloadCubit.forVideo(
    VideoEntity video, {
    DownloadRepository? repository,
  }) {
    final cubit = DownloadCubit(repository: repository);
    if (video.isDownloaded) {
      cubit.emit(
        const DownloadState(status: DownloadStatus.completed, progress: 1),
      );
    }
    return cubit;
  }

  Future<void> download(VideoEntity video) async {
    if (state.status == DownloadStatus.downloading) return;

    _cancelToken = CancelToken();
    emit(state.copyWith(status: DownloadStatus.downloading, progress: 0));

    try {
      await _repository.download(
        video: video,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          if (total <= 0 || isClosed) return;
          emit(state.copyWith(progress: received / total));
        },
      );
      if (!isClosed) {
        emit(state.copyWith(status: DownloadStatus.completed, progress: 1));
      }
    } catch (e) {
      if (isClosed) return;
      if (e is DioException && CancelToken.isCancel(e)) {
        emit(const DownloadState()); // user tự huỷ -> về idle
        return;
      }
      emit(
        state.copyWith(
          status: DownloadStatus.error,
          errorMessage: 'Tải video thất bại. Vui lòng thử lại.',
        ),
      );
    }
  }

  void cancel() => _cancelToken?.cancel();

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
