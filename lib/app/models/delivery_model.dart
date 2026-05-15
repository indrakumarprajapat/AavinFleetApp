import '../utils/parse-util.dart';

enum DeliveryStatus {
  toBeDelivered,
  delivering,
  delivered,

  toBeCollected,
  collecting,
  collected,
}

class DeliveryProductModel {
  final String name;
  final int trays;
  final int packets;
  final int? collectedTrays;

  const DeliveryProductModel({
    required this.name,
    required this.trays,
    required this.packets,
    this.collectedTrays,
  });

  // JSON
  factory DeliveryProductModel.fromJson(Map<String, dynamic> json) {
    return DeliveryProductModel(
      name: json['productName']?.toString() ??
          json['name']?.toString() ??
          json['product_name']?.toString() ??
          "Product",
      trays: ParseUtil.parseInt(json['tray'] ?? json['trays'] ?? json['qty'] ?? json['dispatch_trays']) ?? 0,
      packets: ParseUtil.parseInt(json['loosePackets'] ?? json['packets'] ?? json['packet_qty'] ?? json['dispatch_packets']) ?? 0,
      collectedTrays: ParseUtil.parseInt(json['collected_trays'] ?? json['collectedTrays']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'trays': trays,
      'packets': packets,
      'collected_trays': collectedTrays,
    };
  }

  DeliveryProductModel copyWith({
    String? name,
    int? trays,
    int? packets,
    int? collectedTrays,
  }) {
    return DeliveryProductModel(
      name: name ?? this.name,
      trays: trays ?? this.trays,
      packets: packets ?? this.packets,
      collectedTrays: collectedTrays ?? this.collectedTrays,
    );
  }
}

class DeliveryModel {
  final int boothId;
  final String id;
  final String number;
  final String storeName;
  final String address;
  final String? agentName;
  final String? agentPhone;
  final DeliveryStatus status;
  final List<DeliveryProductModel> products;
  final int collectedTrays;
  final int remainingTrays; // Historical residue from previous trips
  final bool apiIsDelivered;
  final bool apiIsCollected;

  // Calculations
  int get totalTrays {
    if (products.isNotEmpty) {
      final productSum = products.fold<int>(0, (sum, item) => sum + item.trays);
      if (productSum > 0) return productSum;
    }
    return _totalTrays > 0 ? _totalTrays : 0;
  }

  int get totalPackets {
    if (products.isNotEmpty) {
      final productSum = products.fold<int>(0, (sum, item) => sum + item.packets);
      if (productSum > 0) return productSum;
    }
    return _totalPackets > 0 ? _totalPackets : 0;
  }

  final int _totalTrays;
  final int _totalPackets;

  const DeliveryModel({
    required this.boothId,
    required this.id,
    required this.number,
    required this.storeName,
    required this.address,
    this.agentName,
    this.agentPhone,
    required this.status,
    required this.products,
    this.collectedTrays = 0,
    this.remainingTrays = 0,
    this.apiIsDelivered = false,
    this.apiIsCollected = false,
    int totalTrays = 0,
    int totalPackets = 0,
  })  : _totalTrays = totalTrays,
        _totalPackets = totalPackets;

  // CopyWith update
  DeliveryModel copyWith({
    int? boothId,
    String? id,
    String? number,
    String? storeName,
    String? address,
    String? agentName,
    String? agentPhone,
    DeliveryStatus? status,
    List<DeliveryProductModel>? products,
    int? collectedTrays,
    int? remainingTrays,
    bool? apiIsDelivered,
    bool? apiIsCollected,
    int? totalTrays,
    int? totalPackets,
  }) {
    return DeliveryModel(
      boothId: boothId ?? this.boothId,
      id: id ?? this.id,
      number: number ?? this.number,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      status: status ?? this.status,
      products: products ?? this.products,
      collectedTrays: collectedTrays ?? this.collectedTrays,
      remainingTrays: remainingTrays ?? this.remainingTrays,
      apiIsDelivered: apiIsDelivered ?? this.apiIsDelivered,
      apiIsCollected: apiIsCollected ?? this.apiIsCollected,
      totalTrays: totalTrays ?? _totalTrays,
      totalPackets: totalPackets ?? _totalPackets,
    );
  }

  // Renamed from remainingTrays to avoid conflict with the field
  int get pendingTrays => totalTrays - collectedTrays;

  // Status helpers
  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isPending => status == DeliveryStatus.toBeDelivered;

  bool get isFullyCollected => collectedTrays >= totalTrays;

  // JSON
  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    final bId = json['boothId'] ?? json['id'] ?? 0;
    final bIdStr = bId.toString();
    final bCode =
        json['number']?.toString() ?? json['boothCode']?.toString() ?? bIdStr;

    final bool isDeliveredAPI = json['isDelivered'] == true ||
        json['is_delivered'] == true ||
        json['delivered'] == true ||
        json['delivery_time'] != null ||
        json['delivered_at'] != null;

    final bool isCollectedAPI = json['isCollected'] == true ||
        json['is_collected'] == true ||
        json['is_completed'] == true ||
        json['completed'] == true;

    final bool isCompleted = isDeliveredAPI || isCollectedAPI;

    DeliveryStatus status = _parseStatus(json['status'] ??
        json['deliveryStatus'] ??
        json['delivery_status'] ??
        json['boothStatus'] ??
        json['tripStatus']);

    // If any "completed" flag is true, force the status to delivered
    if (isCompleted) {
      status = DeliveryStatus.delivered;
    }

    // Fallback: If we have collected trays or a delivery record exists, it's delivered
    final collected = ParseUtil.parseInt(json['collectedTrays'] ??
            json['collected_trays'] ??
            json['collected_tray'] ??
            json['collectedTray']) ??
        0;

    if (collected > 0 && status == DeliveryStatus.toBeCollected) {
      status = DeliveryStatus.delivered;
    }

    return DeliveryModel(
      boothId: ParseUtil.parseInt(bId) ?? 0,
      id: bIdStr,
      number: bCode,
      storeName: json['storeName']?.toString() ??
          json['name']?.toString() ??
          json['boothName']?.toString() ??
          json['booth_name']?.toString() ??
          "Booth $bCode",
      address: json['address']?.toString() ?? "Address not available",
      agentName: json['agentName']?.toString() ?? json['agent_name']?.toString(),
      agentPhone: json['agentPhone']?.toString() ?? json['agent_phone']?.toString() ?? json['agentMobile']?.toString() ?? json['agent_mobile']?.toString(),
      status: status,
      products: (json['products'] as List? ??
              json['items'] as List? ??
              json['delivery_details'] as List? ??
              json['booth_products'] as List? ??
              json['delivery_note_details'] as List? ??
              json['products_list'] as List?)
              ?.map((e) => DeliveryProductModel.fromJson(e))
              .toList() ??
          [],
      collectedTrays: collected,
      remainingTrays: ParseUtil.parseInt(json['remainingTrays'] ??
              json['remaining_trays'] ??
              json['outstandingTrays']) ??
          0,
      apiIsDelivered: isDeliveredAPI,
      apiIsCollected: isCollectedAPI,
      totalTrays: ParseUtil.parseInt(json['totalTrays'] ??
              json['total_trays'] ??
              json['trayCount'] ??
              json['tray_count'] ??
              json['totalTray'] ??
              json['total_tray'] ??
              json['tray'] ??
              json['trays'] ??
              json['dispatch_trays'] ??
              json['total_dispatch_trays'] ??
              json['total_qty'] ??
              json['total_quantity'] ??
              json['qty'] ??
              json['indent_trays'] ??
              json['total_tray_count'] ??
              json['total_dispatch_tray']) ??
          0,
      totalPackets: ParseUtil.parseInt(json['totalPackets'] ??
              json['total_packets'] ??
              json['packetCount'] ??
              json['packet_count'] ??
              json['total_packet_count'] ??
              json['loosePackets'] ??
              json['packets'] ??
              json['total_packet'] ??
              json['indent_packets'] ??
              json['total_packets_count'] ??
              json['total_dispatch_packet']) ??
          0,
    );
  }

  static DeliveryStatus _parseStatus(dynamic status) {
    if (status == null) return DeliveryStatus.toBeDelivered;
    final s = status.toString().toUpperCase();
    if (s == 'DELIVERED' ||
        s == 'COMPLETED' ||
        s == 'SUCCESS' ||
        s == 'COLLECTED' ||
        s == 'TRUE' ||
        s == '1' ||
        s == 'FINISH') {
      return DeliveryStatus.delivered;
    }
    if (s == 'DELIVERING' ||
        s == 'IN_PROGRESS' ||
        s == 'START' ||
        s == 'RUNNING' ||
        s == '2' ||
        s == 'PROCESS') {
      return DeliveryStatus.delivering;
    }
    return DeliveryStatus.toBeDelivered;
  }

  Map<String, dynamic> toJson() {
    return {
      'boothId': boothId,
      'id': id,
      'number': number,
      'storeName': storeName,
      'address': address,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'status': status.name,
      'products': products.map((e) => e.toJson()).toList(),
      'collectedTrays': collectedTrays,
      'remainingTrays': remainingTrays,
      'totalTray': _totalTrays,
      'totalPackets': _totalPackets,
    };
  }
}
