import 'dart:convert';
import 'package:flutterpractisetasks/video_player/models/domain/watch_history_entry.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchHistoryRepository {
  static const _key = 'watch_history';
  static const _maxEntries = 100; // giới hạn cache, dev tự quyết theo đã chốt

  Future<List<WatchHistoryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => WatchHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lưu/cập nhật tiến độ xem. Nếu videoId+source đã tồn tại → ghi đè
  /// (update position + watchedAt), KHÔNG thêm entry trùng.
  Future<void> saveProgress({
    required String videoId,
    required VideoSourceType source,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    final entries = await getAll();

    final existingIndex = entries.indexWhere(
      (e) => e.videoId == videoId && e.source == source,
    );

    final updatedEntry = WatchHistoryEntry(
      videoId: videoId,
      source: source,
      positionSeconds: positionSeconds,
      durationSeconds: durationSeconds,
      watchedAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      entries[existingIndex] = updatedEntry;
    } else {
      entries.insert(0, updatedEntry); // mới nhất lên đầu
    }

    // Cắt bớt nếu vượt giới hạn, xoá các entry cũ nhất (cuối list)
    final trimmed = entries.length > _maxEntries
        ? entries.sublist(0, _maxEntries)
        : entries;

    await _persist(trimmed);
  }

  Future<void> remove(String videoId, VideoSourceType source) async {
    final entries = await getAll();
    entries.removeWhere((e) => e.videoId == videoId && e.source == source);
    await _persist(entries);
  }

  Future<void> _persist(List<WatchHistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
