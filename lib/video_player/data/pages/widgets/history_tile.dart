import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/core/utils/time_formatter.dart';

class HistoryTile extends StatelessWidget {
  // Khi có model thì gom lại
  final String title;
  final int durationText;
  final double progress; // 0.0 to 1.0
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HistoryTile({
    super.key,
    required this.title,
    required this.durationText,
    required this.progress,
    required this.imageUrl,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // FIX: HistoryTile được dùng trong ListView.builder(scrollDirection:
      // Axis.horizontal) ở home_page._buildWatchHistorySection(). Trong
      // ListView cuộn NGANG, mỗi item nhận width KHÔNG GIỚI HẠN — nhưng
      // Row bên dưới có Expanded(), nên cần 1 width CỐ ĐỊNH bọc ngoài để
      // Row có constraints hữu hạn mà tính toán. Thiếu bước này gây lỗi
      // "RenderFlex children have non-zero flex but incoming width
      // constraints are unbounded". 280 tương đương chiều rộng 1 tile
      // trong mockup Watch History.
      child: SizedBox(
        width: 280,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 110,
                      height: 60,
                      fit: BoxFit.cover,
                      // FIX: thiếu errorBuilder -> Flutter báo lỗi ra
                      // console mỗi khi ảnh load thất bại (offline...).
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 110,
                        height: 60,
                        color: Colors.white10,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIX overflow "473 pixels": Commontext (component
                    // dùng chung, code không nằm trong module này) không
                    // rõ có tự wrap/ellipsis text hay không. Vì đây LÀ
                    // nơi cụ thể gây overflow (theo Debug Console), đổi
                    // riêng chỗ hiển thị title sang Text chuẩn của
                    // Flutter với maxLines + overflow tường minh — đảm
                    // bảo chắc chắn không tràn dù title dài bao nhiêu.
                    // (Nếu Commontext cũng dùng ở chỗ khác trong app mà
                    // KHÔNG có maxLines/overflow mặc định, đáng để kiểm
                    // tra lại file widgets/components/commonText.dart —
                    // rất có thể đây là bug lặp lại ở nhiều nơi khác.)
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      color: Colors.blue,
                      minHeight: 3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TimeFormatter().formatDuration(durationText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
