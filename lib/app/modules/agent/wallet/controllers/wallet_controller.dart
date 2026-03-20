import 'package:get/get.dart';

import '../../../../api/api_service.dart';

class WalletController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final currentBalance = 0.0.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getWalletSummary();

      currentBalance.value = (data['balance'] ?? 0.0).toDouble();
      transactions.value = (data['recentTransactions'] as List? ?? [])
          .map((t) => {
                'type': (t['transactionType'] ?? 2) == 1 ? 'credit' : 'debit',
                'title': _getTransactionTitle(t['transactionType'], t['referenceType']),
                'amount': (t['amount'] ?? 0).toDouble(),
                'description': t['description'] ?? '',
                'date': _formatDate(t['createdAt'] ?? ''),
              })
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load wallet data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getTransactionTitle(int? transactionType, int? referenceType) {
    if (transactionType == 1) {
      switch (referenceType) {
        case 2: return 'Commission Received';
        case 3: return 'Refund Received';
        case 4: return 'Wallet Recharge';
        default: return 'Money Added';
      }
    } else {
      switch (referenceType) {
        case 1: return 'Order Payment';
        case 5: return 'Withdrawal';
        default: return 'Money Deducted';
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
        final period = date.hour >= 12 ? 'PM' : 'AM';
        final minute = date.minute.toString().padLeft(2, '0');
        return 'Today $hour:$minute $period';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}