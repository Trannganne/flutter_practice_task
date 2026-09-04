import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';

class FileCard extends StatelessWidget {
  final String title;
  final String status;
  final int width;
  final int height;
  final String fileSize; // Dung lượng (MB)
  final String? imagePath; // Đường dẫn file ảnh
  final double progress; // Tiến độ từ 0.0 -> 1.0 (ví dụ: 1.0 là 100%)
  final VoidCallback? onCopyPressed;
  final VoidCallback? onCancelPressed;

  const FileCard({
    Key? key,
    required this.title,
    required this.status,
    required this.width,
    required this.height,
    required this.fileSize,
    this.imagePath,
    this.progress = 1.0,
    this.onCopyPressed,
    this.onCancelPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUploading = status == UploadStatus.uploading.name;
    final isPending = status == UploadStatus.pending.name;
    final isDone = status == UploadStatus.done.name;
    final isFailed = status == UploadStatus.failed.name;

    debugPrint('trạng thái hiện tại: $status');
    debugPrint('Tiến trình hiện tại: $progress');
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
                Text(
                  '$fileSize • $width x $height',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),

                // Thanh progress bar + Phần trăm
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDone
                                ? Colors.green
                                : isFailed
                                ? Colors.red
                                : Colors.blueAccent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Trạng thái & Action Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trạng thái Done
              if (status.isNotEmpty) ...[
                Icon(
                  isDone
                      ? Icons.check_circle
                      : isFailed
                      ? Icons.error_outline
                      : isPending
                      ? Icons.schedule
                      : null,
                  color: isDone
                      ? Colors.green
                      : isUploading
                      ? null
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Commontext(
                  title: isUploading ? '' : status,
                  fontSize: '12',
                  fontWeight: FontWeight.w500,
                  colorText: isDone ? Colors.grey : Colors.red,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(isUploading ? Icons.pause : null),
                ),
              ],

              // Icon Action (Copy / Option)
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                icon: Icon(
                  isDone
                      ? Icons.copy
                      : isUploading
                      ? Icons.cancel
                      : Icons.refresh,
                  size: isDone ? 18 : 24,
                  color: isDone ? Colors.grey : Colors.blue,
                ),
                onPressed: isUploading ? onCancelPressed : onCopyPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
