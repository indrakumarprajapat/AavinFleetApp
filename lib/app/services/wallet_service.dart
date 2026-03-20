import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_service.dart';
import '../constants/app_enums.dart';
import '../models/wallet_transaction_model.dart';

class WalletService extends GetxController {
  final storage = GetStorage();
  final apiService = Get.find<ApiService>();
  
  final _balance = 0.0.obs;
  final _transactions = <WalletTransactionModel>[].obs;
  final _isLoading = false.obs;

  double get balance => _balance.value;
  List<WalletTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadWalletData();
  }

  Future<void> loadWalletData() async {
    try {
      _isLoading.value = true;
      // final userType = storage.read('user_type') ?? UserType.agent.index;
      // final isCustomer = userType == UserType.customer.index;
      // final summaryResponse = isCustomer
      //   ? await apiService.getCustomerWalletSummary()
      //   : await apiService.getWalletSummary();
      final summaryResponse = await apiService.getWalletSummary();
        
      _balance.value = summaryResponse['balance']?.toDouble() ?? 0.0;

      final transactionsData = summaryResponse['recentTransactions'] as List? ?? [];
      _transactions.value = transactionsData.map((transaction) => 
        WalletTransactionModel.fromJson(transaction)
      ).toList();
      
    } catch (e) {
      _balance.value = 0.0;
      _transactions.value = [];
    } finally {
      _isLoading.value = false;
    }
  }
  


  Future<bool> addMoneyViaPayment({
    required double amount,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      _isLoading.value = true;

      await apiService.verifyPaymentAndAddFunds(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
        amount: amount,
      );

      await loadWalletData();
      
      Get.snackbar(
        'Success',
        '₹${amount.toStringAsFixed(2)} added to wallet',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      _balance.value += amount;

      _transactions.insert(0, WalletTransactionModel(
        id: DateTime.now().millisecondsSinceEpoch,
        walletId: 1,
        agentId: 0,
        transactionType: 1,
        amount: amount,
        balanceBefore: _balance.value - amount,
        balanceAfter: _balance.value,
        description: 'Payment via Razorpay (ID: $paymentId)',
        status: 1,
        createdAt: DateTime.now().toIso8601String(),
        transactionId: paymentId,
      ));
      
      Get.snackbar(
        'Payment Received',
        '₹${amount.toStringAsFixed(2)} payment successful',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      
      return true;
    } finally {
      _isLoading.value = false;
    }
  }

  void addMoneyLocally(double amount, String paymentId) {
    _balance.value += amount;
    
    _transactions.insert(0, WalletTransactionModel(
      id: DateTime.now().millisecondsSinceEpoch,
      walletId: 1,
      agentId: 0,
      transactionType: 1,
      amount: amount,
      balanceBefore: _balance.value - amount,
      balanceAfter: _balance.value,
      description: 'Payment via Razorpay',
      status: 1,
      createdAt: DateTime.now().toIso8601String(),
      transactionId: paymentId,
    ));
  }

  Future<bool> addMoney(double amount, String paymentId) async {
    addMoneyLocally(amount, paymentId);
    return true;
  }

  Future<bool> deductMoney(double amount, String orderId) async {
    if (_balance.value < amount) {
      Get.snackbar('Insufficient Balance', 'Please add money to wallet');
      return false;
    }

    try {
      _isLoading.value = true;

      await loadWalletData();
      
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Payment failed: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  String getTransactionTypeText(int transactionType) {
    switch (transactionType) {
      case 1:
        return 'Money Added';
      case 2:
        return 'Order Payment';
      default:
        return 'Transaction';
    }
  }

  @override
  void onClose() {
    _balance.value = 0.0;
    _transactions.clear();
    super.onClose();
  }
}