import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../services/wallet_service.dart';
import '../../../api/api_service.dart';
import '../controllers/add_funds_controller.dart';

class AddFundsView extends StatefulWidget {
  const AddFundsView({Key? key}) : super(key: key);

  @override
  State<AddFundsView> createState() => _AddFundsViewState();
}

class _AddFundsViewState extends State<AddFundsView> with WidgetsBindingObserver {
  late Razorpay _razorpay;
  final controller = Get.put(AddFundsController());
  final walletService = Get.put(WalletService());
  final storage = GetStorage();
  final apiService = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      print('Razorpay initialized successfully');
    } catch (e) {
      print('Razorpay initialization error: $e');
      Get.snackbar('Error', 'Failed to initialize payment gateway');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final amount = double.tryParse(controller.amountController.text) ?? 0.0;
    
    // if (controller.isCustomer.value) {
    //   _verifyCustomerPayment(
    //     paymentId: response.paymentId ?? '',
    //     orderId: response.orderId ?? '',
    //     signature: response.signature ?? '',
    //     amount: amount,
    //   );
    // } else {
      walletService.addMoneyViaPayment(
        amount: amount,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );
    // }
    
    controller.amountController.clear();
    
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(true);
        // if (controller.isCustomer.value) {
        //   try {
        //     final walletController = Get.find<CustomerWalletController>();
        //     walletController.loadWalletData();
        //   } catch (e) {
        //     print('CustomerWalletController not found: $e');
        //   }
        // }
        
        Get.snackbar(
          'Payment Successful!',
          '₹${amount.toStringAsFixed(2)} added to wallet',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed', 
      response.message ?? 'Payment cancelled',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Selected: ${response.walletName}');
  }

  void _showPaymentMethodSheet(double amount) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            ...controller.paymentGateways.map((gateway) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildPaymentOption(
                gateway['displayName'],
                gateway['description'],
                Icons.payment,
                () async {
                  Get.back();
                  await Future.delayed(Duration(milliseconds: 500));
                  switch(gateway['name']) {
                    case 'razorpay':
                      await _openRazorpay(amount);
                      break;
                    case 'cashfree':
                      controller.initiateCashfreeWalletPayment();
                      break;
                    case 'easypay':
                      controller.initiateEasyPayPayment();
                      break;
                    case 'ccavenue':
                      controller.initiateCCAvenuePayment();
                      break;
                  }
                },
              ),
            )).toList(),
            SizedBox(height: 20),
          ],
        )),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF00ADD9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Color(0xFF00ADD9),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String? _currentOrderId;

  // Future<void> _verifyCustomerPayment({
  //   required String paymentId,
  //   required String orderId,
  //   required String signature,
  //   required double amount,
  // }) async {
  //   try {
  //     final apiService = Get.find<ApiService>();
  //     await apiService.addCustomerFunds(
  //       amount: amount,
  //       paymentMethod: 'Razorpay',
  //       transactionId: paymentId,
  //       description: 'Razorpay payment: $paymentId',
  //     );
  //   } catch (e) {
  //     print('Customer payment verification error: $e');
  //   }
  // }

  Future<void> _openRazorpay(double amount) async {
    // if (controller.isCustomer.value) {
    //   await _openCustomerRazorpay(amount);
    // } else {
      _openAgentRazorpay(amount);
    // }
  }

  // Future<void> _openCustomerRazorpay(double amount) async {
  //   try {
  //     final razorpayKey = storage.read('razorpay_key') ?? '';
  //
  //     if (razorpayKey.isEmpty) {
  //       Get.snackbar('Error', 'Payment gateway not configured');
  //       return;
  //     }
  //
  //     print('Creating Razorpay order for customer...');
  //     final order = await apiService.getRazorPayOrderIdCustomer(amount);
  //     print('Order created: ${order.id}');
  //
  //     var options = {
  //       'key': razorpayKey,
  //       'amount': (amount * 100).toInt(),
  //       'name': 'AAVIN',
  //       'description': 'Add ₹${amount.toStringAsFixed(2)} to wallet',
  //       'order_id': order.id,
  //       'prefill': {
  //         'contact': controller.customerData.value?.mobileNumber ?? '',
  //         'email': controller.customerData.value?.email ?? '',
  //         'name': controller.customerData.value?.fullName ?? '',
  //       },
  //       'theme': {
  //         'color': '#00ADD9'
  //       }
  //     };
  //
  //     print('Opening Razorpay with options: $options');
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Future.delayed(const Duration(milliseconds: 500), () {
  //         _razorpay.open(options);
  //       });
  //     });
  //   } catch (e) {
  //     print('Razorpay error: $e');
  //     Get.snackbar('Error', 'Failed to create payment order: $e',
  //       backgroundColor: Colors.red, colorText: Colors.white);
  //   }
  // }

  Future<void> _openAgentRazorpay(double amount) async {
    try {
      final razorpayKey = storage.read('razorpay_key') ?? '';
      
      if (razorpayKey.isEmpty) {
        Get.snackbar('Error', 'Payment gateway not configured');
        return;
      }
      
      print('Creating Razorpay order for agent...');
      final order = await apiService.getRazorPayOrderId(amount);
      print('Order created: ${order.id}');

      var options = {
        'key': razorpayKey,
        'amount': (amount * 100).toInt(),
        'name': 'AAVIN',
        'order_id': order.id,
        'description': 'Add ₹${amount.toStringAsFixed(2)} to wallet',
        'prefill': {
          'contact': controller.agentData.value?.mobileNumber ?? '',
          'email': '',
          'name': controller.agentData.value?.name ?? '',
        },
        'theme': {
          'color': '#00ADD9'
        }
      };

      print('Opening Razorpay with options: $options');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _razorpay.open(options);
        });
      });
    } catch (e) {
      print('Razorpay error: $e');
      Get.snackbar('Error', 'Failed to open payment: $e',
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Stack(
        children: [
          _buildHeader(context),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletCard(),
                    SizedBox(height: 24),
                    _buildAmountSection(controller),
                    SizedBox(height: 40),
                    _buildAddFundsButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/Vector.svg',
                fit: BoxFit.fill,
                width: double.infinity,
                colorFilter: ColorFilter.mode(
                  Color(0xFF00ADD9),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Add Funds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFF00ADD9).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF00ADD9),
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Money to Wallet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quick and secure payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(AddFundsController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha:0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha:0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
                prefixIcon: Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00ADD9),
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildQuickAmountButton('₹100', 100, controller),
              SizedBox(width: 12),
              _buildQuickAmountButton('₹500', 500, controller),
              SizedBox(width: 12),
              _buildQuickAmountButton('₹1000', 1000, controller),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, double amount, AddFundsController controller) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.amountController.text = amount.toStringAsFixed(0);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF00ADD9).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFF00ADD9).withValues(alpha:0.3)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00ADD9),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildAddFundsButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : () {
          final amount = double.tryParse(controller.amountController.text);
          if (amount == null || amount <= 0) {
            Get.snackbar('Error', 'Please enter a valid amount');
            return;
          }
          _showPaymentMethodSheet(amount);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00ADD9),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Add Funds to Wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    ));
  }


}

