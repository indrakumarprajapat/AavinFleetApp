import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../modules/agent/claims/controllers/claims_controller.dart';

class ClaimsContentWidget extends StatelessWidget {
  final bool showHeader;
  const ClaimsContentWidget({super.key, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClaimsController>();
    return _buildContent(controller);
  }

  Widget _buildContent(ClaimsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          if (showHeader) _buildHeader(controller),
          _buildStatusFilter(controller),
          Expanded(
            child: _buildClaimsList(controller),
          ),
        ],
      );
    });
  }

  Widget _buildHeader(ClaimsController controller) {
    return Container(
      padding: EdgeInsets.only(top: 0,left: 16, right: 16, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 5,),
          Text(
            'Claims',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00ADD9),
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: () async {
              var result = await Get.toNamed('/create-claim');
              if (result != null) {
                controller.loadClaims();
              }
            },
            icon: Icon(Icons.add, size: 14),
            label: Text('Create', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00ADD9),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: Size(0, 32),
            ),
          ),
          SizedBox(width: 5)
        ],
      ),
    );
  }



  Widget _buildStatusFilter(ClaimsController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 0, controller),
            SizedBox(width: 8),
            _buildFilterChip('Pending', 1, controller),
            SizedBox(width: 8),
            _buildFilterChip('Approved', 2, controller),
            SizedBox(width: 8),
            _buildFilterChip('Rejected', 3, controller),
            SizedBox(width: 8),
            _buildFilterChip('Refunded', 4, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int status, ClaimsController controller) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      print(label);

      return GestureDetector(
        onTap: () => controller.filterByStatus(status),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF00ADD9) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Color(0xFF00ADD9) : Colors.grey.withValues(alpha:0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildClaimsList(ClaimsController controller) {
    if (controller.claims.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: controller.loadClaims,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.claims.length,
        itemBuilder: (context, index) {
          final claim = controller.claims[index];
          return _buildClaimCard(claim, controller);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No claims found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Create a claim for damaged items', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildClaimCard(ClaimModel claim, ClaimsController controller) {
    return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.only(left:12,right:10,top:0,bottom:0),
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
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text(
            'Claim #${claim.id}',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text('Order #${claim.orderId}'),
              SizedBox(height: 2),
              Text(claim.reason, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: controller.getStatusColor(claim.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.getStatusText(claim.status),
              style: TextStyle(
                color: controller.getStatusColor(claim.status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onTap: () => Get.toNamed('/claim-details', arguments: claim.id),
        ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}