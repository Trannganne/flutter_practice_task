import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/core/utils/time_formatter.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';

class ArticleBanner extends StatelessWidget {
  final FeedItem item;

  final String tag;
  final VoidCallback onTap;

  const ArticleBanner({
    super.key,
    this.tag = 'BREAKING',
    required this.onTap,
    required this.item,
  });

  // @override
  // Widget build(BuildContext context) {
  //   final imageUrl = item.imageUrl?.trim();
  //   final hasImage = imageUrl != null && imageUrl.isNotEmpty;

  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 180,
  //       margin: const EdgeInsets.symmetric(horizontal: 16),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16),
  //         // Màu nền dự phòng khi ảnh lỗi (offline...).
  //         color: Colors.grey[900],
  //         image: DecorationImage(
  //           image: NetworkImage(imageUrl!),
  //           fit: BoxFit.cover,
  //           // FIX: DecorationImage không có onError -> lỗi ảnh offline bị
  //           // báo ra console (FlutterError.reportError) mỗi lần build lại.
  //           onError: (exception, stackTrace) {},
  //         ),
  //       ),
  //       child: Stack(
  //         children: [
  //           Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(16),
  //               gradient: LinearGradient(
  //                 colors: [Colors.black.withOpacity(0.7), Colors.transparent],
  //                 begin: Alignment.bottomCenter,
  //                 end: Alignment.topCenter,
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             top: 12,
  //             left: 12,
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: Colors.amber,
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //               child: Text(
  //                 tag,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 12,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             bottom: 12,
  //             left: 16,
  //             right: 60,
  //             child: Text(
  //               item.title,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //           Positioned(
  //             bottom: 16,
  //             right: 60,
  //             left: 16,
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //               decoration: BoxDecoration(
  //                 color: Colors.black54,
  //                 borderRadius: BorderRadius.circular(4),
  //               ),
  //               child: Text(
  //                 '${item.author} - ${item.publishedAt}',
  //                 style: const TextStyle(color: Colors.white, fontSize: 12),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImage
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          color: Colors.grey.shade900,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      },
                    )
                  : _buildImagePlaceholder(),
            ),

            // Lớp gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 24,
              child: Container(
                width: 32,
                height: 32,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.bookmark_outline,
                    size: 16,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 42,
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                '${item.author ?? 'Không rõ tác giả'}'
                ' • ${TimeFormatter().formatTimeAgoFromTimestamp(item.publishedAt!.millisecondsSinceEpoch)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey.shade900,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white54,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'Không có hình ảnh',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
