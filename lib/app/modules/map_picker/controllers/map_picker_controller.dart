import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../api/api_service.dart';
import '../../../config/app_config.dart';
import '../../../constants/api_constants.dart';
import '../../../utils/location-utils.dart';

class MapPickerController extends GetxController {
  GoogleMapController? mapController;
  final searchController = TextEditingController();
  final currentLocation = Get.find<ClientConfig>().centerLocation.obs;
  final selectedLatLng = Rxn<LatLng>();
  final selectedAddress = ''.obs;
  Set<Marker> markers = <Marker>{};
  final isLoading = false.obs;
  RxList<Map<String, dynamic>> searchSuggestions = <Map<String, dynamic>>[].obs;
  final showSuggestions = false.obs;
  String _googleApiKey = '';
  final apiService = Get.find<ApiService>();

  @override
  Future<void> onInit() async {
    super.onInit();
    getCurrentLocation();
    _googleApiKey = await apiService.fetchGoogleApiKey();
  }
  


  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Animate to default location after map is ready
    Future.delayed(Duration(milliseconds: 300), () {
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLocation.value),
        );
      }
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      final allowed = await LocationUtils.ensureLocationPermission();
      if (!allowed) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // if (!serviceEnabled) {
      //   Get.snackbar('Error', 'Location services are disabled');
      //   return;
      // }
      //
      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      //   if (permission == LocationPermission.denied) {
      //     Get.snackbar('Error', 'Location permissions are denied');
      //     return;
      //   }
      // }
      //
      // Position position = await Geolocator.getCurrentPosition();
      // LatLng newLocation = LatLng(position.latitude, position.longitude);
      
      currentLocation.value = newLocation;
      selectedLatLng.value = newLocation; // Auto-select current location
      
      // Add marker for current location
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('current'),
          position: newLocation,
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
      update();
      
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(newLocation),
        );
      }
      
      await getAddressFromLatLng(newLocation);
    } catch (e) {
      Get.snackbar('Error', 'Failed to get current location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onMapTap(LatLng latLng) async {
    selectedLatLng.value = latLng;
    
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('selected'),
        position: latLng,
        infoWindow: InfoWindow(title: 'Selected Location'),
      ),
    );
    update();
    
    await getAddressFromLatLng(latLng);
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        selectedAddress.value = 
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      }
    } catch (e) {
      selectedAddress.value = 'Address not found';
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      isLoading.value = true;
      List<Location> locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newLatLng = LatLng(location.latitude, location.longitude);
        
        selectedLatLng.value = newLatLng;
        
        markers.clear();
        markers.add(
          Marker(
            markerId: MarkerId('searched'),
            position: newLatLng,
            infoWindow: InfoWindow(title: query),
          ),
        );
        update();
        
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLng(newLatLng),
          );
        }
        
        await getAddressFromLatLng(newLatLng);
      } else {
        Get.snackbar('Error', 'Location not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to search location: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchSuggestions.clear();
    showSuggestions.value = false;
  }

  Future<void> onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      searchSuggestions.clear();
      showSuggestions.value = false;
      return;
    }
    
    await getPlacesSuggestions(query);
  }

  Future<void> getPlacesSuggestions(String query) async {
    try {
      if (_googleApiKey.isEmpty) {
        _showFallbackSuggestions(query);
        return;
      }
      
      final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      
      final response = await Dio().get(url, queryParameters: {
        'input': query,
        'key': _googleApiKey,
        'location': '${currentLocation.value.latitude},${currentLocation.value.longitude}',
        'radius': '500000', 
        'components': 'country:in',
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          if (predictions.isNotEmpty) {
            searchSuggestions.value = predictions.map((prediction) => {
              'description': prediction['description'],
              'place_id': prediction['place_id'],
            }).toList();
            showSuggestions.value = true;
          } else {
            _showFallbackSuggestions(query);
          }
        } else {
          _showFallbackSuggestions(query);
        }
      } else {
        _showFallbackSuggestions(query);
      }
    } catch (e) {
      print('Places API Error: $e');
      _showFallbackSuggestions(query);
    }
  }
  
  void _showFallbackSuggestions(String query) {
    searchSuggestions.value = [
      {'description': '$query, Coimbatore, Tamil Nadu', 'place_id': ''},
      {'description': '$query Market, Coimbatore', 'place_id': ''},
      {'description': '$query Road, Coimbatore', 'place_id': ''},
      {'description': '$query Junction, Coimbatore', 'place_id': ''},
      {'description': '$query Area, Coimbatore', 'place_id': ''},
    ];
    showSuggestions.value = true;
  }

  void selectSuggestion(Map<String, dynamic> suggestion) {
    searchController.text = suggestion['description'];
    showSuggestions.value = false;
    
    if (suggestion['place_id'].isNotEmpty) {
      getPlaceDetails(suggestion['place_id']);
    } else {
      searchLocation(suggestion['description']);
    }
  }
  
  void confirmAddress() {
    if (selectedAddress.value.isNotEmpty && selectedLatLng.value != null) {
      Get.back(result: {
        'address': selectedAddress.value,
        'latitude': selectedLatLng.value!.latitude,
        'longitude': selectedLatLng.value!.longitude,
      });
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    try {
      if (_googleApiKey.isEmpty || placeId.isEmpty) {
        searchLocation(searchController.text);
        return;
      }
      
      final String url = 'https://maps.googleapis.com/maps/api/place/details/json';
      
      final response = await Dio().get(url, queryParameters: {
        'place_id': placeId,
        'key': _googleApiKey,
        'fields': 'geometry,formatted_address',
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final result = data['result'];
          final geometry = result['geometry']['location'];
          final address = result['formatted_address'];
          
          LatLng newLatLng = LatLng(geometry['lat'], geometry['lng']);
          
          selectedLatLng.value = newLatLng;
          selectedAddress.value = address;
          
          markers.clear();
          markers.add(
            Marker(
              markerId: MarkerId('place_details'),
              position: newLatLng,
              infoWindow: InfoWindow(title: address),
            ),
          );
          update();
          
          if (mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(newLatLng),
            );
          }
        }
      }
    } catch (e) {
      print('Place Details Error: $e');
      // Fallback to regular search
      searchLocation(searchController.text);
    }
  }
}