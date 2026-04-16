import 'package:get/get.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // We don't put DeliveryController here because it's already 
    // provided by DeliveryRouteBinding in AppPages.
    // This ensures we use the SAME instance with the recorded data.
  }
}
