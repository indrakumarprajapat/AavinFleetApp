import '../utils/parse-util.dart';

class RouteDetail {
  final int? id;
  final int? routeId;
  final int? shift;
  final DateTime? reportDate;
  final String? mainRouteUrl;
  final String? tempRouteUrl;
  final int? serialNo;
  final int? reviseNumber;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? success;

  final int? gatepassId;
  final List<dynamic>? products;

  RouteDetail({
    this.id,
    this.routeId,
    this.gatepassId,
    this.shift,
    this.reportDate,
    this.mainRouteUrl,
    this.tempRouteUrl,
    this.serialNo,
    this.reviseNumber,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.success,
    this.products,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    return RouteDetail(
      id: ParseUtil.parseInt(json['id']),

      routeId: ParseUtil.parseInt(
        json['route_id'] ?? json['routeId'],
      ),

      gatepassId: ParseUtil.parseInt(
        json['gatepass_id'] ?? json['gatepassId'],
      ),

      shift: ParseUtil.parseInt(json['shift']),

      reportDate: ParseUtil.parseDateTime(
        json['report_date'] ?? json['reportDate'],
      ),

      mainRouteUrl: json['main_route_url']?.toString() ??
          json['mainRouteUrl']?.toString(),

      tempRouteUrl: json['temp_route_url']?.toString() ??
          json['tempRouteUrl']?.toString(),

      serialNo: ParseUtil.parseInt(
        json['serial_no'] ?? json['serialNo'],
      ),

      reviseNumber: ParseUtil.parseInt(
        json['revise_number'] ?? json['reviseNumber'],
      ),

      createdBy: ParseUtil.parseInt(
        json['created_by'] ?? json['createdBy'],
      ),

      createdAt: ParseUtil.parseDateTime(
        json['created_at'] ?? json['createdAt'],
      ),

      updatedAt: ParseUtil.parseDateTime(
        json['updated_at'] ?? json['updatedAt'],
      ),

      success: ParseUtil.parseBool(json['success']),
      products: json['products'] as List?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'shift': shift,
      'reportDate': reportDate?.toIso8601String(),
      'mainRouteUrl': mainRouteUrl,
      'tempRouteUrl': tempRouteUrl,
      'serialNo': serialNo,
      'reviseNumber': reviseNumber,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'success': success,
    };
  }
}