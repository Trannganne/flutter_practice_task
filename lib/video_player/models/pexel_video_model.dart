class PexelModel {
  final int id;
  final String url;

  final String photoGrapher;
  final String photoGrapherUrl;
  final String description;
  final String original;
  final String medium;
  final String small;
  final int height;
  final int width;

  PexelModel({
    required this.id,
    required this.url,
    required this.original,
    required this.photoGrapher,
    required this.photoGrapherUrl,
    required this.description,
    required this.medium,
    required this.small,
    required this.height,
    required this.width,
    //  this.isFavorited = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'photographer': photoGrapher,
      'photographer_url': photoGrapherUrl,
      'alt': description,
      'src': {'original': original, 'medium': medium, 'small': small},
      'height': height,
      //'isFavorited': isFavorited,
    };
  }

  factory PexelModel.fromJson(Map<String, dynamic> json) {
    final srcMap = json['src'] as Map<String, dynamic>?;
    return PexelModel(
      id: json['id'] as int? ?? 0,
      url: json['url'] as String,

      // Lấy link ảnh
      original: srcMap?['original'] as String? ?? '',
      medium: srcMap?['medium'] as String? ?? '',
      small: srcMap?['small'] as String? ?? '',

      photoGrapher: json['photographer'] as String,
      photoGrapherUrl: json['photographer_url'] as String,
      description: json['alt'] as String,
      height: json['height'],
      width: json['width'],
    );
  }
}
