import 'dart:convert';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Đọc + GHI metadata (thumbnail, title, videoSources...) của video đã tải
/// qua Popular/Search. WatchHistoryEntry chỉ lưu id + progress, nên repo
/// này "dựng" lại đủ thông tin để hiển thị/phát lại từ Watch History,
/// kể cả lúc offline.
class VideoMetadataCacheRepository {
  static const _maxCached = 200; // giới hạn tổng số video cache mỗi nguồn

  static String _keyFor(VideoSourceType source) =>
      source == VideoSourceType.pexels
      ? 'cached_videos_pexels'
      : 'cached_videos_pixabay';

  Future<VideoEntity?> getById(String id, VideoSourceType source) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFor(source));
    if (raw == null) return null;

    final list = jsonDecode(raw) as List;
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      if (map['id'] == id) return _fromMap(map, source);
    }
    return null; // video đã bị xoá khỏi cache (vượt giới hạn _maxCached)
  }

  /// Ghi/merge danh sách video vừa tải (1 trang Popular hoặc Search) vào
  /// cache. PHẢI gọi ngay sau khi Repository map xong VideoEntity — nếu
  /// không gọi, HistoryBloc sẽ luôn getById() ra null và Watch History
  /// mãi mãi rỗng dù đã xem bao nhiêu video.
  Future<void> saveAll(List<VideoEntity> videos, VideoSourceType source) async {
    if (videos.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(source);
    final raw = prefs.getString(key);

    final oldList = raw == null
        ? <Map<String, dynamic>>[]
        : (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    final newIds = videos.map((v) => v.id).toSet();
    // Video cũ không nằm trong batch mới thì giữ nguyên; video trùng id
    // bị batch mới ghi đè bằng cách đứng trước trong list kết quả.
    final keepOld = oldList.where((m) => !newIds.contains(m['id'])).toList();

    final merged = [...videos.map(_toMap), ...keepOld];
    final trimmed = merged.length > _maxCached
        ? merged.sublist(0, _maxCached)
        : merged;

    await prefs.setString(key, jsonEncode(trimmed));
  }

  Map<String, dynamic> _toMap(VideoEntity video) => {
    'id': video.id,
    'title': video.title,
    'thumbnailUrl': video.thumbnailUrl,
    'durationSeconds': video.duration.inSeconds,
    'videoSources': video.videoSources,
    'localFilePath': video.localFilePath,
  };

  VideoEntity _fromMap(Map<String, dynamic> map, VideoSourceType source) {
    return VideoEntity(
      id: map['id'] as String,
      source: source,
      title: map['title'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      duration: Duration(seconds: map['durationSeconds'] as int),
      videoSources: (map['videoSources'] as List? ?? [])
          .map((e) => e as String)
          .toList(),
      localFilePath: map['localFilePath'] as String?,
    );
  }
}
