import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

enum PopularStatus { initial, loading, loadingMore, loaded, error }

class PopularState extends Equatable {
  final PopularStatus status;
  final List<VideoEntity> videos;
  final String? nextPageUrl; // null sau khi load = đã hết trang
  final String? errorMessage;

  const PopularState({
    this.status = PopularStatus.initial,
    this.videos = const [],
    this.nextPageUrl,
    this.errorMessage,
  });

  /// Chỉ coi là "còn trang tiếp" khi ĐÃ load ít nhất 1 lần (status != initial)
  /// VÀ nextPageUrl có giá trị — tránh nhầm "chưa load" với "đã hết trang",
  /// vì cả 2 trường hợp nextPageUrl đều đang null.
  bool get hasMore => status != PopularStatus.initial && nextPageUrl != null;

  PopularState copyWith({
    PopularStatus? status,
    List<VideoEntity>? videos,
    String? nextPageUrl,
    bool clearNextPageUrl = false,
    String? errorMessage,
  }) {
    return PopularState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      nextPageUrl: clearNextPageUrl ? null : (nextPageUrl ?? this.nextPageUrl),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, videos, nextPageUrl, errorMessage];
}
