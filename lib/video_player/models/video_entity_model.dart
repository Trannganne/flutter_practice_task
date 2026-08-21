enum VideoSourceType { pexels, pixabay }

/// Entity chuẩn hoá từ 2 API (Pexels + Pixabay) — theo đúng thiết kế
/// đã chốt ở phần nghiệp vụ. Đây là bản tối thiểu đủ dùng cho VideoCard;
/// khi build Repository sẽ bổ sung videoSources (list url theo quality)
/// và cachedAt cho phần cache metadata.
class VideoEntity {
  final String id;
  final VideoSourceType source;
  final String title;
  final String thumbnailUrl;
  final Duration duration;
  final List<String>
  videoSources; // sắp theo chất lượng giảm dần, dùng cho fallback
  final String? localFilePath; // null = chưa download, có giá trị = đã tải về

  const VideoEntity({
    required this.id,
    required this.source,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.videoSources,
    this.localFilePath,
  });

  bool get isDownloaded => localFilePath != null;
}
