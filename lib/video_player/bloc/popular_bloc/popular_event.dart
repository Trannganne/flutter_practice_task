import 'package:equatable/equatable.dart';

sealed class PopularEvent extends Equatable {
  const PopularEvent();
  @override
  List<Object?> get props => [];
}

/// Gọi 1 lần khi vào tab Popular (page đầu tiên).
class PopularLoadRequested extends PopularEvent {
  const PopularLoadRequested();
}

/// Gọi khi cuộn gần cuối feed — dùng nextPageUrl đã lưu trong state,
/// KHÔNG tự tính số trang.
class PopularLoadMoreRequested extends PopularEvent {
  const PopularLoadMoreRequested();
}

class PopularRetryRequested extends PopularEvent {
  const PopularRetryRequested();
}
