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
      name: json['name'],
      trays: json['trays'],
      packets: json['packets'],
      tubs: json['tubs'],
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

  const DeliveryModel({
    required this.id,
    required this.number,
    required this.storeName,
    required this.address,
    required this.status,
    required this.products,
    this.collectedTrays = 0,
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
    int? collectedTubs,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      number: number ?? this.number,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      status: status ?? this.status,
      products: products ?? this.products,
      collectedTrays: collectedTrays ?? this.collectedTrays,
    );
  }

  // Calculations
  int get totalTrays =>
      products.fold<int>(0, (sum, item) => sum + item.trays);

  int get totalPackets =>
      products.fold<int>(0, (sum, item) => sum + item.packets);

  int get totalTubs =>
      products.fold<int>(0, (sum, item) => sum + item.tubs);

  int get remainingTrays => totalTrays - collectedTrays;

  // Status helpers
  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isPending => status == DeliveryStatus.pending;

  bool get isFullyCollected =>
      collectedTrays >= totalTrays;

  // JSON
  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      number: json['number'],
      storeName: json['storeName'],
      address: json['address'],
      status: DeliveryStatus.values.firstWhere(
            (e) => e.name == json['status'],
      ),
      products: (json['products'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList(),
      collectedTrays: json['collectedTrays'] ?? 0,
    );
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
    };
  }
}