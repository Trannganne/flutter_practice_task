import '../models/pexel_video_model.dart';

/// Pexels trả sẵn URL đầy đủ cho trang tiếp theo (next_page), khác hẳn
/// Pixabay (tự tính page + so totalHits) — nên không dùng chung 1 wrapper
/// class với PixabaySearchResult.
class PexelSearchResult {
  final List<PexelVideoModel> videos;
  final String? nextPage; // null = đã hết trang

  const PexelSearchResult({required this.videos, this.nextPage});

  factory PexelSearchResult.fromJson(Map<String, dynamic> json) {
    final rawVideos = json['videos'] as List? ?? [];
    return PexelSearchResult(
      videos: rawVideos
          .map((v) => PexelVideoModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }
}
