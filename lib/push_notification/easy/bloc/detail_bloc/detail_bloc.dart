import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/detail_bloc/detail_event.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/detail_bloc/detail_state.dart';
import 'package:flutterpractisetasks/push_notification/easy/services/api_service.dart';

class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  PostDetailBloc() : super(PostDetailInitial()) {
    on<FetchDetailPostEvent>(_onFetchDetailPost);
  }

  Future<void> _onFetchDetailPost(
    FetchDetailPostEvent event,
    Emitter<PostDetailState> emit,
  ) async {
    emit(PostDetailLoading());

    try {
      final post = await ApiService.getPostById(event.postId);

      emit(
        PostDetailLoadSuccess(
          post: post,
          actionMessage: 'Tải chi tiết bài đăng thành công!',
        ),
      );
    } catch (e) {
      emit(
        PostDetailLoadFailure(message: 'Tải chi tiết bài đăng thất bại: $e'),
      );
    }
  }
}
