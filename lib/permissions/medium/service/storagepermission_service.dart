import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class StorageService {
  Future<PermissionStatus> requestPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Trên android 13+, việc ghi file vào app document/ download là
      //mặc định được phép nên không cần xin quyền
      if (androidInfo.version.sdkInt >= 33) {
        return PermissionStatus.granted;
      }
    }
    // Với android <13, tiến hành xin quyền bình thường

    return await Permission.storage.request();
  }
}
