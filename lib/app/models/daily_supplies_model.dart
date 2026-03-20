class DailySuppliesModel {
  final int slotId;
  final int shift;
  final String suppliesDate;
  final int totalFarmers;
  final double totalLiters;
  final double localSales;
  final double sentToUnion;
  final double fatPercentage;
  final double snf;
  final double cfStock;

  DailySuppliesModel({
    required this.slotId,
    required this.shift,
    required this.suppliesDate,
    required this.totalFarmers,
    required this.totalLiters,
    required this.localSales,
    required this.sentToUnion,
    required this.fatPercentage,
    required this.snf,
    required this.cfStock,
  });

  Map<String, dynamic> toJson() {
    return {
      'slotId': slotId,
      'shift': shift,
      'suppliesDate': suppliesDate,
      'totalFarmers': totalFarmers,
      'totalLiters': totalLiters,
      'localSales': localSales,
      'sentToUnion': sentToUnion,
      'fatPercentage': fatPercentage,
      'snf': snf,
      'cfStock': cfStock,
    };
  }
}
