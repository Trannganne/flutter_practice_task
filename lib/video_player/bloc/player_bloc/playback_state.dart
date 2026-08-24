import 'package:equatable/equatable.dart';

/// Trạng thái của MÀN HÌNH PHÁT VIDEO (buffering, lỗi, vị trí xem).
/// KHÔNG liên quan đến PopularState/SearchState/HistoryState (dùng để
/// tải danh sách video) — đây là Cubit RIÊNG cho việc điều khiển phát
/// 1 video cụ thể.
enum PlaybackStatus { loading, playing, paused, buffering, error }

class PlaybackState extends Equatable {
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final int fallbackAttempt; // đang thử source thứ mấy trong videoSources

  const PlaybackState({
    this.status = PlaybackStatus.loading,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.fallbackAttempt = 0,
  });

  PlaybackState copyWith({
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    int? fallbackAttempt,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage,
      fallbackAttempt: fallbackAttempt ?? this.fallbackAttempt,
    );
  }

  @override
  List<Object?> get props => [
    status,
    position,
    duration,
    errorMessage,
    fallbackAttempt,
  ];
}
