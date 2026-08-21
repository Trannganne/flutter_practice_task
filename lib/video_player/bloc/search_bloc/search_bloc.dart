import 'package:bloc/bloc.dart';
import 'package:flutterpractisetasks/video_player/data/repository/search_repository.dart';
import 'package:stream_transform/stream_transform.dart';
import 'search_event.dart';
import 'search_state.dart';

/// EventTransformer debounce riêng cho SearchQueryChanged — restartable()
/// đảm bảo nếu user gõ tiếp trong lúc đang chờ, request cũ bị huỷ luôn,
/// không tốn API call cho những ký tự đã lỗi thời.
EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _repository;
  // static const _perPage = 20;

  SearchBloc({SearchRepository? repository})
    : _repository = repository ?? SearchRepository(),
      super(const SearchState()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: _debounce(const Duration(milliseconds: 500)),
    );
    on<SearchLoadMoreRequested>(_onLoadMoreRequested);
    on<SearchRetryRequested>(_onRetryRequested);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const SearchState()); // reset về trạng thái ban đầu
      return;
    }

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        query: query,
        currentPage: 1,
      ),
    );
    await _fetchPage(query: query, page: 1, emit: emit, append: false);
  }

  Future<void> _onLoadMoreRequested(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    // Chặn gọi trùng khi đang loading/loadingMore, hoặc đã hết trang.
    if (state.status == SearchStatus.loadingMore ||
        state.status == SearchStatus.loading ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(status: SearchStatus.loadingMore));
    await _fetchPage(
      query: state.query,
      page: state.currentPage + 1,
      emit: emit,
      append: true,
    );
  }

  Future<void> _onRetryRequested(
    SearchRetryRequested event,
    Emitter<SearchState> emit,
  ) async {
    if (state.query.isEmpty) return;
    emit(state.copyWith(status: SearchStatus.loading));
    await _fetchPage(query: state.query, page: 1, emit: emit, append: false);
  }

  Future<void> _fetchPage({
    required String query,
    required int page,
    required Emitter<SearchState> emit,
    required bool append,
  }) async {
    try {
      final result = await _repository.search(query: query, page: page);

      final combinedVideos = append
          ? [...state.videos, ...result.videos]
          : result.videos;

      emit(
        state.copyWith(
          status: combinedVideos.isEmpty
              ? SearchStatus.noResults
              : SearchStatus.loaded,
          videos: combinedVideos,
          currentPage: page,
          totalHits: result.totalHits,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.error,
          errorMessage: 'Không tải được video. Vui lòng thử lại.',
        ),
      );
    }
  }
}
