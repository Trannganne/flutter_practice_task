import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

/// Lưu tiến độ xem của 1 video — dùng để hiện thanh progress trong
/// Watch History (giống mockup "02:10 / 04:30") và để resume phát
/// tiếp khi user mở lại video đó.
class WatchHistoryEntry {
  final String videoId;
  final VideoSourceType source;
  final int positionSeconds; // đã xem tới giây thứ mấy
  final int durationSeconds; // tổng thời lượng video
  final DateTime watchedAt; // lần cập nhật gần nhất

  const WatchHistoryEntry({
    required this.videoId,
    required this.source,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.watchedAt,
  });

  double get progressRatio =>
      durationSeconds == 0 ? 0 : positionSeconds / durationSeconds;

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'source': source.name,
    'positionSeconds': positionSeconds,
    'durationSeconds': durationSeconds,
    'watchedAt': watchedAt.millisecondsSinceEpoch,
  };

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WatchHistoryEntry(
      videoId: json['videoId'] as String,
      source: VideoSourceType.values.byName(json['source'] as String),
      positionSeconds: json['positionSeconds'] as int,
      durationSeconds: json['durationSeconds'] as int,
      watchedAt: DateTime.fromMillisecondsSinceEpoch(json['watchedAt'] as int),
    );
  }
}
