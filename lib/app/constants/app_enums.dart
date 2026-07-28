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

