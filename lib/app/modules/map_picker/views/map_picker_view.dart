import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../config/app_config.dart';
import '../../../constants/app_colors.dart';
import '../controllers/map_picker_controller.dart';

class MapPickerView extends GetView<MapPickerController> {
  const MapPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Address'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.selectedAddress.value.isNotEmpty
                ? () => Get.back(result: {
                      'address': controller.selectedAddress.value,
                      'latitude': controller.selectedLatLng.value?.latitude,
                      'longitude': controller.selectedLatLng.value?.longitude,
                    })
                : null,
            child: Text(
              'DONE',
              style: TextStyle(
                color: controller.selectedAddress.value.isNotEmpty
                    ? AppColors.white
                    : AppColors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: controller.onSearchChanged,
                  onSubmitted: controller.searchLocation,
                ),
                
                // Search Suggestions
                Obx(() => controller.showSuggestions.value
                    ? Container(
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = controller.searchSuggestions[index];
                            return ListTile(
                              leading: Icon(Icons.location_on, color: AppColors.primary),
                              title: Text(
                                suggestion['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              onTap: () => controller.selectSuggestion(suggestion),
                              dense: true,
                            );
                          },
                        ),
                      )
                    : SizedBox()),
              ],
            ),
          ),
          
          Expanded(
            child: GetBuilder<MapPickerController>(
              builder: (controller) => GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: Get.find<ClientConfig>().centerLocation,
                  zoom: 15,
                ),
                markers: controller.markers,
                onTap: controller.onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
          ),
          
          Obx(() => controller.selectedAddress.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  color: AppColors.cardBackground,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Address:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.selectedAddress.value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.getCurrentLocation,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.my_location, color: AppColors.white),
      ),
    );
  }
}