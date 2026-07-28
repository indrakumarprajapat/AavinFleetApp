import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../../../constants/app_enums.dart';
import '../../../models/collection_trip.dart';
import '../../../utils/app_snackbar.dart';
import '../../../utils/location-utils.dart';

class CollectionStopController extends GetxController {
  final apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  late final int tripId;
  late final CollectionStop stop;
  late final bool isMcr;

  // MCR
  final canCountCtrl = TextEditingController();
  final canSizeCtrl = TextEditingController(text: '40');
  final milkQtyCtrl = TextEditingController();
  final fatCtrl = TextEditingController();
  final snfCtrl = TextEditingController();

  // MTR
  final fcLtrCtrl = TextEditingController();
  final fcFatCtrl = TextEditingController();
  final fcSnfCtrl = TextEditingController();
  final mcLtrCtrl = TextEditingController();
  final mcFatCtrl = TextEditingController();
  final mcSnfCtrl = TextEditingController();
  final rcLtrCtrl = TextEditingController();
  final rcFatCtrl = TextEditingController();
  final rcSnfCtrl = TextEditingController();

  final remarksCtrl = TextEditingController();

  bool get isAlreadyDone => stop.isDone;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    tripId = args['tripId'] as int? ?? 0;
    stop = args['stop'] as CollectionStop;
    isMcr = args['isMcr'] as bool? ?? true;

    canCountCtrl.text = stop.canCount > 0 ? '${stop.canCount}' : '';
    canSizeCtrl.text =
        stop.canSizeLtr > 0 ? _fmt(stop.canSizeLtr) : '40';
    milkQtyCtrl.text = stop.milkQtyLtr > 0 ? _fmt(stop.milkQtyLtr) : '';
    fatCtrl.text = stop.fatPercent > 0 ? _fmt(stop.fatPercent) : '';
    snfCtrl.text = stop.snfPercent > 0 ? _fmt(stop.snfPercent) : '';

    fcLtrCtrl.text = stop.fcLtr > 0 ? _fmt(stop.fcLtr) : '';
    fcFatCtrl.text = stop.fcFatPercent > 0 ? _fmt(stop.fcFatPercent) : '';
    fcSnfCtrl.text = stop.fcSnfPercent > 0 ? _fmt(stop.fcSnfPercent) : '';
    mcLtrCtrl.text = stop.mcLtr > 0 ? _fmt(stop.mcLtr) : '';
    mcFatCtrl.text = stop.mcFatPercent > 0 ? _fmt(stop.mcFatPercent) : '';
    mcSnfCtrl.text = stop.mcSnfPercent > 0 ? _fmt(stop.mcSnfPercent) : '';
    rcLtrCtrl.text = stop.rcLtr > 0 ? _fmt(stop.rcLtr) : '';
    rcFatCtrl.text = stop.rcFatPercent > 0 ? _fmt(stop.rcFatPercent) : '';
    rcSnfCtrl.text = stop.rcSnfPercent > 0 ? _fmt(stop.rcSnfPercent) : '';
    remarksCtrl.text = stop.remarks ?? '';

    if (isMcr && milkQtyCtrl.text.isEmpty) {
      recalcMilkQty();
    }
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(2);

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  int _i(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  void recalcMilkQty() {
    if (!isMcr) return;
    final cans = _i(canCountCtrl);
    final size = _d(canSizeCtrl);
    if (cans > 0 && size > 0) {
      milkQtyCtrl.text = _fmt(cans * size);
    }
  }

  String? validatePositiveNumber(String? v, String label, {bool allowZero = false}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (!allowZero && n <= 0) return '$label must be greater than 0';
    if (allowZero && n < 0) return '$label cannot be negative';
    return null;
  }

  String? validatePercent(String? v, String label) {
    final err = validatePositiveNumber(v, label);
    if (err != null) return err;
    final n = double.parse(v!.trim());
    if (n > 100) return '$label cannot exceed 100';
    return null;
  }

  String? validateCompartmentFat(String? v, TextEditingController litersCtrl) {
    if (_d(litersCtrl) <= 0) return null;
    return validatePercent(v, 'Fat %');
  }

  String? validateCompartmentSnf(String? v, TextEditingController litersCtrl) {
    if (_d(litersCtrl) <= 0) return null;
    return validatePercent(v, 'SNF %');
  }

  bool _validateCollect() {
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning(
        'Missing details',
        'Please fill all required fields marked with *',
      );
      return false;
    }

    if (isMcr) {
      final cans = _i(canCountCtrl);
      final size = _d(canSizeCtrl);
      if (cans <= 0 || size <= 0) {
        AppSnackbar.warning('Invalid cans', 'Can count and size must be greater than 0');
        return false;
      }
      return true;
    }

    final total = _d(fcLtrCtrl) + _d(mcLtrCtrl) + _d(rcLtrCtrl);
    if (total <= 0) {
      AppSnackbar.warning(
        'No milk entered',
        'Enter liters in at least one compartment (FC / MC / RC)',
      );
      return false;
    }
    return true;
  }

  Future<void> submitStop({bool skip = false}) async {
    if (stop.societyId == null) {
      AppSnackbar.error('Error', 'Stop society is missing');
      return;
    }

    if (!skip && !_validateCollect()) return;

    if (skip) {
      final confirmed = await Get.dialog<bool>(
            AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Skip this stop?',
                style: TextStyle(color: Color(0xFF1B3A4B)),
              ),
              content: const Text(
                'Skipped stops cannot be collected later on this trip. Continue?',
                style: TextStyle(color: Color(0xFF455A64)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                  ),
                  child: const Text('Skip stop'),
                ),
              ],
            ),
          ) ??
          false;
      if (!confirmed) return;
    }

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
        'stopStatus': skip
            ? CollectionStopStatus.skipped.value
            : CollectionStopStatus.collected.value,
      };

      if (!skip) {
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
          body['fcFatPercent'] = _d(fcFatCtrl);
          body['fcSnfPercent'] = _d(fcSnfCtrl);
          body['mcLtr'] = _d(mcLtrCtrl);
          body['mcFatPercent'] = _d(mcFatCtrl);
          body['mcSnfPercent'] = _d(mcSnfCtrl);
          body['rcLtr'] = _d(rcLtrCtrl);
          body['rcFatPercent'] = _d(rcFatCtrl);
          body['rcSnfPercent'] = _d(rcSnfCtrl);
          body['milkQtyLtr'] =
              _d(fcLtrCtrl) + _d(mcLtrCtrl) + _d(rcLtrCtrl);
        }
      }

      await apiService.markCollectionStop(tripId, stop.societyId!, body);
      Get.back(result: true);
      Future.microtask(() {
        AppSnackbar.success(
          skip ? 'Stop skipped' : 'Collected',
          skip
              ? '${stop.societyName ?? "Stop"} was skipped'
              : 'Milk recorded at ${stop.societyName ?? "stop"}',
        );
      });
    } catch (e) {
      AppSnackbar.error('Could not save', e.toString());
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
    fcFatCtrl.dispose();
    fcSnfCtrl.dispose();
    mcLtrCtrl.dispose();
    mcFatCtrl.dispose();
    mcSnfCtrl.dispose();
    rcLtrCtrl.dispose();
    rcFatCtrl.dispose();
    rcSnfCtrl.dispose();
    remarksCtrl.dispose();
    super.onClose();
  }
}
