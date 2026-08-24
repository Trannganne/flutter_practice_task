import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'playback_state.dart';

/// Quản lý VideoPlayerController cho 1 video đang phát: fallback source
/// khi lỗi, buffering, play/pause/seek. KHÔNG liên quan đến việc tải
/// danh sách video (đó là PopularBloc/SearchBloc).
class PlaybackCubit extends Cubit<PlaybackState> {
  VideoPlayerController? _controller;
  List<String> _sources =
      []; // videoSources của VideoEntity, sắp theo quality giảm dần
  int _currentSourceIndex = 0;

  PlaybackCubit() : super(const PlaybackState());

  VideoPlayerController? get controller => _controller;

  Future<void> loadVideo(List<String> sources) async {
    _sources = sources;
    _currentSourceIndex = 0;
    await _initController(_sources[_currentSourceIndex]);
  }

  Future<void> _initController(String url) async {
    // Gỡ listener + dispose controller CŨ trước khi tạo cái mới —
    // thiếu bước này là nguồn gốc bug "nhiều listener chồng nhau"
    // giống module FCM trước đây.
    await _disposeCurrentController();

    emit(state.copyWith(status: PlaybackStatus.loading));

    final newController = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = newController;

    try {
      await newController.initialize();
      // addListener CHỈ gọi ở đây — đúng 1 lần, ngay sau initialize() thành công
      newController.addListener(_onControllerUpdate);
      await newController.play();
      emit(
        state.copyWith(
          status: PlaybackStatus.playing,
          duration: newController.value.duration,
        ),
      );
    } catch (_) {
      _handlePlaybackError();
    }
  }

  /// Gọi mỗi khi VideoPlayerController có thay đổi (position, buffering,
  /// lỗi...). Không setState trực tiếp trong Widget — luôn đi qua Cubit
  /// để UI chỉ cần BlocBuilder<PlaybackCubit, PlaybackState>.
  void _onControllerUpdate() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final value = controller.value;

    if (value.hasError) {
      _handlePlaybackError();
      return;
    }

    emit(
      state.copyWith(
        status: value.isBuffering
            ? PlaybackStatus.buffering
            : (value.isPlaying
                  ? PlaybackStatus.playing
                  : PlaybackStatus.paused),
        position: value.position,
        duration: value.duration,
      ),
    );
  }

  /// Fallback: thử source chất lượng thấp hơn kế tiếp trong videoSources.
  /// Hết list mới báo lỗi thật cho UI (ErrorRetryBanner).
  Future<void> _handlePlaybackError() async {
    final nextIndex = _currentSourceIndex + 1;
    if (nextIndex < _sources.length) {
      _currentSourceIndex = nextIndex;
      emit(state.copyWith(fallbackAttempt: nextIndex));
      await _initController(_sources[nextIndex]);
    } else {
      emit(
        state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: 'Không thể phát video. Vui lòng thử lại.',
        ),
      );
    }
  }

  void retry() {
    if (_sources.isNotEmpty) {
      _currentSourceIndex = 0;
      _initController(_sources[_currentSourceIndex]);
    }
  }

  void togglePlayPause() {
    final controller = _controller;
    if (controller == null) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
  }

  void seekTo(Duration position) => _controller?.seekTo(position);

  Future<void> _disposeCurrentController() async {
    final old = _controller;
    if (old != null) {
      old.removeListener(_onControllerUpdate); // BẮT BUỘC trước dispose
      await old.dispose();
      _controller = null;
    }
  }

  @override
  Future<void> close() async {
    await _disposeCurrentController();
    return super.close();
  }
}
