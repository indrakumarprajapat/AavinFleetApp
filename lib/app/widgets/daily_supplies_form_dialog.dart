import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import '../models/society_supply.dart';

class DailySuppliesFormDialog extends StatefulWidget {
  final int slotId;
  final int shift;
  final String slotDate;
  final String shiftName;

  const DailySuppliesFormDialog({
    Key? key,
    required this.slotId,
    required this.shift,
    required this.slotDate,
    required this.shiftName,
  }) : super(key: key);

  @override
  State<DailySuppliesFormDialog> createState() => _DailySuppliesFormDialogState();
}

class _DailySuppliesFormDialogState extends State<DailySuppliesFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Milk Collection
  final _totalSamplesController = TextEditingController();
  final _totalQtyController = TextEditingController();
  final _localSalesQtyController = TextEditingController();
  final _sentToUnionQtyController = TextEditingController();
  final _avgSnfController = TextEditingController();
  final _avgFatController = TextEditingController();
  final _avgPurchaseRateController = TextEditingController();

  // Step 2: Sample Milk
  final _sampleTotalController = TextEditingController();
  final _sampleMilkQtyController = TextEditingController();
  final _freeMilkStaffQtyController = TextEditingController();
  final _netSampleQtyController = TextEditingController();
  final _mpcsAccountQtyController = TextEditingController();
  final _saleAccountQtyController = TextEditingController();

  // Step 3: Cash Balance
  final _openingBalanceController = TextEditingController();
  final _localSalesValueController = TextEditingController();
  final _otherIncomeController = TextEditingController();
  final _totalExpenditureController = TextEditingController();
  final _closingBalanceController = TextEditingController();

  // Step 4: Cattle Feed & FSS
  final _cfStockBagsController = TextEditingController();
  final _cfSalesBagsController = TextEditingController();
  final _cfClosingBagsController = TextEditingController();
  final _fssNosController = TextEditingController();
  final _fssOpeningBalanceController = TextEditingController();
  final _fssReceiptController = TextEditingController();
  final _fssTotalController = TextEditingController();
  final _fssIssueController = TextEditingController();
  final _fssClosingBalanceController = TextEditingController();

  @override
  void dispose() {
    _totalSamplesController.dispose();
    _totalQtyController.dispose();
    _localSalesQtyController.dispose();
    _sentToUnionQtyController.dispose();
    _avgSnfController.dispose();
    _avgFatController.dispose();
    _avgPurchaseRateController.dispose();
    _sampleTotalController.dispose();
    _sampleMilkQtyController.dispose();
    _freeMilkStaffQtyController.dispose();
    _netSampleQtyController.dispose();
    _mpcsAccountQtyController.dispose();
    _saleAccountQtyController.dispose();
    _openingBalanceController.dispose();
    _localSalesValueController.dispose();
    _otherIncomeController.dispose();
    _totalExpenditureController.dispose();
    _closingBalanceController.dispose();
    _cfStockBagsController.dispose();
    _cfSalesBagsController.dispose();
    _cfClosingBagsController.dispose();
    _fssNosController.dispose();
    _fssOpeningBalanceController.dispose();
    _fssReceiptController.dispose();
    _fssTotalController.dispose();
    _fssIssueController.dispose();
    _fssClosingBalanceController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _totalSamplesController.text.isNotEmpty &&
            _totalQtyController.text.isNotEmpty &&
            _localSalesQtyController.text.isNotEmpty &&
            _sentToUnionQtyController.text.isNotEmpty &&
            _avgSnfController.text.isNotEmpty &&
            _avgFatController.text.isNotEmpty &&
            _avgPurchaseRateController.text.isNotEmpty;
      case 1:
        return _sampleTotalController.text.isNotEmpty &&
            _sampleMilkQtyController.text.isNotEmpty &&
            _freeMilkStaffQtyController.text.isNotEmpty &&
            _netSampleQtyController.text.isNotEmpty &&
            _mpcsAccountQtyController.text.isNotEmpty &&
            _saleAccountQtyController.text.isNotEmpty;
      case 2:
        return _openingBalanceController.text.isNotEmpty &&
            _localSalesValueController.text.isNotEmpty &&
            _otherIncomeController.text.isNotEmpty &&
            _totalExpenditureController.text.isNotEmpty &&
            _closingBalanceController.text.isNotEmpty;
      case 3:
        return _cfStockBagsController.text.isNotEmpty &&
            _cfSalesBagsController.text.isNotEmpty &&
            _cfClosingBagsController.text.isNotEmpty &&
            _fssNosController.text.isNotEmpty &&
            _fssOpeningBalanceController.text.isNotEmpty &&
            _fssReceiptController.text.isNotEmpty &&
            _fssTotalController.text.isNotEmpty &&
            _fssIssueController.text.isNotEmpty &&
            _fssClosingBalanceController.text.isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    } else {
      Get.snackbar('Error', 'Please fill all fields',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final apiService = Get.find<ApiService>();
      final supply = SocietySupply(
        slotId: widget.slotId,
        supplyDate: widget.slotDate,
        shift: widget.shift,
        collectionTotalSamples: double.parse(_totalSamplesController.text),
        collectionTotalQty: double.parse(_totalQtyController.text),
        collectionTotalLocalSalesQty: double.parse(_localSalesQtyController.text),
        collectionTotalSentToUnionQty: double.parse(_sentToUnionQtyController.text),
        collectionAvgSnf: double.parse(_avgSnfController.text),
        collectionAvgFat: double.parse(_avgFatController.text),
        collectionAvgPurchaseRate: double.parse(_avgPurchaseRateController.text),
        sampleTotal: double.parse(_sampleTotalController.text),
        sampleMilkQty: double.parse(_sampleMilkQtyController.text),
        sampleFreeMilkStaffQty: double.parse(_freeMilkStaffQtyController.text),
        sampleNetSampleQty: double.parse(_netSampleQtyController.text),
        sampleMpcsAccountQty: double.parse(_mpcsAccountQtyController.text),
        sampleSaleAccountQty: double.parse(_saleAccountQtyController.text),
        openingBalance: double.parse(_openingBalanceController.text),
        localSalesValue: double.parse(_localSalesValueController.text),
        otherIncome: double.parse(_otherIncomeController.text),
        totalExpenditure: double.parse(_totalExpenditureController.text),
        closingBalance: double.parse(_closingBalanceController.text),
        cfStockBags: double.parse(_cfStockBagsController.text),
        cfSalesBags: double.parse(_cfSalesBagsController.text),
        cfClosingBags: double.parse(_cfClosingBagsController.text),
        fssNos: double.parse(_fssNosController.text),
        fssOpeningBalance: double.parse(_fssOpeningBalanceController.text),
        fssReceipt: double.parse(_fssReceiptController.text),
        fssTotal: double.parse(_fssTotalController.text),
        fssIssue: double.parse(_fssIssueController.text),
        fssClosingBalance: double.parse(_fssClosingBalanceController.text),
      );

      await apiService.submitDailySupplies(supply.toJson());

      Get.back();
      Get.snackbar('Success', 'Daily supplies submitted successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF00ADD9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daily Supplies - ${widget.shiftName}',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: _buildCurrentStep(),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.grey.shade100,
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? Color(0xFF00ADD9) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Milk Collection'),
        SizedBox(height: 16),
        _buildTextField(_totalSamplesController, 'Total Samples', Icons.people),
        SizedBox(height: 12),
        _buildTextField(_totalQtyController, 'Total Qty', Icons.water_drop),
        SizedBox(height: 12),
        _buildTextField(_localSalesQtyController, 'Total Local Sales', Icons.store),
        SizedBox(height: 12),
        _buildTextField(_sentToUnionQtyController, 'Total sent to Union Qty', Icons.local_shipping),
        SizedBox(height: 16),
        _buildSectionTitle('Purchase Average'),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField(_avgSnfController, 'SNF %', Icons.science)),
            SizedBox(width: 12),
            Expanded(child: _buildTextField(_avgFatController, 'FAT %', Icons.opacity)),
          ],
        ),
        SizedBox(height: 12),
        _buildTextField(_avgPurchaseRateController, 'Average Purchase rate', Icons.currency_rupee),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sample Milk'),
        SizedBox(height: 16),
        _buildTextField(_sampleTotalController, 'Total Sample', Icons.science),
        SizedBox(height: 12),
        _buildTextField(_sampleMilkQtyController, 'Total Sample Milk Qty', Icons.water_drop),
        SizedBox(height: 12),
        _buildTextField(_freeMilkStaffQtyController, 'Free Milk availed by staffs', Icons.people),
        SizedBox(height: 12),
        _buildTextField(_netSampleQtyController, 'Net Qty accounted', Icons.calculate),
        SizedBox(height: 12),
        _buildTextField(_mpcsAccountQtyController, 'Sample Milk MPCS account', Icons.account_balance),
        SizedBox(height: 12),
        _buildTextField(_saleAccountQtyController, 'Sample Milk Sale account', Icons.point_of_sale),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Cash Balance'),
        SizedBox(height: 16),
        _buildTextField(_openingBalanceController, 'Opening balance (Rs)', Icons.account_balance_wallet),
        SizedBox(height: 12),
        _buildTextField(_localSalesValueController, 'Local sales value (Rs)', Icons.store),
        SizedBox(height: 12),
        _buildTextField(_otherIncomeController, 'Other income (Rs)', Icons.attach_money),
        SizedBox(height: 12),
        _buildTextField(_totalExpenditureController, 'Total Expenditure (Rs)', Icons.money_off),
        SizedBox(height: 12),
        _buildTextField(_closingBalanceController, 'Closing Balance (Rs)', Icons.account_balance),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Cattle feed details in bag'),
        SizedBox(height: 16),
        _buildTextField(_cfStockBagsController, 'Cattle feed stock in bag', Icons.inventory),
        SizedBox(height: 12),
        _buildTextField(_cfSalesBagsController, 'Cattle feed sales in bag', Icons.shopping_bag),
        SizedBox(height: 12),
        _buildTextField(_cfClosingBagsController, 'Cattle feed Closing Balance', Icons.inventory_2),
        SizedBox(height: 24),
        _buildSectionTitle('FSS details'),
        SizedBox(height: 16),
        _buildTextField(_fssNosController, 'FSS in Nos.', Icons.numbers),
        SizedBox(height: 12),
        _buildTextField(_fssOpeningBalanceController, 'Opening Balance', Icons.account_balance_wallet),
        SizedBox(height: 12),
        _buildTextField(_fssReceiptController, 'Receipt', Icons.receipt),
        SizedBox(height: 12),
        _buildTextField(_fssTotalController, 'Total', Icons.calculate),
        SizedBox(height: 12),
        _buildTextField(_fssIssueController, 'Issue', Icons.error_outline),
        SizedBox(height: 12),
        _buildTextField(_fssClosingBalanceController, 'Closing balance', Icons.account_balance),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF00ADD9)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF00ADD9), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Color(0xFF00ADD9)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Previous', style: TextStyle(fontSize: 16, color: Color(0xFF00ADD9))),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00ADD9),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == 3 ? 'Submit' : 'Next',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
