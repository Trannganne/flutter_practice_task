import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/grid/gridviewitem.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';

class PhotoGridView extends StatelessWidget {
  // final List<PexelModel> photos; // Nhận danh sách PhotoEntity của bạn
  final List<PhotoEnity> photos;
  final int crossAxisCount; // Số cột (Trong ảnh mẫu là 3 cột)
  final Function(dynamic photo)? onPhotoTap;
  final Function(dynamic photo)? onFavoriteToggle;

  const PhotoGridView({
    super.key,
    required this.photos,
    this.crossAxisCount = 3, // Mặc định 3 cột giống mẫu
    this.onPhotoTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Center(child: Text("Không có ảnh nào"));
    }

    return GridView.builder(
      shrinkWrap: true, // Cho phép lồng vào ScrollView nếu cần
      physics:
          const NeverScrollableScrollPhysics(), // Không scroll riêng nếu đã nằm trong CustomScrollView
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10, // Khoảng cách ngang giữa các ảnh
        mainAxisSpacing: 10, // Khoảng cách dọc giữa các ảnh
        childAspectRatio: 1.0, // Tỷ lệ khung hình vuông (1:1) giống ảnh mẫu
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];

        return PhotoGridItem(
          imageUrl: photo.url, // chuyển sang medium khi là pexel
          isFavorite: photo.isFavorited,
          onTap: () => onPhotoTap?.call(photo),
          onFavoriteToggle: () => onFavoriteToggle?.call(photo),
        );
      },
    );
  }
}
