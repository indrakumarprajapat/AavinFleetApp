import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/collection_trip.dart';
import '../../../utils/app_snackbar.dart';
import '../controllers/collection_route_controller.dart';

class CollectionRouteView extends GetView<CollectionRouteController> {
  const CollectionRouteView({super.key});

  static const _teal1 = Color(0xFF007EA7);
  static const _tealDeep = Color(0xFF005F80);
  static const _bg = Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          AppSnackbar.info(
            'Trip in progress',
            'Complete all stops, submit milk, then end the trip to exit.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _tealDeep,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Obx(() {
            final t = controller.trip.value;
            return Text(
              t == null
                  ? 'Collection Trip'
                  : (t.isMtr ? 'MTR Collection' : 'MCR Collection'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: controller.loadTrip,
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.trip.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: _teal1),
            );
          }
          final stops = controller.stops;
          if (stops.isEmpty) {
            return const Center(
              child: Text(
                'No stops on this trip',
                style: TextStyle(color: Color(0xFF546E7A), fontSize: 15),
              ),
            );
          }
          return RefreshIndicator(
            color: _teal1,
            onRefresh: controller.loadTrip,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _progressCard(),
                const SizedBox(height: 14),
                Text(
                  controller.isMcr ? 'Society stops' : 'BMC stops',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(stops.length, (i) {
                  final stop = stops[i];
                  final isCurrent = stop == controller.currentStop;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => controller.openStop(stop),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCurrent
                                  ? _teal1
                                  : stop.isDone
                                      ? const Color(0xFFA5D6A7)
                                      : const Color(0xFFE3E8EF),
                              width: isCurrent || stop.isDone ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: controller.statusColor(stop),
                                child: Text(
                                  '${stop.stopSequence ?? i + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.societyName ??
                                          'Stop ${stop.societyId}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF263238),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _stopSubtitle(stop),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF607D8B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: controller
                                      .statusColor(stop)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  controller.statusLabel(stop),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: controller.statusColor(stop),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        bottomNavigationBar: Obx(() {
          final allDone = controller.allStopsDone;
          final submitted = controller.isSubmitted;
          final pending = controller.stops.length - controller.doneCount;

          String label;
          String helper;
          VoidCallback? onPressed;
          if (!allDone) {
            label = pending == 1
                ? '1 STOP REMAINING'
                : '$pending STOPS REMAINING';
            helper = 'Tap a pending stop to collect milk';
            onPressed = null;
          } else if (!submitted) {
            label = controller.isMcr ? 'SUBMIT AT BMC' : 'SUBMIT AT DAIRY';
            helper = 'All stops done — submit milk to continue';
            onPressed = controller.openSubmit;
          } else {
            label = 'END TRIP';
            helper = 'Milk submitted — end trip to finish';
            onPressed = controller.endTrip;
          }

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE3E8EF))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    helper,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF607D8B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            onPressed == null ? const Color(0xFFB0BEC5) : _teal1,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          controller.isLoading.value ? null : onPressed,
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _progressCard() {
    return Obx(() {
      final total = controller.stops.length;
      final done = controller.doneCount;
      final progress = total == 0 ? 0.0 : done / total;
      final submitted = controller.isSubmitted;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E8EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    controller.trip.value?.routeName ?? 'Route',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1B3A4B),
                    ),
                  ),
                ),
                Text(
                  '$done / $total',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _teal1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFECEFF1),
                color: submitted
                    ? const Color(0xFF2E7D32)
                    : _teal1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              submitted
                  ? 'Submitted — ready to end trip'
                  : done == total && total > 0
                      ? (controller.isMcr
                          ? 'All collected — submit at BMC next'
                          : 'All filled — submit at Dairy next')
                      : 'Collect milk at each stop, then submit',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF607D8B),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _stopSubtitle(CollectionStop stop) {
    if (controller.isMcr) {
      if (stop.isDone) {
        return '${stop.canCount} cans · ${stop.milkQtyLtr} L · Fat ${stop.fatPercent}%';
      }
      return 'Tap to collect milk cans';
    }
    if (stop.isDone) {
      return 'FC ${stop.fcLtr} · MC ${stop.mcLtr} · RC ${stop.rcLtr} L';
    }
    return 'Tap to fill tanker compartments';
  }
}
