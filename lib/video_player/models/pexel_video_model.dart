/// 1 file chất lượng video cụ thể trong video_files[] của Pexels.
/// Danh sách nhiều PexelVideoFile (hd, sd...) chính là nguồn cho
/// videoSources/fallback khi normalize sang VideoEntity.
class PexelVideoFile {
  final int id;
  final String quality; // "hd", "sd", "hls"
  final String fileType; // "video/mp4"
  final int? width;
  final int? height;
  final String link; // URL video thật, dùng để phát

  const PexelVideoFile({
    required this.id,
    required this.quality,
    required this.fileType,
    required this.link,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'quality': quality,
    'file_type': fileType,
    'width': width,
    'height': height,
    'link': link,
  };

  factory PexelVideoFile.fromJson(Map<String, dynamic> json) {
    return PexelVideoFile(
      id: json['id'] as int,
      quality: json['quality'] as String? ?? '',
      fileType: json['file_type'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      link: json['link'] as String,
    );
  }
}

class PexelVideoModel {
  final int id;
  final String url; // trang video trên pexels.com (không phải link phát)
  final int width;
  final int height;
  final int duration; // giây
  final String thumbnailUrl; // field "image" trong response gốc
  final String userName;
  final String userUrl;
  final List<PexelVideoFile> videoFiles;

  const PexelVideoModel({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    required this.duration,
    required this.thumbnailUrl,
    required this.userName,
    required this.userUrl,
    required this.videoFiles,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'width': width,
    'height': height,
    'duration': duration,
    'image': thumbnailUrl,
    'user': {'name': userName, 'url': userUrl},
    'video_files': videoFiles.map((f) => f.toJson()).toList(),
  };

  factory PexelVideoModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>?;
    final rawFiles = json['video_files'] as List? ?? [];

    return PexelVideoModel(
      id: json['id'] as int,
      url: json['url'] as String,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      thumbnailUrl: json['image'] as String? ?? '',
      userName: userMap?['name'] as String? ?? '',
      userUrl: userMap?['url'] as String? ?? '',
      videoFiles: rawFiles
          .map((f) => PexelVideoFile.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
