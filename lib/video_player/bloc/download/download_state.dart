import 'package:equatable/equatable.dart';

/// Trạng thái tải CỦA 1 VIDEO CỤ THỂ — dùng cho DownloadCubit gắn theo
/// nút Download. Khác DownloadsState (dùng cho danh sách nhiều video đã
/// tải, hiển thị thay Watch History lúc offline).
enum DownloadStatus { idle, downloading, completed, error }

class DownloadState extends Equatable {
  final DownloadStatus status;
  final double progress; // 0.0 - 1.0
  final String? errorMessage;

  const DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0,
    this.errorMessage,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, progress, errorMessage];
}
