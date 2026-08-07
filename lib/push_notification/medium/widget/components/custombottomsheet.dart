import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/medium/router/approute.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String body;
  final String url;
  final String? sourceName;
  final String? urlToImage;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.body,
    required this.url,
    this.sourceName,
    this.urlToImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        // Tone màu nền tối (Dark UI)
        color: Color(0xFF161C26),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Tự động co giãn chiều cao theo nội dung chữ
        children: [
          // Thanh gạch nhỏ trên đỉnh BottomSheet để tạo cảm giác vuốt kéo (Drag Handle)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon quả chuông thông báo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.amber,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Hiển thị Tiêu đề (Title) từ Firebase
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Hiển thị Nội dung (Body) từ Firebase
          Text(
            body,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              height: 1.4, // Tạo khoảng cách dòng dễ đọc
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Hàng chứa các nút bấm tương tác (Action Buttons)
          Row(
            children: [
              // Nút Đóng / Bỏ qua
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Đóng',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nút Xem ngay / Hành động chính
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Đóng bottom sheet trước khi làm việc khác
                    final article = Article(
                      sourceName: sourceName ?? 'Unknown',
                      title: title ?? 'Tin tức mới',
                      url: url,
                      publishedAt: DateTime.now(),
                      urlToImage: urlToImage,
                    );

                    //pushNamed dùng name không có dấu /
                    AppRouter.router.pushNamed('articleDetail', extra: article);
                  },
                  child: const Text(
                    'Xem ngay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
