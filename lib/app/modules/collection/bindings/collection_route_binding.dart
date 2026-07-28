import 'package:get/get.dart';
import '../controllers/collection_route_controller.dart';

class CollectionRouteBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CollectionRouteController(), permanent: true);
  }
}
