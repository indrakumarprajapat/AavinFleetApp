enum UserType { none, customer, agent, society,fleetUser }


enum AppState {
  idle,
  loading,
  success,
  error,
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}


enum OrderShift {
  both(0),
  morning(1),
  evening(2);

  final int value;
  const OrderShift(this.value);

  static OrderShift fromValue(int value) {
    return OrderShift.values.firstWhere(
          (e) => e.value == value,
      orElse: () => OrderShift.both,
    );
}
}

enum FleetTripStatus {
  none(0),
  created(1), // New
  tripDeliveryStarted(2), // Started
  tripDeliveryInProgress(3), // Delivering
  tripDeliveryCompleted(4), // All Delivered
  tripCollectionStarted(5), // Collection Started
  tripCollectionInProgress(6), // Collecting
  tripCollectionCompleted(7), // Collection Completed
  tripCompleted(8), // Trip Completed
  cancelled(9); // Cancelled

  final int value;
  const FleetTripStatus(this.value);

  static FleetTripStatus fromValue(int value) {
    return FleetTripStatus.values.firstWhere(
          (e) => e.value == value,
      orElse: () => FleetTripStatus.none,
    );
  }
}

/// 1=Distribution, 2=MCR, 3=MTR
enum FleetType {
  distribution(1),
  mcr(2),
  mtr(3);

  final int value;
  const FleetType(this.value);

  static FleetType fromValue(int? value) {
    return FleetType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FleetType.distribution,
    );
  }

  bool get isCollection => this == FleetType.mcr || this == FleetType.mtr;
}

/// Milk collection trip lifecycle (procure)
enum CollectionFleetTripStatus {
  none(0),
  created(1),
  started(2),
  inProgress(3),
  collectionDone(4),
  submitted(5),
  completed(6),
  cancelled(9);

  final int value;
  const CollectionFleetTripStatus(this.value);

  static CollectionFleetTripStatus fromValue(int? value) {
    return CollectionFleetTripStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CollectionFleetTripStatus.none,
    );
  }
}

enum CollectionStopStatus {
  pending(1),
  collected(2),
  partiallyCollected(3),
  skipped(4);

  final int value;
  const CollectionStopStatus(this.value);

  static CollectionStopStatus fromValue(int? value) {
    return CollectionStopStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CollectionStopStatus.pending,
    );
  }
}

enum CollectionSubmitStatus {
  pending(1),
  submitted(2);

  final int value;
  const CollectionSubmitStatus(this.value);

  static CollectionSubmitStatus fromValue(int? value) {
    return CollectionSubmitStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CollectionSubmitStatus.pending,
    );
  }
}

