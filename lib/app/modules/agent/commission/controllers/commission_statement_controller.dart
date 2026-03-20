import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io';

import '../../../../api/agent_api_service.dart';
import '../../../../models/commission_statement_model.dart';
import '../../../../models/commission_pdf_response_model.dart';

class CommissionStatementController extends GetxController {
  final AgentApiService _apiService = Get.find<AgentApiService>();
  
  final isLoading = false.obs;
  final isDownloading = false.obs;
  final selectedMonth = DateTime.now().obs;
  final Rxn<CommissionStatementModel> commissionStatement = Rxn<CommissionStatementModel>();

  @override
  void onInit() {
    super.onInit();
    final monthParam = Get.parameters['month'];
    if (monthParam != null) {
      try {
        selectedMonth.value = DateFormat('yyyy-MM').parse(monthParam);
      } catch (e) {
        selectedMonth.value = DateTime.now();
      }
    }
    loadCommissionStatement();
  }

  Future<void> loadCommissionStatement() async {
    try {
      isLoading.value = true;
      final monthString = DateFormat('yyyy-MM').format(selectedMonth.value);
      commissionStatement.value = await _apiService.getCommissionStatement(month: monthString);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load commission statement: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadCommissionPdf() async {
    try {
      isDownloading.value = true;
      final monthString = DateFormat('yyyy-MM').format(selectedMonth.value);
      final pdfResponse = await _apiService.downloadCommissionPdf(month: monthString);
      
      if (pdfResponse.url.isNotEmpty) {
        final dir = await getTemporaryDirectory();
        final fileName = 'Commission_${monthString}.pdf';
        final filePath = '${dir.path}/$fileName';
        
        await Dio().download(pdfResponse.url, filePath);
        
        await Share.shareXFiles(
          [XFile(filePath)],
          text: "Commission Statement for $monthString",
        );
      } else {
        Get.snackbar('Error', 'PDF URL not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to download PDF: $e');
    } finally {
      isDownloading.value = false;
    }
  }
}