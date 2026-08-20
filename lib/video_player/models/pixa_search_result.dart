import 'pixamodel.dart';

/// Bọc kết quả search Pixabay: cần totalHits để Bloc biết còn trang
/// tiếp theo hay không (so sánh page * perPage với totalHits).
class PixabaySearchResult {
  final List<Pixamodel> hits;
  final int totalHits;

  const PixabaySearchResult({required this.hits, required this.totalHits});

  factory PixabaySearchResult.fromJson(Map<String, dynamic> json) {
    final rawHits = json['hits'] as List;
    return PixabaySearchResult(
      hits: rawHits
          .map((h) => Pixamodel.fromJson(h as Map<String, dynamic>))
          .toList(),
      totalHits: json['totalHits'] as int? ?? 0,
    );
  }
}
