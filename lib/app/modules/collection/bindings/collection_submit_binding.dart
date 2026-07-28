import 'package:get/get.dart';
import '../controllers/collection_submit_controller.dart';

class CollectionSubmitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CollectionSubmitController(), fenix: true);
  }
}
