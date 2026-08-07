import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

enum FeedType { post, article }

class FeedItem {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? sourceName;
  final String? url;
  final DateTime? publishedAt;
  final String type; // 'post' hoặc 'article'
  final String? category;
  final String? author;
  final String? description;

  const FeedItem({
    required this.id,
    required this.title,
    required this.body,
    this.author,
    this.imageUrl,
    this.sourceName,
    this.url,
    this.publishedAt,
    required this.type,
    this.category = 'general',
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'sourceName': sourceName,
      'url': url,
      'publishedAt': publishedAt?.toIso8601String(),
      'type': type,
      'category': category,
      'author': author,
      'description': description,
    };
  }

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] ?? '',
      sourceName: json['sourceName'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      type: json['type'] as String,
      category: json['category'] ?? 'general',
      author: json['author'] ?? '',
    );
  }

  factory FeedItem.fromPost(Map<String, dynamic> json) {
    return FeedItem(
      id: 'post_${json['id']}',
      title: json['title'] as String,
      body: json['body'] as String,
      sourceName: 'JSONPlaceholder',
      publishedAt: DateTime.now(),
      type: 'post',
      author: json['userId']?.toString(),
    );
  }

  factory FeedItem.fromArticle(Article article, {String category = 'general'}) {
    return FeedItem(
      id: 'article_${article.url}',
      title: article.title,
      body: article.content ?? '',
      description: article.description,
      author: article.author,
      sourceName: article.sourceName,
      url: article.url,
      imageUrl: article.urlToImage,
      publishedAt: article.publishedAt,
      type: 'article',
      category: category,
    );
  }
}
