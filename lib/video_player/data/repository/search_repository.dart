import 'package:flutterpractisetasks/video_player/data/mapper/pixa_video_model_mapper.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:flutterpractisetasks/video_player/services/pixabay_api.dart';

class SearchRepository {
  final PixabayApi _api;
  SearchRepository({PixabayApi? api}) : _api = api ?? PixabayApi();

  /// Trả về (videos đã map, totalHits) để Bloc tự tính hasMore.
  Future<({List<VideoEntity> videos, int totalHits})> search({
    required String query,
    required int page,
  }) async {
    final result = await _api.searchVideos(query: query, page: page);
    final videos = result.hits.map((h) => h.toVideoEntity()).toList();
    return (videos: videos, totalHits: result.totalHits);
  }
}
