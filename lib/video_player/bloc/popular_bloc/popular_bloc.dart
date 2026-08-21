import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/video_player/data/repository/popular_repository.dart';
import 'popular_event.dart';
import 'popular_state.dart';

class PopularBloc extends Bloc<PopularEvent, PopularState> {
  final PopularRepository _repository;

  PopularBloc({PopularRepository? repository})
    : _repository = repository ?? PopularRepository(),
      super(const PopularState()) {
    on<PopularLoadRequested>(_onLoadRequested);
    on<PopularLoadMoreRequested>(_onLoadMoreRequested);
    on<PopularRetryRequested>(_onRetryRequested);
  }

  Future<void> _onLoadRequested(
    PopularLoadRequested event,
    Emitter<PopularState> emit,
  ) async {
    // Chặn gọi lại nếu đã load rồi (vd BlocProvider bị rebuild) — Popular
    // không cần refresh liên tục như History, giữ nguyên feed đã có.
    if (state.status != PopularStatus.initial) return;

    emit(state.copyWith(status: PopularStatus.loading));

    try {
      final result = await _repository.loadFirstPage();
      emit(
        state.copyWith(
          status: PopularStatus.loaded,
          videos: result.videos,
          nextPageUrl: result.nextPageUrl,
          clearNextPageUrl: result.nextPageUrl == null,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi không tải được video: $e');
      emit(
        state.copyWith(
          status: PopularStatus.error,
          errorMessage: 'Không tải được video. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> _onLoadMoreRequested(
    PopularLoadMoreRequested event,
    Emitter<PopularState> emit,
  ) async {
    // Chặn gọi trùng khi đang loading, hoặc đã hết trang (nextPageUrl null).
    if (state.status == PopularStatus.loadingMore ||
        state.status == PopularStatus.loading ||
        !state.hasMore) {
      return;
    }

    emit(state.copyWith(status: PopularStatus.loadingMore));

    try {
      // state.nextPageUrl chắc chắn khác null ở đây nhờ đã check state.hasMore.
      final result = await _repository.loadNextPage(state.nextPageUrl!);
      emit(
        state.copyWith(
          status: PopularStatus.loaded,
          videos: [...state.videos, ...result.videos], // nối, không thay thế
          nextPageUrl: result.nextPageUrl,
          clearNextPageUrl: result.nextPageUrl == null,
        ),
      );
    } catch (e) {
      // Lỗi khi load more KHÔNG xoá videos cũ đã có — chỉ báo lỗi để
      // hiện ErrorRetryBanner bên dưới feed, đúng theo mockup.
      emit(
        state.copyWith(
          status: PopularStatus.error,
          errorMessage: 'Không tải thêm được video.',
        ),
      );
    }
  }

  Future<void> _onRetryRequested(
    PopularRetryRequested event,
    Emitter<PopularState> emit,
  ) async {
    // Retry sau lỗi load more: thử lại đúng nextPageUrl cũ, không load lại
    // từ đầu (tránh mất vị trí cuộn và load trùng video đã có).
    if (state.videos.isNotEmpty && state.nextPageUrl != null) {
      add(const PopularLoadMoreRequested());
      return;
    }

    // Lỗi ngay từ lần load đầu tiên (chưa có video nào) — load lại từ đầu.
    emit(state.copyWith(status: PopularStatus.initial));
    add(const PopularLoadRequested());
  }
}
