import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../api/api_service.dart';
import '../../../constants/app_enums.dart';
import '../../../models/collection_trip.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/location-utils.dart';

class CollectionRouteController extends GetxController {
  final apiService = Get.find<ApiService>();
  final storage = GetStorage();

  final trip = Rxn<CollectionTrip>();
  final isLoading = false.obs;
  final currentIndex = 0.obs;

  int get tripId {
    final args = Get.arguments;
    if (args is int) return args;
    return storage.read('active_trip_id') ?? 0;
  }

  bool get isMcr => trip.value?.isMcr ?? true;

  List<CollectionStop> get stops => trip.value?.stops ?? [];

  CollectionStop? get currentStop {
    if (stops.isEmpty) return null;
    final pending = stops.indexWhere((s) => !s.isDone);
    if (pending >= 0) return stops[pending];
    return null;
  }

  bool get allStopsDone => trip.value?.allStopsDone == true;
  bool get isSubmitted => trip.value?.isSubmitted == true;

  int get doneCount => stops.where((s) => s.isDone).length;

  @override
  void onInit() {
    super.onInit();
    loadTrip();
  }

  Future<void> loadTrip() async {
    if (tripId == 0) {
      AppSnackbar.error('No trip', 'Trip id missing. Return to home and start again.');
      return;
    }
    try {
      isLoading.value = true;
      trip.value = await apiService.getCollectionTripDetail(tripId);
      final pending = stops.indexWhere((s) => !s.isDone);
      currentIndex.value = pending >= 0 ? pending : stops.length;
    } catch (e) {
      AppSnackbar.error('Could not load trip', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void openStop(CollectionStop stop) {
    Get.toNamed(
      Routes.COLLECTION_STOP,
      arguments: {'tripId': tripId, 'stop': stop, 'isMcr': isMcr},
    )?.then((_) => loadTrip());
  }

  void openSubmit() {
    if (!allStopsDone) {
      AppSnackbar.warning(
        'Stops pending',
        'Collect or skip all stops before submitting.',
      );
      return;
    }
    Get.toNamed(
      Routes.COLLECTION_SUBMIT,
      arguments: {'tripId': tripId, 'isMcr': isMcr},
    )?.then((_) => loadTrip());
  }

  Future<void> endTrip() async {
    if (!isSubmitted) {
      AppSnackbar.warning(
        'Submit pending',
        isMcr
            ? 'Submit milk at BMC before ending the trip.'
            : 'Submit milk at Dairy before ending the trip.',
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'End trip?',
              style: TextStyle(color: Color(0xFF1B3A4B)),
            ),
            content: const Text(
              'This will complete the collection trip and return to home.',
              style: TextStyle(color: Color(0xFF455A64)),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('End trip'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    try {
      isLoading.value = true;
      final allowed = await LocationUtils.ensureLocationPermission();
      double lat = 0, lng = 0;
      if (allowed) {
        final pos = await LocationUtils.getCurrentLocation();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        }
      }
      await apiService.endCollectionTrip(tripId, lat, lng);
      storage.write('completed_trip_$tripId', true);
      storage.remove('active_trip_id');
      storage.remove('active_trip_kind');
      Get.offAllNamed(Routes.HOME);
      Future.microtask(() {
        AppSnackbar.success('Trip completed', 'Collection trip ended successfully');
      });
    } catch (e) {
      AppSnackbar.error('Could not end trip', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String statusLabel(CollectionStop stop) {
    switch (stop.stopStatus) {
      case CollectionStopStatus.collected:
        return 'COLLECTED';
      case CollectionStopStatus.partiallyCollected:
        return 'PARTIAL';
      case CollectionStopStatus.skipped:
        return 'SKIPPED';
      case CollectionStopStatus.pending:
        return 'PENDING';
    }
  }

  Color statusColor(CollectionStop stop) {
    switch (stop.stopStatus) {
      case CollectionStopStatus.collected:
        return const Color(0xFF2E7D32);
      case CollectionStopStatus.partiallyCollected:
        return const Color(0xFFF9A825);
      case CollectionStopStatus.skipped:
        return const Color(0xFF757575);
      case CollectionStopStatus.pending:
        if (stop == currentStop) return const Color(0xFF007EA7);
        return const Color(0xFF90A4AE);
    }
  }
}
