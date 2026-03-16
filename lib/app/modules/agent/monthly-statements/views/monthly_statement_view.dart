import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/monthly_statement_controller.dart';

class MonthlyStatementView extends StatelessWidget {
  const MonthlyStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonthlyStatementController());
    
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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFF00ADD9)),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildMonthSelector(controller),
                      SizedBox(height: 16),
                      if (controller.commissionStatement.value != null) ...[
                        SizedBox(height: 16),
                        _buildDailyDataList(controller),
                      ] else
                        _buildNoDataCard(),
                    ],
                  ),
                );
              }),
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
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Monthly Statement',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(MonthlyStatementController controller) {
    return GestureDetector(
      onTap: () => _showMonthPicker(controller),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00ABD5).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFF00ADD9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_month, color: Color(0xFF00ADD9), size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM yyyy').format(controller.selectedMonth.value),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDataList(MonthlyStatementController controller) {
    final dailyData = controller.commissionStatement.value!.dailyData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Text(
            //   'Daily Breakdown',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.w600,
            //     color: Colors.black87,
            //     fontFamily: 'Poppins',
            //   ),
            // ),
            if (dailyData.isNotEmpty)
              GestureDetector(
                onTap: () => controller.downloadMonthlyStatementPdf(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(() => controller.isDownloading.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Download',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                  ),
                ),
              ),
          ],
        ),
        // SizedBox(height: 12),
        // ...dailyData.map((data) => Container(
        //   margin: EdgeInsets.only(bottom: 12),
        //   padding: EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [
        //         Color(0xFFFFFFFF),
        //         Color(0xFFFFFFFF).withValues(alpha: 0.8),
        //       ],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Color(0xFF00ABD5).withValues(alpha: 0.2),
        //         blurRadius: 12,
        //         offset: Offset(0, 4),
        //       ),
        //     ],
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text(
        //             data.date,
        //             style: TextStyle(
        //               fontSize: 16,
        //               fontWeight: FontWeight.w600,
        //               color: Colors.black87,
        //               fontFamily: 'Poppins',
        //             ),
        //           ),
        //           Text(
        //             '₹${data.totalCommission.toStringAsFixed(2)}',
        //             style: TextStyle(
        //               fontSize: 16,
        //               fontWeight: FontWeight.bold,
        //               color: Color(0xFF00ADD9),
        //               fontFamily: 'Poppins',
        //             ),
        //           ),
        //         ],
        //       ),
        //       SizedBox(height: 12),
        //       _buildDetailRow('Milk Amount', '₹${data.milkAmount.toStringAsFixed(2)}'),
        //       _buildDetailRow('SGM Amount', '₹${data.sgmMilkAmount.toStringAsFixed(2)}'),
        //       _buildDetailRow('Gross Commission', '₹${data.grossCommission.toStringAsFixed(2)}'),
        //       _buildDetailRow('TDS (5%)', '₹${data.tds5Percent.toStringAsFixed(2)}'),
        //     ],
        //   ),
        // )).toList(),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00ABD5).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No commission data available for this month',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(MonthlyStatementController controller) {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () {
                      Navigator.pop(context);
                      controller.loadCommissionStatement();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.monthYear,
                initialDateTime: controller.selectedMonth.value,
                maximumDate: DateTime.now(),
                minimumDate: DateTime(2020),
                onDateTimeChanged: (DateTime newDate) {
                  controller.selectedMonth.value = newDate;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


}