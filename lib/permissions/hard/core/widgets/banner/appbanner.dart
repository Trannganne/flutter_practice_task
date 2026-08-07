import 'package:flutter/material.dart';

class AppBanner {
  /// Hiện banner với 1 nút hành động tùy chỉnh + nút đóng mặc định
  static void showAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    Color backgroundColor = const Color(0xFF1E293B),
    Color textColor = Colors.white,
    Color actionColor = const Color(0xFF2563EB),
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Ẩn banner cũ nếu đang hiện, tránh chồng nhiều banner
    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        actions: [
          TextButton(
            onPressed: () {
              onActionPressed();
              messenger.hideCurrentMaterialBanner();
            },
            child: Text(
              actionLabel,
              style: TextStyle(color: actionColor, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: Text(
              'Đóng',
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  /// Hiện banner thông báo đơn giản, chỉ có nút đóng (không có hành động phụ)
  static void showInfo(
    BuildContext context, {
    required String message,
    Color backgroundColor = const Color(0xFF1E293B),
    Color textColor = Colors.white,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: Text(
              'Đóng',
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  /// Ẩn banner hiện tại (nếu cần chủ động ẩn từ nơi khác)
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }
}
