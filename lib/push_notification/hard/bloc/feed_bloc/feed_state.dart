import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feeditemmodel.dart';

sealed class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<FeedItem> items;
  final bool hasMore; // còn trang tiếp không
  final bool isOffline; // đang dùng cache
  final int currentPage;

  FeedLoaded({
    required this.items,
    this.hasMore = true,
    this.isOffline = false,
    this.currentPage = 1,
  });

  FeedLoaded copyWith({
    List<FeedItem>? items,
    bool? hasMore,
    bool? isOffline,
    int? currentPage,
  }) {
    return FeedLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FeedLoadingMore extends FeedLoaded {
  FeedLoadingMore({required super.items, super.currentPage});
}

class FeedError extends FeedState {
  final String message;
  final List<FeedItem> cachedItems; // vẫn hiện cache khi lỗi
  FeedError({required this.message, this.cachedItems = const []});
}
