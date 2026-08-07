import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/notificationhistory.dart';

class NotificationHistoryCard extends StatelessWidget {
  final NotificationHistory history;

  const NotificationHistoryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161C26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (history.type == 'activity')
            const Icon(Icons.wb_sunny, color: Colors.orange),
          if (history.type == 'weather')
            const Icon(Icons.umbrella, color: Colors.purpleAccent),
          if (history.type == 'planner')
            const Icon(Icons.assignment_turned_in, color: Colors.tealAccent),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.title,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  history.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  history.time.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
