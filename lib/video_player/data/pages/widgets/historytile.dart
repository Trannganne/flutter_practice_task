import 'package:flutter/material.dart';

class HistoryTile extends StatelessWidget {
  // Khi có model thì gom lại
  final String title;
  final String durationText;
  final double progress; // 0.0 to 1.0
  final String imageUrl;
  final VoidCallback? onDelete;

  const HistoryTile({
    super.key,
    required this.title,
    required this.durationText,
    required this.progress,
    required this.imageUrl,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  width: 80,
                  height: 50,
                  fit: BoxFit.cover,
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
                  durationText,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
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
    );
  }
}
