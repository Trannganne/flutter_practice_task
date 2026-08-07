import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/local_notification/hard/models/notificationhistory.dart';
import 'package:flutterpractisetasks/local_notification/hard/services/planner_history_cacheservice.dart';
import 'package:intl/intl.dart';

class HardHistoryScreen extends StatelessWidget {
  const HardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Notification Logs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<NotificationHistory>>(
        future: PlannerHistoryCacheservice.getPlannerHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final histories = snapshot.data!;

          if (histories.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có lịch sử thông báo',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final item = histories[index];

              return buildHistoryTile(item);
            },
          );
        },
      ),
    );
  }

  Widget buildHistoryTile(NotificationHistory item) {
    IconData icon;
    Color color;

    switch (item.type) {
      case 'planner':
        icon = Icons.assignment_turned_in;
        color = Colors.tealAccent;
        break;

      case 'activity':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;

      case 'weather':
        icon = Icons.umbrella;
        color = Colors.purpleAccent;
        break;

      default:
        icon = Icons.notifications;
        color = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161C26),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F141C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 6),

                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(item.time),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                _statusIcon(item.status),
                color: _statusColor(item.status),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                _statusLabel(item.status),
                style: TextStyle(
                  color: _statusColor(item.status),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) => switch (status) {
    'done' => Icons.check_circle,
    'snoozed' => Icons.snooze,
    _ => Icons.check_circle_outline,
  };

  Color _statusColor(String status) => switch (status) {
    'done' => Colors.green,
    'snoozed' => Colors.orangeAccent,
    _ => Colors.grey,
  };

  String _statusLabel(String status) => switch (status) {
    'done' => 'Done',
    'snoozed' => 'Snoozed',
    _ => 'Sent',
  };
}
