// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart'; // Để tìm thư mục App Document/ Download lưu file
// import 'package:share_plus/share_plus.dart';

// class FileStorageService {
//   // Lưu chuỗi text thành file .csv và mở pop up chia sẻ ngay lập tức
//   Future<String> exportCountriesToCsv(String csvString, String name) async {
//     //
//     final directory = await getApplicationDocumentsDirectory();
//     final now = DateTime.now();
//     final fileName =
//         '${name}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
//         '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';
//     // Ghi file xuống bộ nhớ
//     final file = File('${directory.path}/$fileName');
//     await file.writeAsString(csvString);

//     debugPrint('Đường dẫn nè: ${file.path}');

//     return file.path;
//   }

//   Future<OpenResult> openFile(String path) {
//     return OpenFilex.open(path);
//   }

//   Future<void> shareFile(String path) async {
//     // Gọi share_plus để share/ open file
//     final xFile = XFile(path, mimeType: 'text/csv');

//     await Share.shareXFiles([
//       xFile,
//     ], text: 'Here is your exported countries CSV file');
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class FileStorageService {
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return true; // iOS xử lý riêng
  }

  Future<String> exportCountriesToCsv(String csvContent) async {
    if (Platform.isAndroid) {
      final granted = await _requestStoragePermission();
      if (!granted) {
        throw Exception('Không có quyền truy cập bộ nhớ');
      }

      final Directory reportDir = Directory(
        '/storage/emulated/0/Download/report',
      );

      if (!await reportDir.exists()) {
        await reportDir.create(recursive: true);
      }

      final bytes = utf8.encode(csvContent);
      final hash = md5.convert(bytes).toString();
      final String fileName = 'export_$hash.csv';
      final String path = '${reportDir.path}/$fileName';
      final File file = File(path);

      if (await file.exists()) {
        final existingContent = await file.readAsString();
        if (existingContent == csvContent) {
          return path; // Return existing path if identical
        } else {
          // Hash collision or file modified, generate new timestamped name
          final fallbackFileName =
              'export_${hash}_${DateTime.now().millisecondsSinceEpoch}.csv';
          final String fallbackPath = '${reportDir.path}/$fallbackFileName';
          final fallbackFile = File(fallbackPath);
          await fallbackFile.writeAsString(csvContent);
          return fallbackPath;
        }
      }

      await file.writeAsString(csvContent);
      return file.path;
    } else {
      throw UnsupportedError(
        'iOS không hỗ trợ ghi trực tiếp vào Download. Dùng share_plus để xuất file.',
      );
    }
  }

  Future<OpenResult> openFile(String path) {
    return OpenFilex.open(path);
  }

  Future<void> shareFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File không tồn tại hoặc đã bị xóa.');
    }
    final xFile = XFile(path, mimeType: 'text/csv');

    await Share.shareXFiles([
      xFile,
    ], text: 'Here is your exported countries CSV file');
  }
}
