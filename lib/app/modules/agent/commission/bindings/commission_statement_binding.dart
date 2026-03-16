import 'package:get/get.dart';
import '../controllers/commission_statement_controller.dart';

class CommissionStatementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommissionStatementController>(() => CommissionStatementController());
  }
}