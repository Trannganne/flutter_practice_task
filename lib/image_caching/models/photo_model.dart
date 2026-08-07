enum PhotoType { pexel, piscum }

class PhotoEnity {
  final String id;
  final String url;
  final String photoGrapher;
  final String? description;
  final PhotoType source;
  final int height;
  final int width;
  bool isFavorited;
  bool isCachedLocally;

  PhotoEnity({
    required this.id,
    required this.url,
    required this.photoGrapher,
    this.description,
    required this.source,
    this.isCachedLocally = false,
    this.isFavorited = false,
    required this.height,
    required this.width,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'photographer': photoGrapher,
      'source': source.name,
      'description': description,
      'isCachedLocally': isCachedLocally,
      'isFavorited': isFavorited,
      'width': width,
      'height': height,
    };
  }

  factory PhotoEnity.fromPexels(Map<String, dynamic> json) {
    return PhotoEnity(
      id: 'pexel_${json['id']}',
      url: json['src']['medium'],
      photoGrapher: json['photographer'],
      description: json['alt'],
      source: PhotoType.pexel,
      height: json['height'],
      width: json['width'],
    );
  }
  factory PhotoEnity.fromPiscums(Map<String, dynamic> json) {
    return PhotoEnity(
      id: 'picsum_${json['id']}',
      url: json['download_url'],
      photoGrapher: json['author'],
      source: PhotoType.piscum,
      height: json['height'],
      width: json['width'],
    );
  }

  factory PhotoEnity.fromMap(Map<String, dynamic> json) {
    return PhotoEnity(
      id: json['id'] as String,
      url: json['url'] as String,
      photoGrapher: json['photographer'] as String,
      source: PhotoType.values.byName(json['source'] as String),
      height: json['height'] as int,
      width: json['width'] as int,
    );
  }

  PhotoEnity copyWith({bool? isFavorited, bool? isCachedLocally}) {
    return PhotoEnity(
      id: id,
      url: url,
      photoGrapher: photoGrapher,
      source: source,
      height: height,
      width: width,
      isFavorited: isFavorited ?? this.isFavorited,
      isCachedLocally: isCachedLocally ?? this.isCachedLocally,
    );
  }
}
