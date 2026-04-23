enum DeliveryStatus {
  delivered,
  delivering,
  pending,
}

class ProductModel {
  final String name;
  final int trays;
  final int packets;
  final int tubs;

  const ProductModel({
    required this.name,
    required this.trays,
    required this.packets,
    required this.tubs,
  });

  //JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['name']?.toString() ?? "Product",
      trays: json['trays'] ?? 0,
      packets: json['packets'] ?? 0,
      tubs: json['tubs'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'trays': trays,
      'packets': packets,
      'tubs': tubs,
    };
  }
}

class DeliveryModel {
  final String id;
  final String number;
  final String storeName;
  final String address;
  final DeliveryStatus status;
  final List<ProductModel> products;
  final int collectedTrays;
  final int remainingTrays; // Historical residue from previous trips

  const DeliveryModel({
    required this.id,
    required this.number,
    required this.storeName,
    required this.address,
    required this.status,
    required this.products,
    this.collectedTrays = 0,
    this.remainingTrays = 0,
  });

  //CopyWith
  DeliveryModel copyWith({
    String? id,
    String? number,
    String? storeName,
    String? address,
    DeliveryStatus? status,
    List<ProductModel>? products,
    int? collectedTrays,
    int? remainingTrays,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      number: number ?? this.number,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      status: status ?? this.status,
      products: products ?? this.products,
      collectedTrays: collectedTrays ?? this.collectedTrays,
      remainingTrays: remainingTrays ?? this.remainingTrays,
    );
  }

  // Calculations
  int get totalTrays =>
      products.fold<int>(0, (sum, item) => sum + item.trays);

  int get totalPackets =>
      products.fold<int>(0, (sum, item) => sum + item.packets);

  int get totalTubs =>
      products.fold<int>(0, (sum, item) => sum + item.tubs);

  // Renamed from remainingTrays to avoid conflict with the field
  int get pendingTrays => totalTrays - collectedTrays;

  // Status helpers
  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isPending => status == DeliveryStatus.pending;

  bool get isFullyCollected =>
      collectedTrays >= totalTrays;

  // JSON
  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id']?.toString() ?? "",
      number: json['number']?.toString() ?? json['boothCode']?.toString() ?? "",
      storeName: json['storeName']?.toString() ?? json['boothName']?.toString() ?? "Store",
      address: json['address']?.toString() ?? "Address not available",
      status: _parseStatus(json['status']?.toString()),
      products: (json['products'] as List?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
      collectedTrays: json['collectedTrays'] ?? 0,
      remainingTrays: json['remainingTrays'] ?? json['outstandingTrays'] ?? 0,
    );
  }

  static DeliveryStatus _parseStatus(String? status) {
    if (status == null) return DeliveryStatus.pending;
    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'COMPLETED':
        return DeliveryStatus.delivered;
      case 'DELIVERING':
      case 'IN_PROGRESS':
      case 'START':
        return DeliveryStatus.delivering;
      case 'PENDING':
      default:
        return DeliveryStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'storeName': storeName,
      'address': address,
      'status': status.name,
      'products': products.map((e) => e.toJson()).toList(),
      'collectedTrays': collectedTrays,
      'remainingTrays': remainingTrays,
    };
  }
}
