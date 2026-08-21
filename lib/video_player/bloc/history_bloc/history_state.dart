import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/domain/history_item.dart';

enum HistoryStatus { initial, loading, loaded, empty, error }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<HistoryItem> items;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryItem>? items,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
