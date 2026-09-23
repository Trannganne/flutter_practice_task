import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';

sealed class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedItem> items;
  final bool hasMore;
  final bool isOffline;
  final int currentPage;
  final bool hasLoadMoreError; // Thêm cờ để biết load more bị lỗi

  const FeedLoaded({
    required this.items,
    this.hasMore = true,
    this.isOffline = false,
    this.currentPage = 1,
    this.hasLoadMoreError = false,
  });

  FeedLoaded copyWith({
    List<FeedItem>? items,
    bool? hasMore,
    bool? isOffline,
    int? currentPage,
    bool? hasLoadMoreError,
  }) {
    return FeedLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      currentPage: currentPage ?? this.currentPage,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }

  @override
  List<Object?> get props => [
    items,
    hasMore,
    isOffline,
    currentPage,
    hasLoadMoreError,
  ];
}

class FeedLoadingMore extends FeedLoaded {
  const FeedLoadingMore({required super.items, super.currentPage})
    : super(hasLoadMoreError: false);
}

class FeedError extends FeedState {
  final String message;
  final List<FeedItem> cachedItems;
  final bool isOfflineError;
  const FeedError({required this.message, this.cachedItems = const [], this.isOfflineError = false});

  @override
  List<Object?> get props => [message, cachedItems, isOfflineError];
}
