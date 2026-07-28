import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../models/collection_trip.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/location-utils.dart';

class CollectionSubmitController extends GetxController {
  final apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  late final int tripId;
  late final bool isMcr;

  final canCountCtrl = TextEditingController();
  final canSizeCtrl = TextEditingController(text: '40');
  final milkQtyCtrl = TextEditingController();
  final fatCtrl = TextEditingController();
  final snfCtrl = TextEditingController();

  final fcLtrCtrl = TextEditingController();
  final mcLtrCtrl = TextEditingController();
  final rcLtrCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  final collectedSummary = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    tripId = args['tripId'] as int? ?? 0;
    isMcr = args['isMcr'] as bool? ?? true;
    _prefillFromTrip();
  }

  Future<void> _prefillFromTrip() async {
    try {
      final trip = await apiService.getCollectionTripDetail(tripId);
      _applyPrefill(trip);
    } catch (_) {
      // Prefill is optional
    }
  }

  void _applyPrefill(CollectionTrip trip) {
    final doneStops = trip.stops.where((s) => s.isDone).toList();
    if (doneStops.isEmpty) return;

    if (isMcr) {
      final cans = doneStops.fold<int>(0, (s, e) => s + e.canCount);
      final milk = doneStops.fold<double>(0, (s, e) => s + e.milkQtyLtr);
      final fatSum = doneStops.fold<double>(0, (s, e) => s + e.fatPercent);
      final snfSum = doneStops.fold<double>(0, (s, e) => s + e.snfPercent);
      final n = doneStops.length;
      final size = doneStops
              .map((e) => e.canSizeLtr)
              .firstWhere((v) => v > 0, orElse: () => 40.0);

      canCountCtrl.text = cans > 0 ? '$cans' : '';
      canSizeCtrl.text = _fmt(size);
      milkQtyCtrl.text = milk > 0 ? _fmt(milk) : '';
      fatCtrl.text = n > 0 ? _fmt(fatSum / n) : '';
      snfCtrl.text = n > 0 ? _fmt(snfSum / n) : '';
      collectedSummary.value =
          'From ${doneStops.length} stop(s): $cans cans · ${_fmt(milk)} L';
    } else {
      final fc = doneStops.fold<double>(0, (s, e) => s + e.fcLtr);
      final mc = doneStops.fold<double>(0, (s, e) => s + e.mcLtr);
      final rc = doneStops.fold<double>(0, (s, e) => s + e.rcLtr);
      fcLtrCtrl.text = fc > 0 ? _fmt(fc) : '';
      mcLtrCtrl.text = mc > 0 ? _fmt(mc) : '';
      rcLtrCtrl.text = rc > 0 ? _fmt(rc) : '';
      collectedSummary.value =
          'From ${doneStops.length} BMC(s): FC ${_fmt(fc)} · MC ${_fmt(mc)} · RC ${_fmt(rc)} L';
    }
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(2);

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  String? validatePositive(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return '$label must be greater than 0';
    return null;
  }

  String? validatePercent(String? v, String label) {
    final err = validatePositive(v, label);
    if (err != null) return err;
    final n = double.parse(v!.trim());
    if (n > 100) return '$label cannot exceed 100';
    return null;
  }

  bool _validate() {
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning(
        'Missing details',
        'Please fill all required fields marked with *',
      );
      return false;
    }

    if (!isMcr) {
      final total = _d(fcLtrCtrl) + _d(mcLtrCtrl) + _d(rcLtrCtrl);
      if (total <= 0) {
        AppSnackbar.warning(
          'No milk entered',
          'Enter liters for at least one compartment',
        );
        return false;
      }
    }
    return true;
  }

  Future<void> submit() async {
    if (!_validate()) return;

    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              isMcr ? 'Confirm BMC submit?' : 'Confirm Dairy submit?',
              style: const TextStyle(color: Color(0xFF1B3A4B)),
            ),
            content: Text(
              isMcr
                  ? 'Milk will be marked as submitted at the BMC. Continue?'
                  : 'Milk will be marked as submitted at the Dairy. Continue?',
              style: const TextStyle(color: Color(0xFF455A64)),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Confirm'),
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

      final body = <String, dynamic>{
        'lat': lat,
        'lng': lng,
        'remarks': remarksCtrl.text.trim(),
      };

      if (isMcr) {
        final cans = _i(canCountCtrl);
        final size = _d(canSizeCtrl);
        body['canCount'] = cans;
        body['canSizeLtr'] = size;
        body['milkQtyLtr'] =
            milkQtyCtrl.text.trim().isEmpty ? cans * size : _d(milkQtyCtrl);
        body['fatPercent'] = _d(fatCtrl);
        body['snfPercent'] = _d(snfCtrl);
      } else {
        body['fcLtr'] = _d(fcLtrCtrl);
        body['mcLtr'] = _d(mcLtrCtrl);
        body['rcLtr'] = _d(rcLtrCtrl);
        body['milkQtyLtr'] = _d(fcLtrCtrl) + _d(mcLtrCtrl) + _d(rcLtrCtrl);
        body['fatPercent'] = _d(fatCtrl);
        body['snfPercent'] = _d(snfCtrl);
      }

      await apiService.markCollectionSubmit(tripId, body);
      Get.back(result: true);
      Future.microtask(() {
        AppSnackbar.success(
          'Submitted',
          isMcr ? 'Milk submitted at BMC' : 'Milk submitted at Dairy',
        );
      });
    } catch (e) {
      AppSnackbar.error('Submit failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    canCountCtrl.dispose();
    canSizeCtrl.dispose();
    milkQtyCtrl.dispose();
    fatCtrl.dispose();
    snfCtrl.dispose();
    fcLtrCtrl.dispose();
    mcLtrCtrl.dispose();
    rcLtrCtrl.dispose();
    remarksCtrl.dispose();
    super.onClose();
  }
}
