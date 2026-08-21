import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

enum SearchStatus {
  emptyQuery, // chưa gõ gì
  loading, // đang load trang đầu tiên
  loadingMore, // đang load thêm trang tiếp theo
  loaded,
  noResults, // có query nhưng kết quả rỗng
  error,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<VideoEntity> videos;
  final int currentPage;
  final int totalHits;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.emptyQuery,
    this.query = '',
    this.videos = const [],
    this.currentPage = 1,
    this.totalHits = 0,
    this.errorMessage,
  });

  /// Còn trang tiếp theo hay không — so số video đã tải với totalHits.
  bool get hasMore => videos.length < totalHits;

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<VideoEntity>? videos,
    int? currentPage,
    int? totalHits,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      videos: videos ?? this.videos,
      currentPage: currentPage ?? this.currentPage,
      totalHits: totalHits ?? this.totalHits,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    videos,
    currentPage,
    totalHits,
    errorMessage,
  ];
}
