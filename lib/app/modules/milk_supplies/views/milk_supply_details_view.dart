import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';

class MilkSupplyDetailsView extends StatefulWidget {
  @override
  State<MilkSupplyDetailsView> createState() => _MilkSupplyDetailsViewState();
}

class _MilkSupplyDetailsViewState extends State<MilkSupplyDetailsView> {
  Map<String, dynamic>? supply;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final id = Get.parameters['id'];
    if (id == null) return;

    setState(() => isLoading = true);
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getMilkSupplyDetails(int.parse(id));
      setState(() {
        supply = response['supply'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Color(0xFF00ADD9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('Supply Details', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : supply == null
              ? Center(child: Text('Supply not found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailCard('Shift', supply!['shift'] == 1 ? 'Morning' : 'Evening'),
                      _buildDetailCard('Date', supply!['reportDate']?.toString().split('T')[0] ?? ''),
                      _buildDetailCard('Total Farmers', supply!['totalFarmers'].toString()),
                      _buildDetailCard('Total Liters', supply!['totalLiters'].toString()),
                      _buildDetailCard('Local Sales', supply!['localSales'].toString()),
                      _buildDetailCard('Sent to Union', supply!['sentToUnion'].toString()),
                      _buildDetailCard('Fat %', supply!['fatPercentage'].toString()),
                      _buildDetailCard('SNF', supply!['snf'].toString()),
                      _buildDetailCard('CF Stock', supply!['cfStock'].toString()),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
