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
  final int leak;
  final int pktMinus;
  final int pktPlus;

  const DeliveryProductModel({
    required this.name,
    required this.trays,
    required this.packets,
    this.collectedTrays,
    this.leak = 0,
    this.pktMinus = 0,
    this.pktPlus = 0,
  });

  // JSON
  factory DeliveryProductModel.fromJson(Map<String, dynamic> json) {
    return DeliveryProductModel(
      name: json['productName']?.toString() ??
          json['name']?.toString() ??
          "Product",
      trays: ParseUtil.parseInt(json['tray'] ?? json['trays']) ?? 0,
      packets: ParseUtil.parseInt(json['loosePackets'] ?? json['packets']) ?? 0,
      collectedTrays: ParseUtil.parseInt(json['collected_trays'] ?? json['collectedTrays']),
      leak: ParseUtil.parseInt(json['leak']) ?? 0,
      pktMinus: ParseUtil.parseInt(json['pkt_minus']) ?? 0,
      pktPlus: ParseUtil.parseInt(json['pkt_plus']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'trays': trays,
      'packets': packets,
      'collected_trays': collectedTrays,
      'leak': leak,
      'pkt_minus': pktMinus,
      'pkt_plus': pktPlus,
    };
  }

  DeliveryProductModel copyWith({
    String? name,
    int? trays,
    int? packets,
    int? collectedTrays,
    int? leak,
    int? pktMinus,
    int? pktPlus,
  }) {
    return DeliveryProductModel(
      name: name ?? this.name,
      trays: trays ?? this.trays,
      packets: packets ?? this.packets,
      collectedTrays: collectedTrays ?? this.collectedTrays,
      leak: leak ?? this.leak,
      pktMinus: pktMinus ?? this.pktMinus,
      pktPlus: pktPlus ?? this.pktPlus,
    );
  }
}

class DeliveryModel {
  final int boothId;
  final String id;
  final String number;
  final String storeName;
  final String address;
  final DeliveryStatus status;
  final List<DeliveryProductModel> products;
  final int collectedTrays;
  final int remainingTrays; // Historical residue from previous trips
  final bool apiIsDelivered;
  final bool apiIsCollected;
  final String? agentName;
  final String? agentPhone;

  // Calculations
  int get totalTrays => products.isNotEmpty
      ? products.fold<int>(0, (sum, item) => sum + item.trays)
      : (_totalTrays > 0 ? _totalTrays : 0);

  int get totalPackets => products.isNotEmpty
      ? products.fold<int>(0, (sum, item) => sum + item.packets)
      : (_totalPackets > 0 ? _totalPackets : 0);

  final int _totalTrays;
  final int _totalPackets;

  const DeliveryModel({
    required this.boothId,
    required this.id,
    required this.number,
    required this.storeName,
    required this.address,
    required this.status,
    required this.products,
    this.collectedTrays = 0,
    this.remainingTrays = 0,
    this.apiIsDelivered = false,
    this.apiIsCollected = false,
    this.agentName,
    this.agentPhone,
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
    DeliveryStatus? status,
    List<DeliveryProductModel>? products,
    int? collectedTrays,
    int? remainingTrays,
    bool? apiIsDelivered,
    bool? apiIsCollected,
    String? agentName,
    String? agentPhone,
    int? totalTrays,
    int? totalPackets,
  }) {
    return DeliveryModel(
      boothId: boothId ?? this.boothId,
      id: id ?? this.id,
      number: number ?? this.number,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      status: status ?? this.status,
      products: products ?? this.products,
      collectedTrays: collectedTrays ?? this.collectedTrays,
      remainingTrays: remainingTrays ?? this.remainingTrays,
      apiIsDelivered: apiIsDelivered ?? this.apiIsDelivered,
      apiIsCollected: apiIsCollected ?? this.apiIsCollected,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
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
    final bId = json['booth_id'] ?? json['boothId'] ?? json['id'] ?? 0;
    final bIdStr = bId.toString();
    final bCode =
        json['number']?.toString() ?? json['boothCode']?.toString() ?? bIdStr;

    final bool isDeliveredAPI = ParseUtil.parseBool(json['isDelivered'] ?? json['is_delivered'] ?? json['delivered']) ||
        (json['delivery_time'] != null && 
         json['delivery_time'].toString().isNotEmpty && 
         json['delivery_time'].toString() != "null" && 
         json['delivery_time'].toString() != "0" && 
         json['delivery_time'].toString() != "00:00:00" &&
         json['delivery_time'].toString() != "00:00:00.000000") ||
        (json['delivered_at'] != null && 
         json['delivered_at'].toString().isNotEmpty && 
         json['delivered_at'].toString() != "null") ||
        (ParseUtil.parseInt(json['deliveryStatus'] ?? json['delivery_status'] ?? json['status']) == 4);

    final bool isCollectedAPI = ParseUtil.parseBool(json['isCollected'] ?? json['is_collected'] ?? json['is_completed'] ?? json['completed']) ||
        (json['collected_at'] != null && json['collected_at'].toString().isNotEmpty && json['collected_at'].toString() != "null");

    final bool isCompleted = isDeliveredAPI || isCollectedAPI;

    DeliveryStatus status = _parseStatus(json['status'] ??
        json['deliveryStatus'] ??
        json['delivery_status'] ??
        json['boothStatus']);

    // If any "completed" flag is true, force the status to delivered
    if (isCompleted) {
      status = DeliveryStatus.delivered;
    }

    // Fallback: Trust API flags first
    final collected = ParseUtil.parseInt(json['collectedTrays'] ??
        json['collected_trays'] ??
        json['collected_tray'] ??
        json['collectedTray']) ?? 0;

    return DeliveryModel(
      boothId: ParseUtil.parseInt(bId) ?? 0,
      id: bIdStr,
      number: bCode,
      storeName: "Booth $bCode",
      address: json['address']?.toString() ?? "Address not available",
      status: status,
      products: (json['products'] as List?)
              ?.map((e) => DeliveryProductModel.fromJson(e))
              .toList() ??
          [],
      collectedTrays: collected,
      remainingTrays: ParseUtil.parseInt(json['remainingTrays'] ??
          json['remaining_trays'] ??
          json['outstandingTrays']) ?? 0,
      apiIsDelivered: isDeliveredAPI,
      apiIsCollected: isCollectedAPI,
      agentName: json['agentName']?.toString() ?? json['agent_name']?.toString(),
      agentPhone: json['agentPhone']?.toString() ?? json['agent_phone']?.toString() ?? json['mobile']?.toString() ?? json['agentMobileNumber']?.toString(),
      totalTrays: ParseUtil.parseInt(json['totalTrays'] ??
          json['total_trays'] ??
          json['totalTray'] ??
          json['total_tray'] ??
          json['tray'] ??
          json['trays'] ??
          json['trayCount']) ?? 0,
      totalPackets: ParseUtil.parseInt(json['totalPackets'] ??
          json['total_packets'] ??
          json['loosePackets'] ??
          json['packets'] ??
          json['qtyPkt']) ?? 0,
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
        s == '4' ||
        s == 'FINISH') {
      return DeliveryStatus.delivered;
    }
    if (s == 'DELIVERING' ||
        s == 'IN_PROGRESS' ||
        s == 'START' ||
        s == 'RUNNING' ||
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
      'status': status.name,
      'products': products.map((e) => e.toJson()).toList(),
      'collectedTrays': collectedTrays,
      'remainingTrays': remainingTrays,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'totalTray': _totalTrays,
      'totalPackets': _totalPackets,
    };
  }
}
