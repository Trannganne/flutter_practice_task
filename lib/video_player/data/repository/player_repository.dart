import 'package:flutterpractisetasks/video_player/models/pixa_model.dart';
import 'package:flutterpractisetasks/video_player/services/player_api.dart';

class PlayerRepository {
  Future<List<Pixamodel>> getVideo(int page) async {
    final result = await PixabayApi().loadVideos(page: page);
    final videos = result.hits;
    return videos;
  }
}
