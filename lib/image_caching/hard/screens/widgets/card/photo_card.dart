import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/image_caching/core/app_colors.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';
import 'package:cached_network_image/cached_network_image.dart' as ima;

class PhotoCard extends StatelessWidget {
  final PexelCollections collections;
  final VoidCallback? onTap;

  const PhotoCard({required this.collections, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Viền mỏng thích ứng theo Theme
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BlocBuilder<PhotoBloc, PhotoState>(
          builder: (context, state) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child:
                        collections.coverUrl != null &&
                            collections.coverUrl!.isNotEmpty
                        ? ima.CachedNetworkImage(
                            imageUrl: collections.coverUrl!,
                            fit: BoxFit
                                .cover, // Cần thêm thuộc tính này để ảnh không bị méo/bóp
                            placeholder: (context, url) => Container(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  // Lớp phủ Gradient làm tối chân ảnh
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withOpacity(0.1),
                            AppColors.black.withOpacity(
                              0.85,
                            ), // Dùng màu cố định cho text trên nền ảnh
                          ],
                          stops: const [0.4, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Nội dung Text
                  Positioned(
                    left: 14,
                    bottom: 14,
                    right: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          collections.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors
                                .white, // Chữ trên ảnh luôn giữ màu trắng
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${collections.photoCount}',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
