import 'package:get/get.dart';
import '../controllers/monthly_statement_controller.dart';

class MonthlyStatementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MonthlyStatementController>(() => MonthlyStatementController());
  }
}