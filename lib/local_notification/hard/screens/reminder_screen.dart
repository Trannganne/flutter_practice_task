import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_state.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_event.dart';

class HardRemindersScreen extends StatelessWidget {
  const HardRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Manage Reminders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          if (state is PlannerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (state is PlannerLoadSuccess) {
            final planner = state.planner;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'ACTIVE CONFIGURATIONS',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Thẻ cấu hình Bài Easy: Daily Activity
                _buildDetailReminderTile(
                  context: context,
                  title: 'Daily Activity Reminder',
                  description:
                      'Gợi ý hoạt động ngẫu nhiên: "${planner.activity.activity}".',
                  time: 'Every day at 08:00 AM',
                  icon: Icons.wb_sunny_outlined,
                  iconColor: Colors.orange,
                  isActive: planner.activityEnabled, // Đồng bộ với Bloc State
                  onChanged: (value) {
                    context.read<PlannerBloc>().add(
                      ToggleActivityReminderEvent(isEnabled: value),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Thẻ cấu hình Bài Medium: Rain Umbrella
                _buildDetailReminderTile(
                  context: context,
                  title: 'Rain Umbrella Reminder',
                  description:
                      'Kiểm tra thời tiết tự động tại ${planner.forecast.cityName}. Cảnh báo mang ô nếu tỷ lệ mưa vượt ngưỡng.',
                  time: 'Checked daily at 08:00 AM',
                  icon: Icons.umbrella_outlined,
                  iconColor: Colors.purpleAccent,
                  isActive: planner.forecastEnabled, // Đồng bộ với Bloc State
                  onChanged: (value) {
                    context.read<PlannerBloc>().add(
                      ToggleUmbrellaReminderEvent(isEnabled: value),
                    );
                  },
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'Không có dữ liệu Planner. Vui lòng thử lại!',
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailReminderTile({
    required BuildContext context,
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isActive,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161C26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222B3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: Colors.greenAccent.shade700,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFF222B3C), height: 1),
          ),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.amber.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  color: Colors.amber.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
