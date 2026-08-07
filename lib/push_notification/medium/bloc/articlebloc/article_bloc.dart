import 'package:bloc/bloc.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/notificationService.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/apiservice.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/articlebloc/article_event.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/articlebloc/article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  ArticleBloc() : super(ArticleInitial()) {
    // Đăng ký lắng nghe sự kiện từ Service ngay khi Bloc được khởi tạo
    NotificationService.onForegroundMessageReceived = (message) {
      add(OnIncomingNotificationEvent(message: message));
    };
    //======================================================================
    on<FetchArticleEvent>(_onFetchArticles);

    // Trong file ArticleBloc của bạn:
    on<OnIncomingNotificationEvent>((event, emit) {
      if (state is ArticleLoadingSuccess) {
        final currentState = state as ArticleLoadingSuccess;

        // 1. Trích xuất title và body từ biến event.message ra đây:
        final String fcmTitle =
            event.message.notification?.title ?? "Thông báo mới";
        final String fcmBody =
            event.message.notification?.body ?? "Bạn có một tin nhắn mới.";
        final String fcmUrl =
            event.message.data['url'] ?? "Bạn có một tin nhắn mới.";
        final String fcmUrlToImage = event.message.data['urlToImage'] ?? "";

        // 2. Đập dữ liệu vừa bóc tách vào State để truyền xuống UI
        emit(
          currentState.copyWith(
            foregroundNotification: ForegroundNotification(
              title: fcmTitle,
              body: fcmBody,
              url: fcmUrl,
              urlToImage: fcmUrlToImage,
              timestamp: DateTime.now(),
            ),
          ),
        );
      }
    });
  }

  Future<void> _onFetchArticles(
    FetchArticleEvent event,
    Emitter<ArticleState> emit,
  ) async {
    emit(ArticleLoading());
    try {
      final articles = await Apiservice.getArticles(category: event.category);

      emit(
        ArticleLoadingSuccess(
          articles: articles,
          actionMessage: 'Tải danh sách articles thành công!',
        ),
      );
    } catch (e, s) {
      print(e);
      print(s);
      emit(ArticleLoadingFailure(message: 'Không thể tải danh sách bài báo!'));
    }
  }
}
