import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../api/agent_api_service.dart';
import '../../../../models/earnings_model.dart';

class EarningsController extends GetxController {
  final isLoading = true.obs;
  final selectedMonth = DateTime.now().obs;
  final totalEarnings = 0.0.obs;
  final commissionAmount = 0.0.obs;
  final leakageAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadEarnings();
  }

  Future<void> loadEarnings() async {
    try {
      isLoading.value = true;
      
      final apiService = Get.isRegistered<AgentApiService>() 
          ? Get.find<AgentApiService>() 
          : Get.put(AgentApiService());
      
      final month = DateFormat('yyyy-MM').format(selectedMonth.value);
      final earnings = await apiService.getEarnings(month);

      totalEarnings.value = earnings.totalEarnings;
      commissionAmount.value = earnings.commissionAmount;
      leakageAmount.value = earnings.leakageAmount;
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      totalEarnings.value = 0.0;
      commissionAmount.value = 0.0;
      leakageAmount.value = 0.0;
      Future.microtask(() => Get.snackbar('Info', 'No earnings data available'));
    }
  }

  void updateMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    loadEarnings();
  }

  void downloadStatement() {
    Get.snackbar('Info', 'PDF download feature coming soon');
  }
}
