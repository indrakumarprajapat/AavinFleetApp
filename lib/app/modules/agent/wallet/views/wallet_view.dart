// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import '../../../../constants/app_enums.dart';
// import '../../../../models/agent_model.dart';
// import '../../../../models/customer_model.dart';
// import '../../../../models/wallet_transaction_model.dart';
// import '../../../../services/api_service.dart';
// import '../../../../services/wallet_service.dart';
// import '../../../../widgets/global_header.dart';
//
// class WalletView extends StatefulWidget {
//   const WalletView({Key? key}) : super(key: key);
//
//   @override
//   State<WalletView> createState() => _WalletViewState();
// }
//
// class _WalletViewState extends State<WalletView> {
//   late Razorpay _razorpay;
//   final walletService = Get.put(WalletService());
//   final storage = GetStorage();
//   final Rx<AgentModel?> agentData = Rx<AgentModel?>(null);
//   final Rx<Customer?> customerData = Rx<Customer?>(null);
//   final apiService = Get.find<ApiService>();
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     final userType = storage.read('user_type');
//     if (userType.value == UserType.customer) {
//       final customerData = storage.read('customer');
//       if (customerData != null) {
//         if (customerData is Map<String, dynamic>) {
//           this.customerData.value = Customer.fromJson(customerData);
//         } else if (customerData is Customer) {
//           this.customerData.value = customerData;
//         }
//       }
//     } else {
//       final agentJson = storage.read('agent');
//       if (agentJson != null) {
//         agentData.value = AgentModel.fromJson(agentJson);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     final orderId = response.orderId ?? '';
//     if (orderId.startsWith('wallet_')) {
//       final parts = orderId.split('_');
//       final amount = parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 100.0;
//
//       walletService.addMoneyViaPayment(
//         amount: amount,
//         paymentId: response.paymentId ?? '',
//         orderId: orderId,
//         signature: response.signature ?? '',
//       );
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     Get.snackbar('Payment Failed', response.message ?? 'Payment cancelled');
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     Get.snackbar('External Wallet', 'Selected: ${response.walletName}');
//   }
//
//   Future<void> _openRazorpay(double amount) async {
//     final razorpayKey = storage.read('razorpay_key') ?? '';
//
//     final order = await apiService.getRazorPayOrderId(amount);
//
//     var options = {
//       'key': razorpayKey,
//       'amount': (amount * 100).toInt(),
//       'name': 'AAVIN',
//       'order_id': order.id,
//       'description': 'Add ₹${amount.toStringAsFixed(2)} to wallet',
//       // 'order_id': 'wallet_${DateTime.now().millisecondsSinceEpoch}_${amount.toInt()}',
//       'prefill': {
//         'contact': agentData.value?.mobileNumber ?? '',
//         'email': '',
//         'name': agentData.value?.name ?? '',
//       },
//       'theme': {
//         'color': '#00ADD9'
//       }
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to open payment: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F8F8),
//       body: Column(
//         children: [
//           GlobalHeader(title: 'Wallet'),
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: () => walletService.loadWalletData(),
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     _buildBalanceCard(walletService),
//                     SizedBox(height: 20),
//                     _buildAddMoneyCard(),
//                     SizedBox(height: 20),
//                     _buildTransactionHistory(walletService),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBalanceCard(WalletService walletService) {
//     return Obx(() => Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF00ADD9), Color(0xFF0088CC)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Wallet Balance',
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             '₹${walletService.balance.toStringAsFixed(2)}',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     ));
//   }
//
//   Widget _buildAddMoneyCard() {
//     final amountController = TextEditingController();
//
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Add Money',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 16),
//           TextField(
//             controller: amountController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: 'Enter Amount',
//               prefixText: '₹ ',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Quick Add',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//           SizedBox(height: 8),
//           Row(
//             children: [
//               _buildQuickAmountButton('₹100', 100, amountController),
//               SizedBox(width: 8),
//               _buildQuickAmountButton('₹500', 500, amountController),
//               SizedBox(width: 8),
//               _buildQuickAmountButton('₹1000', 1000, amountController),
//             ],
//           ),
//           SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 final amount = double.tryParse(amountController.text);
//                 if (amount != null && amount > 0) {
//                   _openRazorpay(amount);
//                   amountController.clear();
//                 } else {
//                   Get.snackbar('Error', 'Please enter valid amount');
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFF00ADD9),
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: Text('Add Money'),
//             ),
//           ),
//           SizedBox(height: 10),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: () => _openRazorpay(100.0),
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: Color(0xFF00ADD9)),
//                 foregroundColor: Color(0xFF00ADD9),
//                 padding: EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: Text('Test Razorpay (₹100)'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTransactionHistory(WalletService walletService) {
//     return Obx(() => Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Recent Transactions',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 16),
//           if (walletService.transactions.isEmpty)
//             Text('No transactions yet')
//           else
//             ...walletService.transactions.take(5).map((transaction) =>
//               _buildTransactionItem(transaction)),
//         ],
//       ),
//     ));
//   }
//
//   Widget _buildTransactionItem(WalletTransactionModel transaction) {
//     final isCredit = transaction.isCredit;
//
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Icon(
//             isCredit ? Icons.add_circle : Icons.remove_circle,
//             color: isCredit ? Colors.green : Colors.red,
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   transaction.transactionTypeText,
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 if (transaction.description != null)
//                   Text(
//                     transaction.description!,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Text(
//             '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               color: isCredit ? Colors.green : Colors.red,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickAmountButton(String label, int amount, TextEditingController controller) {
//     return Expanded(
//       child: OutlinedButton(
//         onPressed: () => controller.text = amount.toString(),
//         style: OutlinedButton.styleFrom(
//           side: BorderSide(color: Color(0xFF00ADD9)),
//           foregroundColor: Color(0xFF00ADD9),
//         ),
//         child: Text(label),
//       ),
//     );
//   }
// }