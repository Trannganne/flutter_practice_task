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

  // large video
  final String videoLargeUrl;
  final int size;

  // tiny video
  final String thumbnail;

  const Pixamodel({
    required this.id,
    required this.tags,
    required this.duration,
    required this.user,
    required this.userImageUrl,
    required this.userUrl,
    required this.videoLargeUrl,
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
      'videoLargeUrl': videoLargeUrl,
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
  /// Ví dụ dùng đúng ở tầng Repository:
  ///   final rawHits = response['hits'] as List;
  ///   final videos = rawHits.map((h) => Pixamodel.fromJson(h)).toList();
  factory Pixamodel.fromJson(Map<String, dynamic> json) {
    final videos = json['videos'] as Map<String, dynamic>;
    final large = videos['large'] as Map<String, dynamic>;
    final tiny = videos['tiny'] as Map<String, dynamic>;

    return Pixamodel(
      id: json['id'].toString(),
      tags: (json['tags'] as String).split(', '),
      duration: json['duration'] as int,
      videoLargeUrl: large['url'] as String,
      size: large['size'] as int,
      thumbnail: tiny['thumbnail'] as String,
      comments: json['comments'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      user: json['user'] as String,
      userImageUrl: json['userImageURL'] as String,
      // Lưu ý: field "userUrl" không có sẵn trong response gốc của Pixabay
      // API (chỉ có "pageURL" cho trang video, không có link riêng cho user).
      // Cần xác nhận lại đây là field bạn tự thêm hay đang map nhầm key,
      // tạm để rỗng nếu không có trong response thật để tránh lỗi key not found.
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
    String? videoLargeUrl,
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
      videoLargeUrl: videoLargeUrl ?? this.videoLargeUrl,
      size: size ?? this.size,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
