import 'package:flutterpractisetasks/video_player/data/mapper/pixel_video_model_mapper.dart';
import 'package:flutterpractisetasks/video_player/data/repository/cache_metadata_repository.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:flutterpractisetasks/video_player/services/pexel_video_api.dart';

class PopularRepository {
  final PexelModelApi _api;
  final VideoMetadataCacheRepository _cacheRepo;

  PopularRepository({
    PexelModelApi? api,
    VideoMetadataCacheRepository? cacheRepo,
  }) : _api = api ?? PexelModelApi(),
       _cacheRepo = cacheRepo ?? VideoMetadataCacheRepository();

  Future<({List<VideoEntity> videos, String? nextPageUrl})>
  loadFirstPage() async {
    final result = await _api.loadPopularVideos(page: 1);
    final videos = result.videos.map((v) => v.toVideoEntity()).toList();
    await _cacheRepo.saveAll(
      videos,
      VideoSourceType.pexels,
    ); // cache cho offline history
    return (videos: videos, nextPageUrl: result.nextPage);
  }

  Future<({List<VideoEntity> videos, String? nextPageUrl})> loadNextPage(
    String nextPageUrl,
  ) async {
    final result = await _api.loadNextPage(nextPageUrl);
    final videos = result.videos.map((v) => v.toVideoEntity()).toList();
    await _cacheRepo.saveAll(videos, VideoSourceType.pexels);
    return (videos: videos, nextPageUrl: result.nextPage);
  }
}
