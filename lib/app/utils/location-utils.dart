import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationUtils {

  static Future<bool> ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Services Disabled',
        'Please enable location services to continue',
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
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

  static Future<Position?> getCurrentLocation() async {
    try {
      // Try to get last known position first for speed
      Position? position = await Geolocator.getLastKnownPosition();
      
      // If we have a last known position and it's fresh (less than 1 min old), use it
      if (position != null) {
        final age = DateTime.now().difference(position.timestamp);
        if (age.inMinutes < 1) {
          return position;
        }
      }

      // Otherwise try to get current position with medium accuracy and a timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error getting location: $e');
      // Final fallback to last known if current failed
      return await Geolocator.getLastKnownPosition();
    }
  }

}

