import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationUtils {

  static Future<bool> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Required',
        'Please enable location access from Settings to continue',
      );
    }

    return false;
  }

}

