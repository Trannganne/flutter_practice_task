import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationMenu extends StatelessWidget {
  const AppNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Flutter Practice Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn cấp độ bài tập:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Cấp độ EASY
            _buildNavigationCard(
              context: context,
              title: 'Daily Activity Reminder',
              subtitle:
                  'Lên lịch local notification hằng ngày, gọi API lấy nội dung nhắc việc, hiển thị và cho phép test ngay.',
              badgeText: 'Easy',
              badgeColor: Colors.green.shade600,
              icon: Icons.gamepad,
              onTap: () {
                context.pushNamed('activity');
                _showComingSoonSnackBar(context, 'Easy Apps');
              },
            ),
            const SizedBox(height: 16),

            // 2. Cấp độ MEDIUM (Chính là App thời tiết nhắc mang ô của bạn)
            _buildNavigationCard(
              context: context,
              title: 'Rain Umbrella Reminder',
              subtitle:
                  'Dùng dữ liệu thời tiết để quyết định có lên lịch nhắc mang ô; xử lý loading/error/empty và quyền notification.',
              badgeText: 'Medium',
              badgeColor: Colors.orange.shade700,
              icon: Icons.umbrella_rounded,
              onTap: () {
                context.pushNamed('umbrellaReminder');

                // Tạm thời hiển thị thông báo nếu chưa mở comment code điều hướng
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigating to Weather Screen (Medium)...'),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Cấp độ HARD
            _buildNavigationCard(
              context: context,
              title: 'Smart Daily Planner',
              subtitle:
                  'Nâng cao: Kết hợp nhắc việc + thời tiết, offline cache, retry, timezone, UX production, không spam notification',
              badgeText: 'Hard',
              badgeColor: Colors.red.shade600,
              icon: Icons.bolt,
              onTap: () {
                context.pushNamed('hardDashboard');
                _showComingSoonSnackBar(context, 'Hard Apps');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget chung tạo Thẻ điều hướng
  Widget _buildNavigationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Khối Icon bên trái đại diện cho App
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: badgeColor, size: 30),
                ),
                const SizedBox(width: 16),

                // Nội dung text ở giữa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag hiển thị Level
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mũi tên dẫn đường bên phải
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String level) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ứng dụng thuộc nhóm $level đang được phát triển!'),
      ),
    );
  }
}
