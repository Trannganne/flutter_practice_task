import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Gpsservice {
  // Lấy vị trí hiện tại
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    //1. Kiểm tra gps đã bật chưa
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        'Dịch vụ GPS đã bị tắt. Vui lòng bật để thực hiện chức năng này!',
      );
    }

    //2. Kiểm tra quyền đã được cấp chưa
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied!');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Quyền vị trí đã bị từ chối vĩnh viễn!');
    }
    //3. Tiến hành lấy vị trí
    return await Geolocator.getCurrentPosition();
  }

  Future<String?> getCoutryCode(double lat, double long) async {
    final Geocoding geocoding = Geocoding();
    List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
      lat,
      long,
    );

    if (placemarks.isEmpty) return null;
    return placemarks.first.isoCountryCode;
  }
}
