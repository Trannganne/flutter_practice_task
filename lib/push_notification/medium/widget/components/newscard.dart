import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
import 'package:go_router/go_router.dart';

class Newscard extends StatelessWidget {
  final Article article;
  const Newscard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          context.push('/article/', extra: article);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,

                child: CachedNetworkImage(
                  imageUrl: article.urlToImage ?? '',
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Commontext(
                      title: article.title,
                      fontWeight: FontWeight.bold,
                      fontSize: "15",
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Commontext(
                          title: article.sourceName!,
                          colorText: Colors.grey,
                          fontSize: "12",
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 4,
                          width: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Commontext(
                          title: article.timeAgo(article.publishedAt),
                          fontSize: '12',
                          colorText: Colors.grey,
                        ),
                        Spacer(),
                        Icon(
                          Icons.bookmark_outline,
                          color: const Color.fromARGB(255, 75, 73, 73),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
