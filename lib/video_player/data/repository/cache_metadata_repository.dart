// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../domain/entities/video_entity.dart';

// /// Đọc lại metadata (thumbnail, title, videoSources...) của video đã cache
// /// khi lướt Popular/Search. WatchHistoryEntry chỉ lưu id nên cần repo này
// /// để "dựng" lại đủ thông tin hiển thị/phát video từ history.
// class VideoMetadataCacheRepository {
//   static String _keyFor(VideoSourceType source) =>
//       source == VideoSourceType.pexels
//       ? 'cached_videos_pexels'
//       : 'cached_videos_pixabay';

//   Future<VideoEntity?> getById(String id, VideoSourceType source) async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(_keyFor(source));
//     if (raw == null) return null;

//     final list = jsonDecode(raw) as List;
//     for (final item in list) {
//       final map = item as Map<String, dynamic>;
//       if (map['id'] == id) {
//         return VideoEntity(
//           id: map['id'] as String,
//           source: source,
//           title: map['title'] as String,
//           thumbnailUrl: map['thumbnailUrl'] as String,
//           duration: Duration(seconds: map['durationSeconds'] as int),
//           localFilePath: map['localFilePath'] as String?,
//         );
//       }
//     }
//     return null; // video đã bị xoá khỏi cache (vd vượt giới hạn 100 video)
//   }
// }

//==================== DEMO với Pixabay model ====================
// Lưu video vào cache
// import 'dart:convert';

// import 'package:flutterpractisetasks/video_player/models/pixa_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class VideoMetadataCacheRepository {
//   static String _keyFor() => 'cached_videos_pixabay';
//   Future<Pixamodel?> getById(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final raw = prefs.getString(_keyFor());
//     if (raw == null) return null;

//     final list = jsonDecode()(raw) as List;
//     for (final item in list) {
//       final map = item as Map<String, dynamic>;
//       if (map['id'] == id) {
//         return Pixamodel.fromJson(map);
//       }
//     }
//     return null; // video đã bị xoá khỏi cache (vd vượt giới hạn 100 video)
//   }
// }
