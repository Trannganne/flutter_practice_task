import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

/// Bắn mỗi khi user gõ vào ô search. Debounce xử lý ở Bloc (không phải UI)
/// để logic debounce nằm đúng chỗ, dễ test.
class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchLoadMoreRequested extends SearchEvent {
  const SearchLoadMoreRequested();
}

/// Dùng cho nút Retry trên ErrorRetryBanner — gọi lại đúng query hiện tại.
class SearchRetryRequested extends SearchEvent {
  const SearchRetryRequested();
}
