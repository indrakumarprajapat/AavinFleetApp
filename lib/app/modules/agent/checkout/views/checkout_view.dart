import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../widgets/error_boundary.dart';
import '../../../../widgets/global_header.dart';
import '../controllers/checkout_controller.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: _buildCheckoutContent(),
    );
  }

  Widget _buildCheckoutContent() {
    final controller = Get.put(CheckoutController());

    return Obx(() => PopScope(
        canPop: !(controller.isLoading || controller.isButtonDisabled),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),

          body: Column(
            children: [
              GlobalHeader(title: 'Checkout', showCart: false),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPaymentMethod(),
                      const SizedBox(height: 20),
                      _buildOrderSummary(),

                      // IMPORTANT: give extra space so last card
                      // doesn't hide behind the bottom button
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPlaceOrderButton(),
            ),
          ),
        )
    ));
  }

  Widget _buildPaymentMethod() {
    final controller = Get.find<CheckoutController>();
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (controller.boothData.value?.isWalletPayAllow ?? false)
            SizedBox(height: 12),
          if (controller.boothData.value?.isWalletPayAllow ?? false)
            GestureDetector(
            onTap: controller.canUseWallet ? () => controller.selectPaymentMethod(1) : null,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: controller.canUseWallet ? Color(0xFF00ADD9) : Colors.grey,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wallet Payment',
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.canUseWallet ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        Text(
                          'Balance: ₹${controller.walletBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: controller.canUseWallet ? Colors.grey[600] : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    controller.selectedPaymentMethod == 1 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                    color: controller.canUseWallet && controller.selectedPaymentMethod == 1 
                        ? Color(0xFF00ADD9) 
                        : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (controller.boothData.value?.isOnlinePayAllow ?? false)
            SizedBox(height: 5),
          if (controller.boothData.value?.isOnlinePayAllow ?? false)
            GestureDetector(
            onTap: () => controller.selectPaymentMethod(2),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12),
              // decoration: BoxDecoration(
              //   color: controller.selectedPaymentMethod == 2
              //       ? Colors.green.withValues(alpha:0.1)
              //       : Colors.transparent,
              //   borderRadius: BorderRadius.circular(8),
              // ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/rupee.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    controller.selectedPaymentMethod == 2 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                    color: controller.selectedPaymentMethod == 2 
                        ? Colors.green 
                        : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if ((controller.boothData.value?.isCredit ?? false) || (controller.boothData.value?.isCreditPayAllow ?? false))
            SizedBox(height: 5),
          if ((controller.boothData.value?.isCredit ?? false) || (controller.boothData.value?.isCreditPayAllow ?? false))
            GestureDetector(
              onTap: () => controller.selectPaymentMethod(3),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                // decoration: BoxDecoration(
                //   color: controller.selectedPaymentMethod == 3
                //       ? Color(0xFFFF9800).withValues(alpha:0.1)
                //       : Colors.transparent,
                //   borderRadius: BorderRadius.circular(8),
                // ),
                child: Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credit',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Outstanding: ₹${controller.outstandingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      controller.selectedPaymentMethod == 3 
                          ? Icons.radio_button_checked 
                          : Icons.radio_button_unchecked,
                      color: controller.selectedPaymentMethod == 3 
                          ? Color(0xFF1976D2)
                          : Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildOrderSummary() {
    final controller = Get.find<CheckoutController>();
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: TextStyle(fontSize: 16)),
              Text('₹${controller.subtotalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
            ],
          ),
          SizedBox(height: 4),
          Visibility(visible: controller.totalDiscount>0? true: false,
            child: Column(
              children: [
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount:', style: TextStyle(fontSize: 16)),
                    Text('₹${controller.totalDiscount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax:', style: TextStyle(fontSize: 16)),
              Text('₹${controller.totalTax.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('₹${controller.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildPlaceOrderButton() {
    final controller = Get.find<CheckoutController>();
    return Obx(() => ElevatedButton(
      onPressed: (controller.isLoading || controller.isButtonDisabled) ? null : () {
        if (controller.selectedPaymentMethod == 2) {
          _showPaymentMethodSheet(controller.totalAmount, controller);
        } else {
          controller.placeOrder();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: controller.isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              'PLACE ORDER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    ));
  }

  void _showPaymentMethodSheet(double amount, CheckoutController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                () {
                  Get.back();
                  switch(gateway['name']) {
                    case 'razorpay':
                      controller.initiateRazorpayPayment();
                      break;
                    case 'cashfree':
                      controller.initiateCashfreePayment();
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
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
}