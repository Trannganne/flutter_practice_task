import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';

class Completedcard extends StatelessWidget {
  final String title;
  final String sourcePath;
  final String? imagePath; // Đường dẫn file ảnh
  final VoidCallback? onCopyPressed;
  final String completedAt;

  const Completedcard({
    Key? key,
    required this.title,
    required this.completedAt,
    required this.sourcePath,
    this.imagePath,
    this.onCopyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        //   color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Thumbnail Ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath != null
                ? Image.file(
                    File(imagePath!),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),

          // 2. Nội dung chính (Tên, Thông tin, Thanh Progress)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tên file
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Dung lượng & Kích thước (MB • W x H)
                Commontext(
                  title: '$sourcePath',
                  colorText: Colors.blueAccent,
                  fontSize: '12',
                ),
                const SizedBox(height: 8),

                // Thanh progress bar + Phần trăm
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Trạng thái & Action Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thời gian hoàn thành
              Commontext(
                title: completedAt,
                colorText: Colors.grey,
                fontSize: '12',
              ),
              // Icon Action (Copy / Option)
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: Icon(Icons.copy, size: 18, color: Colors.grey),
                onPressed: onCopyPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
