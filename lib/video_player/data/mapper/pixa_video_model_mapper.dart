import 'package:flutterpractisetasks/video_player/models/pixa_model.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

extension PixamodelMapper on Pixamodel {
  VideoEntity toVideoEntity() {
    return VideoEntity(
      id: id,
      source: VideoSourceType.pixabay,
      title: name.isNotEmpty ? name : 'Video by $user',
      thumbnailUrl: thumbnail,
      duration: Duration(seconds: duration),
      videoSources: videoSources, // đã sắp large -> medium -> small sẵn
    );
  }
}
