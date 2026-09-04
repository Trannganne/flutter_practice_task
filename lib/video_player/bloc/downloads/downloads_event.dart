import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

sealed class DownloadsEvent extends Equatable {
  const DownloadsEvent();
  @override
  List<Object?> get props => [];
}

/// Load toàn bộ video ĐÃ TẢI THẬT về máy.
class DownloadsLoadRequested extends DownloadsEvent {
  const DownloadsLoadRequested();
}

/// Xoá 1 video đã tải: xoá file thật khỏi disk + gỡ cờ trong cache metadata.
class DownloadRemoveRequested extends DownloadsEvent {
  final String videoId;
  final VideoSourceType source;
  const DownloadRemoveRequested({required this.videoId, required this.source});

  @override
  List<Object?> get props => [videoId, source];
}
