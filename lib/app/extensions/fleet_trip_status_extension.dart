import 'package:aavin/app/constants/app_enums.dart';

extension FleetTripStatusExtension on FleetTripStatus {
  String get label {
    switch (this) {
      case FleetTripStatus.none:
        return 'None';
      case FleetTripStatus.created:
        return 'New';
      case FleetTripStatus.tripDeliveryStarted:
        return 'Started';
      case FleetTripStatus.tripDeliveryInProgress:
        return 'Delivering';
      case FleetTripStatus.tripDeliveryCompleted:
        return 'All Delivered';
      case FleetTripStatus.tripCollectionStarted:
        return 'Collection Started';
      case FleetTripStatus.tripCollectionInProgress:
        return 'Collecting';
      case FleetTripStatus.tripCollectionCompleted:
        return 'Collection Completed';
      case FleetTripStatus.tripCompleted:
        return 'Trip Completed';
      case FleetTripStatus.cancelled:
        return 'Cancelled';
    }
  }
}