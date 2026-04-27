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
  none,
  morning,
  evening
}