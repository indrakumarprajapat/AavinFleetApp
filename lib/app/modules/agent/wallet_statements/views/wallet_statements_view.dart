import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../models/transaction_model.dart';
import '../../../../api/api_service.dart';

class WalletStatementsView extends StatelessWidget {
  const WalletStatementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletStatementsController());
    return Obx(() {
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
                child: Column(
                  children: [
                    _buildAppliedFilters(controller),
                    Obx(() => controller.selectedType.value == 2 
                        ? _buildCreditOutstandingCard(controller) 
                        : SizedBox.shrink()),
                    Expanded(
                      child: controller.isLoading.value
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF00ADD9),
                              ),
                            )
                          : RefreshIndicator(
                        onRefresh: controller.loadTransactions,
                        child: controller.transactions.isEmpty
                            ? ListView(
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                  Center(
                                    child: Text(
                                      'No transactions found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : NotificationListener<ScrollNotification>(
                                onNotification: (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
                                    if (!controller.isLoadingMore.value && controller.hasMoreData.value && !controller.isLoading.value) {
                                      controller.loadMoreTransactions();
                                    }
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  controller: controller.scrollController,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(20),
                                  itemCount: controller.transactions.length + (controller.isLoadingMore.value ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == controller.transactions.length) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF00ADD9),
                                          ),
                                        ),
                                      );
                                    }
                                    final transaction = controller.transactions[index];
                                    return controller.buildTransactionCard(transaction);
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
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
                          'Statements',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.find<WalletStatementsController>().showFilterDialog(),
                      icon: Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditOutstandingCard(WalletStatementsController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 0, left: 20, right: 20,top:5),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Outstanding',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Total credit amount pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Text(
            '₹${controller.outstandingAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters(WalletStatementsController controller) {
    return Obx(() {
      final hasFilters = controller.selectedType.value != null || 
                        controller.fromDate.value != null || 
                        controller.toDate.value != null;
      if (!hasFilters) return SizedBox.shrink();
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (controller.selectedType.value != null)
                _buildFilterChipWithRemove(
                  controller.getTypeLabel(controller.selectedType.value!),
                  () => controller.removeTypeFilter(),
                ),
              if (controller.fromDate.value != null) ...[
                if (controller.selectedType.value != null) SizedBox(width: 8),
                _buildFilterChipWithRemove(
                  'From: ${controller.fromDate.value!.toIso8601String().split('T')[0]}',
                  () => controller.removeFromDateFilter(),
                ),
              ],
              if (controller.toDate.value != null) ...[
                if (controller.selectedType.value != null || controller.fromDate.value != null) SizedBox(width: 8),
                _buildFilterChipWithRemove(
                  'To: ${controller.toDate.value!.toIso8601String().split('T')[0]}',
                  () => controller.removeToDateFilter(),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
  Widget _buildFilterChipWithRemove(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF00ADD9).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF00ADD9).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF00ADD9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: Color(0xFF00ADD9),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletStatementsController extends GetxController {
  final transactions = <TransactionModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final ScrollController scrollController = ScrollController();
  int currentOffset = 0;
  final int limit = 20;
  
  final selectedType = Rxn<int>(3); // Default to Order (3)
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final _outstandingAmount = 0.0.obs;
  
  double get outstandingAmount => _outstandingAmount.value;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
 ever(selectedType, (type) {
      if (type == 2) {
        _loadCreditOutstanding();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      currentOffset = 0;
      transactions.clear();
      
      final apiService = Get.find<ApiService>();
      final data = await apiService.getTransactions(
        type: selectedType.value,
        fromDate: fromDate.value?.toIso8601String().split('T')[0],
        toDate: toDate.value?.toIso8601String().split('T')[0],
        limit: limit,
        offset: 0,
      );
      
      final newTransactions = (data as List? ?? [])
          .map((t) => TransactionModel.fromJson(t))
          .toList();
      transactions.value = newTransactions;
      currentOffset = limit;
      hasMoreData.value = newTransactions.length == limit;
      if (selectedType.value == 2) {
        _loadCreditOutstanding();
      }
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to load transactions: $e');
    }
  }
  
  Future<void> _loadCreditOutstanding() async {
    try {
      final apiService = Get.find<ApiService>();
      final creditOutstanding = await apiService.getCreditOutstanding();
      _outstandingAmount.value = creditOutstanding.outstandingAmount;
    } catch (e) {
      _outstandingAmount.value = 0.0;
    }
  }

  Future<void> loadMoreTransactions() async {
    try {
      isLoadingMore.value = true;
      
      final apiService = Get.find<ApiService>();
      final data = await apiService.getTransactions(
        type: selectedType.value,
        fromDate: fromDate.value?.toIso8601String().split('T')[0],
        toDate: toDate.value?.toIso8601String().split('T')[0],
        limit: limit,
        offset: currentOffset,
      );
      
      final newTransactions = (data as List? ?? [])
          .map((t) => TransactionModel.fromJson(t))
          .toList();
      transactions.addAll(newTransactions);
      currentOffset += limit;
      hasMoreData.value = newTransactions.length == limit;
      isLoadingMore.value = false;
    } catch (e) {
      isLoadingMore.value = false;
    }
  }

  Widget buildTransactionCard(TransactionModel transaction) {
    final isCredit = _isCredit(transaction);
    final amount = double.parse(transaction.amount);
    final title = _getTransactionTitle(transaction);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.withValues(alpha:0.1) : Colors.red.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
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
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Text(
                '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCredit ? Colors.green : Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: MediaQuery.of(Get.context!).size.width * 0.14),
              Text(
                formatDate(transaction.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontFamily: 'Poppins',
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  _getTransactionType(transaction),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isCredit(TransactionModel transaction) {
    switch (transaction.transactionType) {
      case 'wallet':
        return transaction.walletType == 1;
      case 'credit':
        return transaction.creditType == 2;
      case 'order':
        return false;
      default:
        return false;
    }
  }

  String _getTransactionTitle(TransactionModel transaction) {
    switch (transaction.transactionType) {
      case 'wallet':
        if (transaction.walletType == 1) {
          switch (transaction.referenceType) {
            case 2: return 'Commission Received';
            case 3: return 'Refund Received';
            case 4: return 'Wallet Recharge';
            default: return 'Money Added';
          }
        } else {
          switch (transaction.referenceType) {
            case 1: return 'Order Payment';
            case 5: return 'Withdrawal';
            default: return 'Money Deducted';
          }
        }
      case 'credit':
        return transaction.creditType == 1 ? 'Credit Added' : 'Credit Used';
      case 'order':
        return 'Order Payment';
      default:
        return 'Transaction';
    }
  }

  String _getTransactionType(TransactionModel transaction) {
    switch (transaction.transactionType) {
      case 'wallet':
        return 'Wallet';
      case 'credit':
        return 'Credit';
      case 'order':
        return 'Order';
      default:
        return 'Unknown';
    }
  }

  void showFilterDialog() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Filter Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      selectedType.value = null;
                      fromDate.value = null;
                      toDate.value = null;
                      loadTransactions();
                    },
                    child: Text('Clear All', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection('Transaction Type', [
                      // _buildFilterChip('All', null, selectedType),
                      _buildFilterChip('Wallet', 1, selectedType),
                      _buildFilterChip('Credit', 2, selectedType),
                      _buildFilterChip('Order', 3, selectedType),
                    ]),
                    SizedBox(height: 20),
                    _buildDateSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        loadTransactions();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00ADD9),
                      ),
                      child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterSection(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int? value, Rxn<int> selectedValue) {
    return Obx(() => FilterChip(
      label: Text(label),
      selected: selectedValue.value == value,
      onSelected: (selected) {
        selectedValue.value = selected ? value : null;
      },
      selectedColor: Color(0xFF00ADD9).withValues(alpha:0.2),
      checkmarkColor: Color(0xFF00ADD9),
    ));
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: () => _selectDate(true),
                child: Text(
                  fromDate.value?.toIso8601String().split('T')[0] ?? 'From Date',
                  style: TextStyle(
                    color: fromDate.value == null ? Colors.grey : Colors.black87,
                  ),
                ),
              )),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: () => _selectDate(false),
                child: Text(
                  toDate.value?.toIso8601String().split('T')[0] ?? 'To Date',
                  style: TextStyle(
                    color: toDate.value == null ? Colors.grey : Colors.black87,
                  ),
                ),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (isFromDate) {
        fromDate.value = picked;
      } else {
        toDate.value = picked;
      }
    }
  }

  String getTypeLabel(int type) {
    switch (type) {
      case 1: return 'Wallet';
      case 2: return 'Credit';
      case 3: return 'Order';
      default: return 'Unknown';
    }
  }

  void removeTypeFilter() {
    selectedType.value = null;
    loadTransactions();
  }

  void removeFromDateFilter() {
    fromDate.value = null;
    loadTransactions();
  }

  void removeToDateFilter() {
    toDate.value = null;
    loadTransactions();
  }

  String formatDate(String dateStr) {
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

  Widget _buildCreditOutstandingCard(WalletStatementsController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.credit_card,
              color: Colors.red,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Outstanding',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Total credit amount pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Text(
            '₹${controller.outstandingAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          )),
        ],
      ),
    );
  }
}