import 'package:flutter/material.dart';

class VideoGridCard extends StatelessWidget {
  final String title;
  final int duration; // giây — đồng bộ kiểu với VideoCard
  final String imageUrl;
  final VoidCallback? onTap;

  const VideoGridCard({
    super.key,
    required this.title,
    required this.duration,
    required this.imageUrl,
    this.onTap,
  });

  /// Format giây -> "mm:ss", ví dụ 192 -> "03:12".
  /// Trùng logic với VideoCard._formatDuration — nếu sau này tách thành
  /// hàm dùng chung thì đưa vào 1 file util, tránh lặp ở 2 widget.
  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIX: trước đây ảnh hardcode height: 90, khiến tổng chiều cao
            // Column (90 + 8 + text) VƯỢT QUÁ height cố định mà GridView
            // cấp cho ô này (SliverGridDelegateWithMaxCrossAxisExtent +
            // childAspectRatio tính ra 1 height cụ thể) mỗi khi title đủ
            // dài để wrap 2 dòng -> "BOTTOM OVERFLOWED BY 7.4 PIXELS".
            // Dùng Expanded để ảnh tự co giãn lấp phần không gian CÒN LẠI
            // sau khi trừ phần chữ cố định bên dưới -> Column luôn khớp
            // đúng height được cấp, bất kể title 1 hay 2 dòng.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      // FIX: thiếu errorBuilder -> lỗi mạng offline bị
                      // báo ra console thay vì được Flutter xử lý êm.
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white10,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Fixed height = đúng 2 dòng ở fontSize 13 — không co giãn theo
            // nội dung, nên KHÔNG đẩy layout lệch dù title ngắn hay dài.
            SizedBox(
              height: 32,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
