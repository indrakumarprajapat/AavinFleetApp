class NearbyBoothModel {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String address;
  final double distanceKm;

  NearbyBoothModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
    required this.distanceKm,
  });

  factory NearbyBoothModel.fromJson(Map<String, dynamic> json) {
    return NearbyBoothModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'distance_km': distanceKm,
    };
  }
}