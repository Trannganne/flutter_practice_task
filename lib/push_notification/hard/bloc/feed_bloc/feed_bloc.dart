import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/feed_repository.dart';
import '../../services/cache_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc() : super(FeedInitial()) {
    on<FetchFeedEvent>(_onFetch);
    on<LoadMoreFeedEvent>(_onLoadMore);
    on<RefreshFeedEvent>(_onRefresh);
  }

  Future<void> _onFetch(FetchFeedEvent event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final items = await FeedRepository.getFeed(page: 1);
      final cachedItem = await CacheService.getCachedFeed();

      final isOffline =
          items.isNotEmpty && items.every((i) => cachedItem.contains(i));
      emit(
        FeedLoaded(
          items: items,
          hasMore: items.length >= 10,
          isOffline: isOffline,
          currentPage: 1,
        ),
      );
    } catch (e) {
      // Lỗi → vẫn hiện cache
      final cached = await CacheService.getCachedFeed();
      emit(FeedError(message: e.toString(), cachedItems: cached));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (state is! FeedLoaded) return;
    final current = state as FeedLoaded;
    if (!current.hasMore) return;

    // Hiện loading ở cuối list
    emit(
      FeedLoadingMore(items: current.items, currentPage: current.currentPage),
    );

    try {
      final nextPage = current.currentPage + 1;
      final newItems = await FeedRepository.getFeed(page: nextPage);

      emit(
        current.copyWith(
          items: [...current.items, ...newItems],
          hasMore: newItems.length >= 10,
          currentPage: nextPage,
        ),
      );
    } catch (e) {
      // Load more lỗi → giữ nguyên list cũ
      emit(current);
    }
  }

  Future<void> _onRefresh(
    RefreshFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    try {
      final items = await FeedRepository.getFeed(page: 1);
      emit(FeedLoaded(items: items, currentPage: 1));
    } catch (e) {
      // Refresh lỗi → giữ nguyên state
    }
  }
}
