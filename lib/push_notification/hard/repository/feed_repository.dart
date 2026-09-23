import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';
import 'package:flutterpractisetasks/push_notification/hard/services/news_service.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

import '../services/post_service.dart';
import '../services/cache_service.dart';
import '../../../connectivity_check/connectivity_service.dart';

class FeedResult {
  final List<FeedItem> items;
  final bool isOffline;
  FeedResult({required this.items, required this.isOffline});
}

class FeedRepository {
  int _newsPage = 1;
  int _postsPage = 1;
  bool _newsHasMore = true;
  bool _postsHasMore = true;

  final List<FeedItem> _buffer = [];
  final Set<String> _seenIds = {};

  void reset() {
    _newsPage = 1;
    _postsPage = 1;
    _newsHasMore = true;
    _postsHasMore = true;
    _buffer.clear();
    _seenIds.clear();
  }

  Future<FeedResult> getNextPage({int limit = 10}) async {
    final hasInternet = await ConnectivityService().hasInternet();

    if (!hasInternet) {
      // Offline fallback
      final cached = await CacheService.getCachedFeed();
      final startIndex = _seenIds.length;
      final items = cached.skip(startIndex).take(limit).toList();
      _seenIds.addAll(items.map((e) => e.id));
      return FeedResult(items: items, isOffline: true);
    }

    // Online fetch
    while (_buffer.length < limit && (_newsHasMore || _postsHasMore)) {
      final futures = <Future<List<FeedItem>>>[];

      final fetchNews = _newsHasMore;
      final fetchPosts = _postsHasMore;

      if (fetchNews) {
        futures.add(
          NewsService.getArticles(page: _newsPage).then((articles) {
            final items = articles.map(FeedItem.fromArticle).toList();
            if (items.isEmpty) _newsHasMore = false;
            return items;
          }),
        );
      }

      if (fetchPosts) {
        futures.add(
          PostService.getPosts(page: _postsPage).then((posts) {
            final items = posts.map(FeedItem.fromPost).toList();
            if (items.isEmpty) _postsHasMore = false;
            return items;
          }),
        );
      }

      if (futures.isNotEmpty) {
        // Nếu 1 trong 2 lỗi, Future.wait ném lỗi ra ngoài.
        // Page chưa được tăng, buffer chưa được cập nhật -> retry sẽ gọi lại đúng trang.
        final results = await Future.wait(futures);

        final newItems = <FeedItem>[];
        for (final res in results) {
          newItems.addAll(res);
        }

        for (final item in newItems) {
          if (!_seenIds.contains(item.id)) {
            _seenIds.add(item.id);
            _buffer.add(item);
          }
        }

        if (fetchNews) _newsPage++;
        if (fetchPosts) _postsPage++;
      }
    }

    _buffer.sort(
      (a, b) => (b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );

    final resultCount = _buffer.length < limit ? _buffer.length : limit;
    final result = _buffer.sublist(0, resultCount);
    _buffer.removeRange(0, resultCount);

    return FeedResult(items: result, isOffline: false);
  }
}
