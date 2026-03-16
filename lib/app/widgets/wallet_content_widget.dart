import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/add_funds/views/add_funds_view.dart';
import '../modules/agent/wallet/controllers/wallet_controller.dart';
import '../modules/agent/wallet_statements/views/wallet_statements_view.dart';

class WalletContentWidget extends StatelessWidget {
  const WalletContentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());
    return _buildContent(controller);
  }

  Widget _buildContent(WalletController controller) {
    return Obx(() => RefreshIndicator(
      onRefresh: controller.loadWalletData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: controller.isLoading.value
            ? SizedBox(
                height: Get.height * 0.6,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00ADD9),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWalletBalance(controller),
                  SizedBox(height: 24),
                  _buildActionButtons(controller),
                  SizedBox(height: 24),
                  _buildTransactionHistory(controller),
                  SizedBox(height: 100),
                ],
              ),
      ),
    ));
  }

  Widget _buildWalletBalance(WalletController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00ADD9), Color(0xFF0088CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ADD9).withValues(alpha:0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Wallet Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '₹${controller.currentBalance.value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(WalletController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Get.to(() => AddFundsView());
              if (result == true) {
                controller.loadWalletData();
              }
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add to Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.to(() => WalletStatementsView());
            },
            icon: Icon(Icons.description, color: Colors.white),
            label: Text('Statement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00ADD9),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        controller.transactions.isEmpty
            ? SizedBox(
                height: Get.height * 0.4,
                child: Center(
                  child: Text(
                    'No transactions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'credit';
    final amount = transaction['amount'] as double;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.only(left:12,right:10,top:8,bottom:8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.2),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit ? Colors.green.withValues(alpha:0.1) : Colors.red.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : ''}₹${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }


}