class Pixamodel {
  final String id;
  final List<String> tags;
  final int duration;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final String user;
  final String userImageUrl;
  final String userUrl;
  final String name;

  // Các chất lượng video, sắp sẵn theo thứ tự giảm dần (large -> medium ->
  // small) để dùng trực tiếp cho fallback, không cần sort lại ở mapper.
  final List<String> videoSources;
  final int size; // size của bản large, dùng hiển thị thông tin nếu cần

  final String thumbnail;

  const Pixamodel({
    required this.id,
    required this.tags,
    required this.duration,
    required this.user,
    required this.userImageUrl,
    required this.userUrl,
    required this.videoSources,
    required this.thumbnail,
    required this.size,
    required this.name,
    this.comments = 0,
    this.likes = 0,
    this.downloads = 0,
    this.views = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tags': tags,
      'duration': duration,
      'videoSources': videoSources,
      'user': user,
      'userImageUrl': userImageUrl,
      'userUrl': userUrl,
      'size': size,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'comments': comments,
      'name': name,
      'thumbnail': thumbnail,
    };
  }

  /// LƯU Ý: [json] ở đây là 1 phần tử ĐÃ LẤY RA từ list `hits` của response
  /// Pixabay, không phải truyền thẳng cả response gốc vào.
  factory Pixamodel.fromJson(Map<String, dynamic> json) {
    final videos = json['videos'] as Map<String, dynamic>;
    final large = videos['large'] as Map<String, dynamic>;
    final medium = videos['medium'] as Map<String, dynamic>?;
    final small = videos['small'] as Map<String, dynamic>?;
    final tiny = videos['tiny'] as Map<String, dynamic>?;

    // Gom các chất lượng có thật trong response thành list fallback,
    // bỏ qua chất lượng nào bị thiếu (không phải video nào cũng có đủ
    // cả 4 mức) thay vì ép buộc và gây lỗi null.
    final sources = <String>[
      large['url'] as String,
      if (medium?['url'] != null) medium!['url'] as String,
      if (small?['url'] != null) small!['url'] as String,
    ];

    return Pixamodel(
      id: json['id'].toString(),
      tags: (json['tags'] as String).split(', '),
      duration: json['duration'] as int,
      videoSources: sources,
      size: large['size'] as int,
      // Thumbnail lấy từ tiny nếu có, không có thì rơi về ảnh của large
      // để tránh crash khi response thiếu field tiny.
      thumbnail:
          (tiny?['thumbnail'] as String?) ??
          (large['thumbnail'] as String? ?? ''),
      comments: json['comments'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      user: json['user'] as String,
      userImageUrl: json['userImageURL'] as String,
      // "userUrl" không có sẵn trong response gốc Pixabay (chỉ có
      // "pageURL" cho trang video) — để rỗng nếu thiếu, tránh crash.
      userUrl: json['userUrl'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Pixamodel copyWith({
    String? id,
    List<String>? tags,
    int? duration,
    int? views,
    int? downloads,
    int? likes,
    int? comments,
    String? user,
    String? userImageUrl,
    String? userUrl,
    String? name,
    List<String>? videoSources,
    int? size,
    String? thumbnail,
  }) {
    return Pixamodel(
      id: id ?? this.id,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      user: user ?? this.user,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      userUrl: userUrl ?? this.userUrl,
      name: name ?? this.name,
      videoSources: videoSources ?? this.videoSources,
      size: size ?? this.size,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
