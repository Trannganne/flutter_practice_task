import 'package:flutterpractisetasks/video_player/data/mapper/pixel_video_model_mapper.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:flutterpractisetasks/video_player/services/pexel_video_api.dart';

class PopularRepository {
  final PexelModelApi _api;
  PopularRepository({PexelModelApi? api}) : _api = api ?? PexelModelApi();

  Future<({List<VideoEntity> videos, String? nextPageUrl})>
  loadFirstPage() async {
    final result = await _api.loadPopularVideos(page: 1);
    return (
      videos: result.videos.map((v) => v.toVideoEntity()).toList(),
      nextPageUrl: result.nextPage,
    );
  }

  /// Gọi thẳng bằng URL next_page Pexels đã trả sẵn — không tự build query.
  Future<({List<VideoEntity> videos, String? nextPageUrl})> loadNextPage(
    String nextPageUrl,
  ) async {
    final result = await _api.loadNextPage(nextPageUrl);
    return (
      videos: result.videos.map((v) => v.toVideoEntity()).toList(),
      nextPageUrl: result.nextPage,
    );
  }
}
