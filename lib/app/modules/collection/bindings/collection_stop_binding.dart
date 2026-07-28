import 'package:get/get.dart';
import '../controllers/collection_stop_controller.dart';

class CollectionStopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CollectionStopController(), fenix: true);
  }
}
