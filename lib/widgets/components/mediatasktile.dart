import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TileType { queue, completed, history }

class MediaTaskTile extends StatelessWidget {
  final String fileName;
  final String? subtitleText;
  final String? url;
  final double progress; // 0.0 - 1.0
  final String statusText;
  final Color statusColor;
  final IconData? statusIcon;
  final String? imageUrl;
  final TileType type;
  final VoidCallback? Action;

  const MediaTaskTile({
    super.key,
    required this.fileName,
    this.subtitleText,
    this.url,
    this.progress = 1.0,
    required this.statusText,
    this.statusColor = Colors.green,
    this.statusIcon,
    this.imageUrl,
    this.type = TileType.completed,
    this.Action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: Colors.blue.shade100,
                      child: const Icon(
                        Icons.insert_drive_file,
                        color: Colors.blue,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Info & Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (type == TileType.queue) ...[
                    Text(
                      subtitleText ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: statusColor,
                      minHeight: 4,
                    ),
                  ] else ...[
                    Text(
                      url ?? subtitleText ?? '',
                      style: TextStyle(
                        color: url != null ? Colors.blue : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status & Action Icon
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (statusIcon != null) ...[
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    type == TileType.queue
                        ? Icons.pause_circle_outline
                        : Icons.copy_rounded,
                    color: Colors.grey.shade700,
                    size: 20,
                  ),
                  onPressed:
                      Action ??
                      () {
                        if (url != null) {
                          Clipboard.setData(ClipboardData(text: url!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied link to clipboard'),
                            ),
                          );
                        }
                      },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
