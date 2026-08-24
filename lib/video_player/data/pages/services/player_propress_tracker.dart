import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutterpractisetasks/video_player/data/repository/watch_history_repository.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:video_player/video_player.dart';

/// Gắn theo dõi + lưu progress vào VideoPlayerController. Đặt trong
/// VideoPlayerScreen, KHÔNG đặt trong PlaybackCubit — vì đây là side-effect
/// (ghi SharedPreferences định kỳ), tách riêng khỏi state quản lý UI.
class PlayerProgressTracker with WidgetsBindingObserver {
  final VideoPlayerController controller;
  final WatchHistoryRepository _historyRepo;
  final String videoId;
  final VideoSourceType source;

  Timer? _saveTimer;
  bool _isDisposed = false;

  PlayerProgressTracker({
    required this.controller,
    required this.videoId,
    required this.source,
    WatchHistoryRepository? historyRepo,
  }) : _historyRepo = historyRepo ?? WatchHistoryRepository();

  /// Gọi hàm này sau khi PlaybackCubit đã initialize() xong (controller
  /// khác null) — không gọi sớm hơn.
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);

    // 1) Resume: seek tới vị trí đã lưu trước đó (nếu có)
    final entries = await _historyRepo.getAll();
    for (final e in entries) {
      if (e.videoId == videoId && e.source == source && e.positionSeconds > 0) {
        await controller.seekTo(Duration(seconds: e.positionSeconds));
        break;
      }
    }

    // 2) Throttle: chỉ lưu mỗi 5 giây, không lưu mỗi lần listener bắn
    //    (video_player bắn listener nhiều lần/giây).
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) => _persist());
  }

  Future<void> _persist() async {
    if (_isDisposed) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration.inSeconds == 0) return; // chưa load xong metadata

    await _historyRepo.saveProgress(
      videoId: videoId,
      source: source,
      positionSeconds: position.inSeconds,
      durationSeconds: duration.inSeconds,
    );
  }

  /// Bắt trường hợp user thoát app (background) khi đang xem —
  /// Timer 5s có thể chưa kịp chạy, cần lưu ngay lúc này.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _persist();
    }
  }

  /// Gọi trong dispose() của VideoPlayerScreen.
  Future<void> dispose() async {
    _isDisposed = true;
    _saveTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    await _persist(); // lưu vị trí cuối cùng trước khi rời màn hình
  }
}
