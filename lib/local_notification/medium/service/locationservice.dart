import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else {
      if (status.isDenied) {
        status = await Permission.location.request();
        return status.isGranted;
      } else {
        openAppSettings();
        return false;
      }
    }
  }

  static Future<Position> getCurrentLocation() async {
    bool granted = await requestLocationPermission();
    if (!granted) {
      throw Exception('Location permission not granted');
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service is not enabled');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
