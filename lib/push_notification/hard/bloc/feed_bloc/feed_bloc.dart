import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/feed_repository.dart';
import '../../services/cache_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _repo = FeedRepository();

  FeedBloc() : super(FeedInitial()) {
    on<FetchFeedEvent>(_onFetch);
    on<LoadMoreFeedEvent>(_onLoadMore);
    on<RefreshFeedEvent>(_onRefresh);
  }

  Future<void> _onFetch(FetchFeedEvent event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      _repo.reset();
      final items = await _repo.getNextPage(limit: 10);
      final cachedItem = await CacheService.getCachedFeed();

      final isOffline =
          items.isNotEmpty &&
          items.every((i) => cachedItem.any((c) => c.id == i.id));

      emit(
        FeedLoaded(
          items: items,
          hasMore: items.length >= 10,
          isOffline: isOffline,
          currentPage: 1,
        ),
      );
    } catch (e) {
      final cached = await CacheService.getCachedFeed();
      emit(FeedError(message: e.toString(), cachedItems: cached));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoaded) return;
    if (state is FeedLoadingMore) return; // Chặn concurrent request
    final current = state as FeedLoaded;
    if (!current.hasMore) return;

    emit(
      FeedLoadingMore(items: current.items, currentPage: current.currentPage),
    );

    try {
      final nextPage = current.currentPage + 1;
      final newItems = await _repo.getNextPage(limit: 10);

      // Lưu cache cộng dồn (thêm những item mới vào cache)
      if (newItems.isNotEmpty) {
        final allItems = [...current.items, ...newItems];
        await CacheService.saveFeedItems(allItems);
      }

      emit(
        current.copyWith(
          items: [...current.items, ...newItems],
          hasMore: newItems.length >= 10,
          currentPage: nextPage,
          hasLoadMoreError: false,
        ),
      );
    } catch (e) {
      // Load more lỗi → đánh dấu lỗi, giữ nguyên list
      emit(current.copyWith(hasLoadMoreError: true));
    }
  }

  Future<void> _onRefresh(
    RefreshFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      _repo.reset();
      final items = await _repo.getNextPage(limit: 10);

      if (items.isNotEmpty) {
        await CacheService.saveFeedItems(items);
      }

      emit(FeedLoaded(items: items, currentPage: 1));
    } catch (e) {
      // Refresh lỗi → giữ nguyên state
    }
  }
}
