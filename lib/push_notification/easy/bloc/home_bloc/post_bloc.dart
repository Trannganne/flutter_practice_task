import 'package:bloc/bloc.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/home_bloc/post_event.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/home_bloc/post_state.dart';
import 'package:flutterpractisetasks/push_notification/easy/services/api_service.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostInitial()) {
    on<FetchPostEvent>(_onFetchPosts);
  }

  Future<void> _onFetchPosts(
    FetchPostEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final posts = await ApiService.getPosts();
      emit(
        PostLoadSuccess(
          posts: posts,
          actionMessage: "Tải danh sách Posts thành công!",
        ),
      );
    } catch (e) {
      emit(PostLoadFailure(message: 'Tải danh sách posts thất bại: $e'));
    }
  }
}
