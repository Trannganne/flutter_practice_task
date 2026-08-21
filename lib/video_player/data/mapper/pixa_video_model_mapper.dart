import 'package:flutterpractisetasks/video_player/models/pixa_model.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

extension PixamodelMapper on Pixamodel {
  /// LƯU Ý: Pixamodel hiện chỉ lưu 1 chất lượng (videoLargeUrl), nên
  /// videoSources ở đây chỉ có đúng 1 phần tử — không có source dự phòng
  /// thật sự để fallback. Nếu muốn fallback hoạt động đúng cho cả 2
  /// nguồn, cần bổ sung thêm videoMediumUrl/videoSmallUrl vào Pixamodel
  /// (lấy từ videos.medium.url / videos.small.url trong response gốc).
  VideoEntity toVideoEntity() {
    return VideoEntity(
      id: id,
      source: VideoSourceType.pixabay,
      title: name.isNotEmpty ? name : 'Video by $user',
      thumbnailUrl: thumbnail,
      duration: Duration(seconds: duration),
      videoSources: [videoLargeUrl],
    );
  }
}
