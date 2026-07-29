import '../constants/app_enums.dart';
import '../utils/parse-util.dart';

class CollectionTrip {
  final int? id;
  final int? unionId;
  final int? routeId;
  final String? routeName;
  final int? contractId;
  final FleetType fleetType;
  final int? shift;
  final String? tripDate;
  final int? destinationId;
  final String? destinationName;
  final int? destinationType;
  final CollectionFleetTripStatus status;
  final String? operatorName;
  final String? vehicleRegistrationNumber;
  final String? startTime;
  final String? endTime;
  final List<CollectionStop> stops;
  final List<CollectionSubmit> submits;

  CollectionTrip({
    this.id,
    this.unionId,
    this.routeId,
    this.routeName,
    this.contractId,
    this.fleetType = FleetType.mcr,
    this.shift,
    this.tripDate,
    this.destinationId,
    this.destinationName,
    this.destinationType,
    this.status = CollectionFleetTripStatus.none,
    this.operatorName,
    this.vehicleRegistrationNumber,
    this.startTime,
    this.endTime,
    this.stops = const [],
    this.submits = const [],
  });

  bool get isMcr => fleetType == FleetType.mcr;
  bool get isMtr => fleetType == FleetType.mtr;

  int get stopCount => stops.length;
  int get collectedCount => stops
      .where((s) =>
          s.stopStatus == CollectionStopStatus.collected ||
          s.stopStatus == CollectionStopStatus.skipped)
      .length;

  bool get allStopsDone =>
      stops.isNotEmpty && collectedCount == stops.length;

  bool get isSubmitted =>
      status == CollectionFleetTripStatus.submitted ||
      status == CollectionFleetTripStatus.completed ||
      (submits.isNotEmpty &&
          submits.every((s) => s.submitStatus == CollectionSubmitStatus.submitted));

  factory CollectionTrip.fromJson(Map<String, dynamic> json) {
    final stopsJson = json['stops'] as List? ?? [];
    final submitsJson = json['submits'] as List? ?? [];
    return CollectionTrip(
      id: ParseUtil.parseInt(json['id']),
      unionId: ParseUtil.parseInt(json['unionId'] ?? json['union_id']),
      routeId: ParseUtil.parseInt(json['routeId'] ?? json['route_id']),
      routeName: json['routeName']?.toString() ?? json['route_name']?.toString(),
      contractId: ParseUtil.parseInt(json['contractId'] ?? json['contract_id']),
      fleetType: FleetType.fromValue(
        ParseUtil.parseInt(json['fleetType'] ?? json['fleet_type']),
      ),
      shift: ParseUtil.parseInt(json['shift']),
      tripDate: json['tripDate']?.toString() ?? json['trip_date']?.toString(),
      destinationId:
          ParseUtil.parseInt(json['destinationId'] ?? json['destination_id']),
      destinationName: json['destinationName']?.toString(),
      destinationType: ParseUtil.parseInt(
          json['destinationType'] ?? json['destination_type']),
      status: CollectionFleetTripStatus.fromValue(
        ParseUtil.parseInt(json['status']),
      ),
      operatorName: json['operatorName']?.toString(),
      vehicleRegistrationNumber:
          json['vehicleRegistrationNumber']?.toString(),
      startTime: json['startTime']?.toString() ?? json['start_time']?.toString(),
      endTime: json['endTime']?.toString() ?? json['end_time']?.toString(),
      stops: stopsJson
          .map((e) => CollectionStop.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      submits: submitsJson
          .map((e) => CollectionSubmit.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class CollectionStop {
  final int? id;
  final int? societyId;
  final String? societyName;
  final bool isBmc;
  final int? stopSequence;
  final CollectionStopStatus stopStatus;
  final int canCount;
  final double canSizeLtr;
  final double milkQtyLtr;
  final double fatPercent;
  final double snfPercent;
  final double fcLtr;
  final double fcFatPercent;
  final double fcSnfPercent;
  final double mcLtr;
  final double mcFatPercent;
  final double mcSnfPercent;
  final double rcLtr;
  final double rcFatPercent;
  final double rcSnfPercent;
  final double? lat;
  final double? lng;
  final String? collectedAt;
  final String? remarks;

  CollectionStop({
    this.id,
    this.societyId,
    this.societyName,
    this.isBmc = false,
    this.stopSequence,
    this.stopStatus = CollectionStopStatus.pending,
    this.canCount = 0,
    this.canSizeLtr = 40,
    this.milkQtyLtr = 0,
    this.fatPercent = 0,
    this.snfPercent = 0,
    this.fcLtr = 0,
    this.fcFatPercent = 0,
    this.fcSnfPercent = 0,
    this.mcLtr = 0,
    this.mcFatPercent = 0,
    this.mcSnfPercent = 0,
    this.rcLtr = 0,
    this.rcFatPercent = 0,
    this.rcSnfPercent = 0,
    this.lat,
    this.lng,
    this.collectedAt,
    this.remarks,
  });

  bool get isDone =>
      stopStatus == CollectionStopStatus.collected ||
      stopStatus == CollectionStopStatus.skipped;

  factory CollectionStop.fromJson(Map<String, dynamic> json) {
    return CollectionStop(
      id: ParseUtil.parseInt(json['id']),
      societyId: ParseUtil.parseInt(json['societyId'] ?? json['society_id']),
      societyName: json['societyName']?.toString(),
      isBmc: ParseUtil.parseBool(json['isBmc'] ?? json['is_bmc']),
      stopSequence:
          ParseUtil.parseInt(json['stopSequence'] ?? json['stop_sequence']),
      stopStatus: CollectionStopStatus.fromValue(
        ParseUtil.parseInt(json['stopStatus'] ?? json['stop_status']),
      ),
      canCount: ParseUtil.parseInt(json['canCount'] ?? json['can_count']) ?? 0,
      canSizeLtr: ParseUtil.parseDouble(
              json['canSizeLtr'] ?? json['can_size_ltr']) ??
          40,
      milkQtyLtr: ParseUtil.parseDouble(
              json['milkQtyLtr'] ?? json['milk_qty_ltr']) ??
          0,
      fatPercent:
          ParseUtil.parseDouble(json['fatPercent'] ?? json['fat_percent']) ?? 0,
      snfPercent:
          ParseUtil.parseDouble(json['snfPercent'] ?? json['snf_percent']) ?? 0,
      fcLtr: ParseUtil.parseDouble(json['fcLtr'] ?? json['fc_ltr']) ?? 0,
      fcFatPercent: ParseUtil.parseDouble(
              json['fcFatPercent'] ?? json['fc_fat_percent']) ??
          0,
      fcSnfPercent: ParseUtil.parseDouble(
              json['fcSnfPercent'] ?? json['fc_snf_percent']) ??
          0,
      mcLtr: ParseUtil.parseDouble(json['mcLtr'] ?? json['mc_ltr']) ?? 0,
      mcFatPercent: ParseUtil.parseDouble(
              json['mcFatPercent'] ?? json['mc_fat_percent']) ??
          0,
      mcSnfPercent: ParseUtil.parseDouble(
              json['mcSnfPercent'] ?? json['mc_snf_percent']) ??
          0,
      rcLtr: ParseUtil.parseDouble(json['rcLtr'] ?? json['rc_ltr']) ?? 0,
      rcFatPercent: ParseUtil.parseDouble(
              json['rcFatPercent'] ?? json['rc_fat_percent']) ??
          0,
      rcSnfPercent: ParseUtil.parseDouble(
              json['rcSnfPercent'] ?? json['rc_snf_percent']) ??
          0,
      lat: ParseUtil.parseDouble(json['lat'] ?? json['collectedLat']),
      lng: ParseUtil.parseDouble(json['lng'] ?? json['collectedLng']),
      collectedAt:
          json['collectedAt']?.toString() ?? json['collected_at']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }
}

class CollectionSubmit {
  final int? id;
  final int? destinationId;
  final String? destinationName;
  final int? destinationType;
  final CollectionSubmitStatus submitStatus;
  final int canCount;
  final double canSizeLtr;
  final double milkQtyLtr;
  final double fatPercent;
  final double snfPercent;
  final double fcLtr;
  final double mcLtr;
  final double rcLtr;
  final String? submittedAt;

  CollectionSubmit({
    this.id,
    this.destinationId,
    this.destinationName,
    this.destinationType,
    this.submitStatus = CollectionSubmitStatus.pending,
    this.canCount = 0,
    this.canSizeLtr = 40,
    this.milkQtyLtr = 0,
    this.fatPercent = 0,
    this.snfPercent = 0,
    this.fcLtr = 0,
    this.mcLtr = 0,
    this.rcLtr = 0,
    this.submittedAt,
  });

  factory CollectionSubmit.fromJson(Map<String, dynamic> json) {
    return CollectionSubmit(
      id: ParseUtil.parseInt(json['id']),
      destinationId:
          ParseUtil.parseInt(json['destinationId'] ?? json['destination_id']),
      destinationName: json['destinationName']?.toString(),
      destinationType: ParseUtil.parseInt(
          json['destinationType'] ?? json['destination_type']),
      submitStatus: CollectionSubmitStatus.fromValue(
        ParseUtil.parseInt(json['submitStatus'] ?? json['submit_status']),
      ),
      canCount: ParseUtil.parseInt(json['canCount'] ?? json['can_count']) ?? 0,
      canSizeLtr: ParseUtil.parseDouble(
              json['canSizeLtr'] ?? json['can_size_ltr']) ??
          40,
      milkQtyLtr: ParseUtil.parseDouble(
              json['milkQtyLtr'] ?? json['milk_qty_ltr']) ??
          0,
      fatPercent:
          ParseUtil.parseDouble(json['fatPercent'] ?? json['fat_percent']) ?? 0,
      snfPercent:
          ParseUtil.parseDouble(json['snfPercent'] ?? json['snf_percent']) ?? 0,
      fcLtr: ParseUtil.parseDouble(json['fcLtr'] ?? json['fc_ltr']) ?? 0,
      mcLtr: ParseUtil.parseDouble(json['mcLtr'] ?? json['mc_ltr']) ?? 0,
      rcLtr: ParseUtil.parseDouble(json['rcLtr'] ?? json['rc_ltr']) ?? 0,
      submittedAt:
          json['submittedAt']?.toString() ?? json['submitted_at']?.toString(),
    );
  }
}
