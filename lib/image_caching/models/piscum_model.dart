class PiscumModel {
  final String id;
  final String url;
  final String author;
  final String download_url;
  final int height;
  final int widght;

  PiscumModel({
    required this.id,
    required this.author,
    required this.url,
    required this.download_url,
    required this.height,
    required this.widght,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'author': author,
      'download_url': download_url,
      'height': height,
      'widght': widght,
    };
  }

  factory PiscumModel.fromJson(Map<String, dynamic> json) {
    return PiscumModel(
      id: json['id'] as String,
      url: json['url']?.toString() ?? '',
      author: json['author']?.toString() ?? 'Unknown',
      download_url: json['download_url']?.toString() ?? 'Unknown',
      height: json['height'],
      widght: json['widght'],
    );
  }
}
