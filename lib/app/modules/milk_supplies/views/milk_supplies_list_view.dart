import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';

class MilkSuppliesListView extends StatefulWidget {
  @override
  State<MilkSuppliesListView> createState() => _MilkSuppliesListViewState();
}

class _MilkSuppliesListViewState extends State<MilkSuppliesListView> {
  List<dynamic> supplies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSupplies();
  }

  Future<void> _loadSupplies() async {
    setState(() => isLoading = true);
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.getMilkSupplies();
      setState(() {
        supplies = response['supplies'] ?? [];
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
        title: Text('Milk Supplies', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : supplies.isEmpty
              ? Center(child: Text('No supplies found'))
              : RefreshIndicator(
                  onRefresh: _loadSupplies,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: supplies.length,
                    itemBuilder: (context, index) {
                      final supply = supplies[index];
                      return _buildSupplyCard(supply);
                    },
                  ),
                ),
    );
  }

  Widget _buildSupplyCard(dynamic supply) {
    final shift = supply['shift'] == 1 ? 'Morning' : 'Evening';
    final date = supply['reportDate']?.toString().split('T')[0] ?? '';
    
    return GestureDetector(
      onTap: () => Get.toNamed('/milk-supplies/${supply['id']}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
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
                color: supply['shift'] == 1 ? Color(0xFFFF7A00).withOpacity(0.1) : Color(0xFF007BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                supply['shift'] == 1 ? Icons.wb_sunny : Icons.nightlight_round,
                color: supply['shift'] == 1 ? Color(0xFFFF7A00) : Color(0xFF007BFF),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$shift - $date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${supply['totalLiters']} L | ${supply['totalFarmers']} Farmers',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
