import 'package:flutterpractisetasks/video_player/models/pexel_video_model.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

extension PexelVideoModelMapper on PexelVideoModel {
  /// Sắp video_files theo chất lượng giảm dần (hd trước, sd sau) để
  /// PlayerCubit fallback đúng thứ tự khi nguồn đầu tiên lỗi.
  VideoEntity toVideoEntity() {
    final sortedFiles = [...videoFiles]
      ..sort((a, b) => (b.height ?? 0).compareTo(a.height ?? 0));

    return VideoEntity(
      id: id.toString(),
      source: VideoSourceType.pexels,
      title: userName.isNotEmpty ? 'Video by $userName' : 'Pexels video',
      thumbnailUrl: thumbnailUrl,
      duration: Duration(seconds: duration),
      videoSources: sortedFiles.map((f) => f.link).toList(),
    );
  }
}
