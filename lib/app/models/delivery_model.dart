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
      name: json['productName']?.toString() ?? json['name']?.toString() ?? "Product",
      trays: ParseUtil.parseInt(json['tray']) ?? 0,
      packets: ParseUtil.parseInt(json['loosePackets']) ?? 0,
      collectedTrays: ParseUtil.parseInt(json['trayCollected']),
      leak: ParseUtil.parseInt(json['leak']) ?? 0,
      pktMinus: ParseUtil.parseInt(json['pktMinus']) ?? 0,
      pktPlus: ParseUtil.parseInt(json['pktPlus']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': name,
      'tray': trays,
      'loosePackets': packets,
      'trayCollected': collectedTrays,
      'leak': leak,
      'pktMinus': pktMinus,
      'pktPlus': pktPlus,
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
  final int remainingTrays;
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
    final bId = json['boothId'] ?? 0;
    final bIdStr = bId.toString();
    final bCode = json['boothCode']?.toString() ?? bIdStr;

    final bool isDeliveredAPI = (json['isDelivered'] == true || json['isDelivered'] == "true") ||
        (ParseUtil.parseInt(json['deliveryStatus']) == 4) ||
        (json['deliveryStatus']?.toString().toUpperCase() == 'DELIVERED');

    final bool isCollectedAPI = (json['isCollected'] == true || json['isCollected'] == "true") ||
        (json['collectionStatus']?.toString().toUpperCase() == 'COLLECTED');

    DeliveryStatus status = _parseStatus(json['collectionStatus'] ?? json['deliveryStatus'] ?? json['status']);
    if (isCollectedAPI) {
      status = DeliveryStatus.collected;
    } else if (isDeliveredAPI) {
      status = DeliveryStatus.delivered;
    }

    return DeliveryModel(
      boothId: ParseUtil.parseInt(bId) ?? 0,
      id: bIdStr,
      number: bCode,
      storeName: json['storeName'] ?? "Booth $bCode",
      address: json['address']?.toString() ?? "Address not available",
      status: status,
      products: (json['products'] as List?)
              ?.map((e) => DeliveryProductModel.fromJson(e))
              .toList() ??
          [],
      collectedTrays: ParseUtil.parseInt(json['trayCollected']) ?? 0,
      remainingTrays: ParseUtil.parseInt(json['remainingTrays']) ?? 0,
      apiIsDelivered: isDeliveredAPI,
      apiIsCollected: isCollectedAPI,
      agentName: json['agentName']?.toString(),
      agentPhone: json['agentPhone']?.toString() ?? json['agentMobileNumber']?.toString(),
      totalTrays: ParseUtil.parseInt(json['trayCount']) ?? 0,
      totalPackets: ParseUtil.parseInt(json['loosePackets']) ?? 0,
    );
  }

  static DeliveryStatus _parseStatus(dynamic status) {
    if (status == null) return DeliveryStatus.toBeDelivered;
    final s = status.toString().toUpperCase();
    if (s == 'DELIVERED' || s == '4') {
      return DeliveryStatus.delivered;
    }
    if (s == 'COLLECTED' || s == 'NOT_COLLECTED' || s == 'NOT COLLECTED' || s == 'PARTIALLY_COLLECTED') {
      return DeliveryStatus.collected;
    }
    if (s == 'DELIVERING' || s == 'IN_PROGRESS' || s == 'COLLECTING' || s == '2') {
      return s.contains('COLLECT') ? DeliveryStatus.collecting : DeliveryStatus.delivering;
    }
    return DeliveryStatus.toBeDelivered;
  }

  Map<String, dynamic> toJson() {
    return {
      'boothId': boothId,
      'boothCode': number,
      'storeName': storeName,
      'address': address,
      'status': status.name,
      'products': products.map((e) => e.toJson()).toList(),
      'trayCollected': collectedTrays,
      'remainingTrays': remainingTrays,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'trayCount': totalTrays,
      'loosePackets': totalPackets,
    };
  }
}
