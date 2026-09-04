import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

enum DownloadsStatus { initial, loading, loaded, empty, error }

/// Trạng thái của danh sách video ĐÃ TẢI (hiển thị thay Watch History
/// lúc offline, và ở màn Saved Videos). Khác DownloadState (1 lượt tải
/// cụ thể của DownloadCubit).
class DownloadsState extends Equatable {
  final DownloadsStatus status;
  final List<VideoEntity> videos;
  final String? errorMessage;

  const DownloadsState({
    this.status = DownloadsStatus.initial,
    this.videos = const [],
    this.errorMessage,
  });

  DownloadsState copyWith({
    DownloadsStatus? status,
    List<VideoEntity>? videos,
    String? errorMessage,
  }) {
    return DownloadsState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, videos, errorMessage];
}
