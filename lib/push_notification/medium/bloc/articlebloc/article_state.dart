import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

sealed class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoadingSuccess extends ArticleState {
  final List<Article> articles;
  final String? actionMessage;
  final ForegroundNotification? foregroundNotification;

  ArticleLoadingSuccess({
    required this.articles,
    this.actionMessage,
    this.foregroundNotification,
  });

  // Tạo hàm copyWith để dễ dàng cập nhật thông báo mà giữ nguyên danh sách bài viết
  ArticleLoadingSuccess copyWith({
    List<Article>? articles,
    String? actionMessage,
    ForegroundNotification? foregroundNotification,
    bool clearNotification =
        false, // Thêm cờ này để xóa thông báo sau khi hiển thị xong
  }) {
    return ArticleLoadingSuccess(
      articles: articles ?? this.articles,
      actionMessage: actionMessage ?? this.actionMessage,
      foregroundNotification: clearNotification
          ? null
          : (foregroundNotification ?? this.foregroundNotification),
    );
  }

  @override
  List<Object?> get props => [articles, actionMessage, foregroundNotification];
}

class ArticleLoadingFailure extends ArticleState {
  final String message;

  const ArticleLoadingFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// Định nghĩa một Object nhỏ để gom nhóm dữ liệu thông báo
class ForegroundNotification {
  final String title;
  final String body;
  final String url;
  final String? sourceName;
  final String? urlToImage;
  final DateTime
  timestamp; // Dùng timestamp để BlocListener phân biệt được tin nhắn mới hoàn toàn

  ForegroundNotification({
    required this.title,
    required this.body,
    required this.url,
    required this.timestamp,
    this.sourceName,
    this.urlToImage,
  });
}
