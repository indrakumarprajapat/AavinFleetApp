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
          "Product",
      trays: (json['tray'] as num?)?.toInt() ??
          (json['trays'] as num?)?.toInt() ??
          0,
      packets: (json['loosePackets'] as num?)?.toInt() ??
          (json['packets'] as num?)?.toInt() ??
          0,
      collectedTrays: (json['collected_trays'] as num?)?.toInt() ??
          (json['collectedTrays'] as num?)?.toInt(),
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
  final DeliveryStatus status;
  final List<DeliveryProductModel> products;
  final int collectedTrays;
  final int remainingTrays; // Historical residue from previous trips
  final bool apiIsDelivered;
  final bool apiIsCollected;

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
    final collected = (json['collectedTrays'] as num?)?.toInt() ??
        (json['collected_trays'] as num?)?.toInt() ??
        0;

    if (collected > 0 && status == DeliveryStatus.toBeCollected) {
      status = DeliveryStatus.delivered;
    }

    return DeliveryModel(
      boothId: bId is int ? bId : int.tryParse(bId.toString()) ?? 0,
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
      remainingTrays: (json['remainingTrays'] as num?)?.toInt() ??
          (json['outstandingTrays'] as num?)?.toInt() ??
          0,
      apiIsDelivered: isDeliveredAPI,
      apiIsCollected: isCollectedAPI,
      totalTrays: (json['totalTray'] as num?)?.toInt() ??
          (json['tray'] as num?)?.toInt() ??
          0,
      totalPackets: (json['totalPackets'] as num?)?.toInt() ??
          (json['loosePackets'] as num?)?.toInt() ??
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
      'status': status.name,
      'products': products.map((e) => e.toJson()).toList(),
      'collectedTrays': collectedTrays,
      'remainingTrays': remainingTrays,
      'totalTray': _totalTrays,
      'totalPackets': _totalPackets,
    };
  }
}
