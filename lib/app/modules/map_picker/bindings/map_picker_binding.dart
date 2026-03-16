import 'package:get/get.dart';
import '../controllers/map_picker_controller.dart';

class MapPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapPickerController>(() => MapPickerController());
  }
}