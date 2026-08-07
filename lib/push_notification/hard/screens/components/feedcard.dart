import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feeditemmodel.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';

class Feedcard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback onTap;

  const Feedcard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shadowColor: const Color.fromARGB(255, 118, 117, 117).withOpacity(0.25),
      color: const Color.fromARGB(
        255,
        45,
        82,
        118,
      ), // Đổi nền Card sang màu xám xanh đậm sang trọng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Appcolor.bgColor.withOpacity(0.3),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Phần Header nhỏ của Thẻ: Hiển thị nguồn/loại bài viết nếu có
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Appcolor.bgColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.type?.toUpperCase() ?? 'NEWS',
                      style: const TextStyle(
                        color: Appcolor.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 18,
                    color: Appcolor.textTertiary.withOpacity(0.6),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                CachedNetworkImage(
                  //  Bỏ dấu ! đi vì chúng ta đã kiểm tra null ở phía trên rồi
                  imageUrl: item.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  // Nên thêm errorWidget để xử lý nếu link ảnh lỗi không tải được
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              // 2. Tiêu đề bài viết
              Text(
                item.title,
                style: const TextStyle(
                  color: Appcolor
                      .textTertiary, // Chữ màu trắng nổi bật trên nền tối
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 3. Nội dung mô tả ngắn
              Text(
                item.description ?? 'Không có nội dung mô tả.',
                style: TextStyle(
                  color: Appcolor.textTertiary.withOpacity(
                    0.7,
                  ), // Giảm opacity để làm text phụ
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 10),

              // 4. Footer của Thẻ: Điểm nhấn nút hành động giả
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Đọc tiếp',
                    style: TextStyle(
                      color: Appcolor
                          .textSecondary, // Màu đỏ làm điểm nhấn hành động
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Appcolor.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fallback khi không có ảnh
  Widget _buildImageFallback() {
    return Container(
      color: Colors.blueGrey.shade100,
      child: const Center(
        child: Icon(Icons.newspaper, size: 60, color: Colors.blueGrey),
      ),
    );
  }
}
