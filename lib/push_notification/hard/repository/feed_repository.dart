import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';
import 'package:flutterpractisetasks/push_notification/hard/services/news_service.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

import '../services/post_service.dart';
import '../services/cache_service.dart';
import '../../../connectivity_check/connectivity_service.dart';

class FeedRepository {
  // Lưu id đã có để dedupe trong session
  //static final Set<String> _seenIds = {};

  static Future<List<FeedItem>> getFeed({int page = 1}) async {
    final hasInternet = await ConnectivityService().hasInternet();

    // Offline → trả về cache
    if (!hasInternet) {
      return (await CacheService.getCachedFeed())
          .skip((page - 1) * 10)
          .take(10)
          .toList();
    }

    // Online → gọi cả 2 API song song
    final results = await Future.wait([
      NewsService.getArticles(page: page),
      PostService.getPosts(page: page),
    ]);

    final articles = results[0] as List<Article>;
    final posts = results[1] as List<Map<String, dynamic>>;

    // Parse về FeedItem
    final feedItems = [
      ...articles.map(FeedItem.fromArticle),
      ...posts.map(FeedItem.fromPost),
    ];
    final seenIds = <String>{};
    print("Before dedupe: ${feedItems.length}");
    print("Seen: ${seenIds.length}");

    // Dedupe — bỏ item đã thấy
    final deduped = feedItems.where((item) {
      if (seenIds.contains(item.id)) return false;
      seenIds.add(item.id);
      return true;
    }).toList();

    print("After dedupe: ${deduped.length}");
    // Sắp xếp mới nhất trước
    deduped.sort(
      (a, b) => (b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );

    // Lưu vào cache
    await CacheService.saveFeedItems(deduped);

    return deduped;
  }
}
