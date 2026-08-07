import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
  Future<PermissionStatus> cameraRequest() {
    return Permission.camera.request();
  }

  Future<PermissionStatus> locationRequest() {
    return Permission.location.request();
  }

  // Dùng để đọc trạng thái hiện tại, không hiệu pop up xin quyền

  Future<PermissionStatus> checkLocationStatus() => Permission.location.status;

  Future<PermissionStatus> checkCameraStatus() => Permission.camera.status;

  // Cách viết 1:
  // Future<PermissionStatus> checkStorageaStatus() {
  //   return Permission.storage.status;
  // }
  //Cách: 2
  Future<PermissionStatus> checkStorageaStatus() => Permission.storage.status;
}
