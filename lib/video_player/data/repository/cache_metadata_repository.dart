import 'dart:convert';
import 'package:flutter/foundation.dart';
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

    // FIX: video vừa Download mà xuất hiện lại trong batch mới (ví dụ
    // PopularBloc load lại trang 1 mỗi lần mở app) từng bị MẤT cờ "đã
    // tải" — vì VideoEntity fresh từ API (qua mapper) luôn có
    // localFilePath: null, và trước đây batch mới ghi đè thẳng lên entry
    // cũ không giữ lại field này. File thật vẫn còn trên disk, chỉ là
    // app không còn biết tới nó -> tưởng như "quay về trạng thái chưa
    // lưu". Giờ tra bảng id -> localFilePath CŨ trước, rồi khôi phục lại
    // cho entry mới nếu có.
    final oldLocalPaths = <String, String?>{
      for (final m in oldList) m['id'] as String: m['localFilePath'] as String?,
    };

    final newIds = videos.map((v) => v.id).toSet();
    // Video cũ không nằm trong batch mới thì giữ nguyên; video trùng id
    // bị batch mới ghi đè (title/thumbnail/videoSources có thể đã đổi),
    // NHƯNG localFilePath được khôi phục lại từ bản cũ nếu có.
    final keepOld = oldList.where((m) => !newIds.contains(m['id'])).toList();

    final freshMapped = videos.map((v) {
      final map = _toMap(v);
      final preservedPath = oldLocalPaths[v.id];
      if (preservedPath != null) map['localFilePath'] = preservedPath;
      return map;
    }).toList();

    final merged = [...freshMapped, ...keepOld];
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

  /// Đánh dấu 1 video đã tải xong file thật — ghi [localFilePath] vào
  /// đúng entry đang có trong cache (entry BẮT BUỘC đã tồn tại từ trước,
  /// vì user chỉ bấm Download được từ 1 video đã lướt qua Popular/Search,
  /// tức đã qua saveAll() lúc fetch list). Gọi bởi DownloadRepository
  /// ngay sau khi tải file xong.
  Future<void> markDownloaded(
    String id,
    VideoSourceType source,
    String localFilePath,
  ) async {
    await _updateLocalFilePath(id, source, localFilePath);
  }

  /// Gỡ cờ "đã tải" (chỉ set localFilePath = null, KHÔNG xoá metadata) —
  /// gọi sau khi DownloadRepository đã xoá file thật khỏi disk.
  Future<void> clearDownload(String id, VideoSourceType source) async {
    await _updateLocalFilePath(id, source, null);
  }

  Future<void> _updateLocalFilePath(
    String id,
    VideoSourceType source,
    String? localFilePath,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(source);
    final raw = prefs.getString(key);
    if (raw == null) {
      // DEBUG: nếu dòng này in ra khi bấm Download -> cache rỗng hoàn
      // toàn cho source này, tức saveAll() chưa từng chạy (video chưa
      // qua Popular/Search) -> không có gì để markDownloaded() ghi vào.
      debugPrint(
        '[CacheMetadata] KHÔNG tìm thấy cache cho source=$source (raw null) '
        '-> markDownloaded/clearDownload bị bỏ qua, id=$id',
      );
      return;
    }

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final index = list.indexWhere((m) => m['id'] == id);
    if (index == -1) {
      // DEBUG: cache CÓ tồn tại cho source này, nhưng không có entry nào
      // khớp đúng id -> id bị lệch (sai kiểu, sai nguồn) hoặc entry đã bị
      // trim do vượt _maxCached.
      debugPrint(
        '[CacheMetadata] Cache có ${list.length} video cho source=$source '
        'nhưng KHÔNG có id=$id -> markDownloaded/clearDownload bị bỏ qua',
      );
      return;
    }

    list[index] = {...list[index], 'localFilePath': localFilePath};
    await prefs.setString(key, jsonEncode(list));
    debugPrint(
      '[CacheMetadata] Đã ghi localFilePath=$localFilePath cho id=$id, source=$source',
    );
  }

  /// Quét cả 2 nguồn, trả về mọi video ĐÃ có file thật trên máy — dùng
  /// cho "Downloaded Videos" (thay Watch History lúc offline) và màn
  /// Saved Videos.
  Future<List<VideoEntity>> getAllDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <VideoEntity>[];

    for (final source in VideoSourceType.values) {
      final raw = prefs.getString(_keyFor(source));
      if (raw == null) continue;

      final list = jsonDecode(raw) as List;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        if (map['localFilePath'] != null) {
          result.add(_fromMap(map, source));
        }
      }
    }
    return result;
  }
}
