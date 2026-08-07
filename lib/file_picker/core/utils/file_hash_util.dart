import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class FileHashUtil {
  static Future<String> hashFile(String filePath) async {
    return compute(_hashInIsolate, filePath);
  }

  static String _hashInIsolate(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    return md5.convert(bytes).toString();
  }
}
