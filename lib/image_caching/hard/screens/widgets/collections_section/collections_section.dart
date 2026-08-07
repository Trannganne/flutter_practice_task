// lib/presentation/widgets/collection_section.dart
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/widgets/card/photo_card.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/common/commontext.dart';
//import 'package:google_fonts/google_fonts.dart'; // (Tùy chọn) Thêm google_fonts nếu cần phông chữ đẹp

class CollectionSection extends StatelessWidget {
  final String title;
  final List<PexelCollections> collections;
  final VoidCallback? onSeeAllPressed;
  final VoidCallback? onCollectionTap;

  const CollectionSection({
    Key? key,
    this.title = 'Collections',
    required this.collections,
    this.onSeeAllPressed,
    this.onCollectionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy Theme để màu sắc tự động đổi (Light/Dark Mode)
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Giảm kích thước tối thiểu
      children: [
        // --- 1. PHẦN TIÊU ĐỀ (HEADER) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  // textTheme tự động lấy màu đúng theo Light/Dark mode
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: onSeeAllPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      text: 'See all',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant, // Màu chữ mờ hơn
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant, // Chú thích phần này nữa
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        //  2. Phần cuộn ngang
        // Phải dùng Container/SizedBox có height cố định cho ListView.builder ngang
        SizedBox(
          height: 180, // Điều chỉnh chiều cao phù hợp với Card của bạn
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Đặt trục cuộn ngang
            itemCount: collections.length,
            // Thêm padding cho các thẻ
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            itemBuilder: (context, index) {
              final collection = collections[index];
              return Padding(
                padding: const EdgeInsets.only(
                  right: 12.0,
                ), // Khoảng cách giữa các card
                child: PhotoCard(
                  collections: collection,
                  onTap: () {
                    onCollectionTap;
                    // Xử lý khi nhấn vào card (ví dụ: chuyển trang)
                    print('Pressed ${collection.title}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
