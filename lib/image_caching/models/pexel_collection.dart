class PexelCollections {
  final String id;
  final String title;
  final int photoCount;
  final String description;
  final String? coverUrl;

  PexelCollections({
    required this.id,
    required this.title,
    required this.photoCount,
    this.description = '',
    this.coverUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'photos_count': photoCount,
      'description': description,
      'coverUrl': coverUrl,
    };
  }

  // Pleaseee nhớ dùm là phải chống crash đối với các trường không biết có null hay không
  factory PexelCollections.fromJson(Map<String, dynamic> json) {
    return PexelCollections(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      photoCount: json['photos_count'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      coverUrl: null,
    );
  }

  PexelCollections copyWith({String? coverUrl}) {
    return PexelCollections(
      id: id,
      title: title,
      photoCount: photoCount,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}
