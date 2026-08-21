import 'package:flutterpractisetasks/video_player/models/domain/watch_history_entry.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

/// Kết quả join giữa WatchHistoryEntry (progress) và VideoEntity (metadata)
/// — dùng riêng cho UI HistoryScreen, không phải domain entity gốc.
class HistoryItem {
  final VideoEntity video;
  final WatchHistoryEntry progress;

  const HistoryItem({required this.video, required this.progress});
}
