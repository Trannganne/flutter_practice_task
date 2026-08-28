import 'package:flutterpractisetasks/video_player/data/mapper/pixa_video_model_mapper.dart';
import 'package:flutterpractisetasks/video_player/data/repository/cache_metadata_repository.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:flutterpractisetasks/video_player/services/pixabay_api.dart';

class SearchRepository {
  final PixabayApi _api;
  final VideoMetadataCacheRepository _cacheRepo;

  SearchRepository({PixabayApi? api, VideoMetadataCacheRepository? cacheRepo})
    : _api = api ?? PixabayApi(),
      _cacheRepo = cacheRepo ?? VideoMetadataCacheRepository();

  Future<({List<VideoEntity> videos, int totalHits})> search({
    required String query,
    required int page,
  }) async {
    final result = await _api.searchVideos(query: query, page: page);
    final videos = result.hits.map((h) => h.toVideoEntity()).toList();
    await _cacheRepo.saveAll(videos, VideoSourceType.pixabay);
    return (videos: videos, totalHits: result.totalHits);
  }
}
