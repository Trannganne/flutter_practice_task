import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

/// Load toàn bộ danh sách lịch sử xem (gọi khi vào tab History,
/// hoặc khi cần refresh sau khi quay lại từ Player).
class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

/// Xoá 1 video khỏi lịch sử xem.
class HistoryEntryDeleted extends HistoryEvent {
  final String videoId;
  final VideoSourceType source;
  const HistoryEntryDeleted({required this.videoId, required this.source});

  @override
  List<Object?> get props => [videoId, source];
}
