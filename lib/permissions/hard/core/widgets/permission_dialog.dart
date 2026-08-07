import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDialogUtils {
  /// Hiển thị Dialog yêu cầu người dùng mở Cài đặt khi quyền bị từ chối vĩnh viễn.
  /// [title]: Tiêu đề của Dialog (VD: 'Quyền truy cập Camera')
  /// [content]: Lời giải thích lý do cần quyền (VD: 'Ứng dụng cần camera để chụp ảnh...')
  static void showSettingsDialog({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Đóng',
    String confirmText = 'Đi đến Cài đặt',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // Ép người dùng thao tác trên các nút
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
            ElevatedButton(
              child: Text(confirmText),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog trước
                openAppSettings(); // Mở cài đặt hệ thống
              },
            ),
          ],
        );
      },
    );
  }
}
