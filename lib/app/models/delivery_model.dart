enum DeliveryStatus {
  delivered,
  delivering,
  pending,
}

class ProductModel {
  String name;
  int trays;
  int packets;
  int tubs;

  ProductModel({
    required this.name,
    required this.trays,
    required this.packets,
    required this.tubs,
  });
}

class DeliveryModel {
  /// ✅ UNIQUE ID (IMPORTANT FOR NAVIGATION)
  final String id;

  String number;
  String storeName;
  String address;
  DeliveryStatus status;
  List<ProductModel> products;

  /// ✅ COLLECTION DATA
  int collectedTrays;
  int collectedTubs;

  DeliveryModel({
    String? id, // optional for backward compatibility
    required this.number,
    required this.storeName,
    required this.address,
    required this.status,
    required this.products,
    this.collectedTrays = 0,
    this.collectedTubs = 0,
  }) : id = id ?? number; // fallback to number

  /// ✅ TOTAL CALCULATIONS
  int get totalTrays =>
      products.fold(0, (sum, item) => sum + item.trays);

  int get totalPackets =>
      products.fold(0, (sum, item) => sum + item.packets);

  int get totalTubs =>
      products.fold(0, (sum, item) => sum + item.tubs);

  /// ✅ REMAINING
  int get remainingTrays => totalTrays - collectedTrays;
  int get remainingTubs => totalTubs - collectedTubs;

  /// ✅ STATUS HELPERS
  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isPending => status == DeliveryStatus.pending;

  bool get isFullyCollected =>
      collectedTrays >= totalTrays &&
          collectedTubs >= totalTubs;

  /// ✅ MARK FUNCTIONS (BEST PRACTICE)
  void markDelivered() {
    status = DeliveryStatus.delivered;
  }

  void markDelivering() {
    status = DeliveryStatus.delivering;
  }

  void markCollected(int trays, int tubs) {
    collectedTrays = trays;
    collectedTubs = tubs;
  }
}