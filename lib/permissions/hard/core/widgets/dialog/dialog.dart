import 'package:flutter/material.dart';

enum DialogResult { cancel, confirm }

class CustomDialog {
  Future<DialogResult?> showCusTomDialog(
    BuildContext context, {
    String title = 'Xác nhận',
    String content = 'Nhập nội dung',
    String button1 = 'Hủy',
    String button2 = 'Xác nhận',
    Color background = Colors.red,
  }) {
    return showDialog<DialogResult>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, DialogResult.cancel),
            child: Text(button1, style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: background, // Red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext, DialogResult.confirm); // Đóng Dialog
            },
            child: Text(button2, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
