import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/pixamodel.dart';

enum LoadStatus { initial, loading, success, failed }

class Playerstate extends Equatable {
  final List<Pixamodel> videos;
  final LoadStatus loadStatus;
  final String? actionMessage;

  // Load more
  final bool isLoading;
  final bool hasMore;

  const Playerstate({
    this.loadStatus = LoadStatus.initial,
    this.actionMessage,
    this.videos = const [],
    this.isLoading = true,
    this.hasMore = false,
  });

  Playerstate copyWith({
    List<Pixamodel>? videos,
    LoadStatus? loadStatus,
    String? actionMessage,
    bool? isLoading,
    bool? hasMore,
  }) {
    return Playerstate(
      videos: videos ?? this.videos,
      loadStatus: loadStatus ?? this.loadStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [loadStatus, actionMessage, isLoading, hasMore];
}
