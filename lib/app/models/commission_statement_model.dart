class CommissionStatementModel {
  final String month;
  final List<DailyCommissionData> dailyData;
  final CommissionTotals totals;

  CommissionStatementModel({
    required this.month,
    required this.dailyData,
    required this.totals,
  });

  factory CommissionStatementModel.fromJson(Map<String, dynamic> json) {
    return CommissionStatementModel(
      month: json['month'] ?? '',
      dailyData: (json['daily_data'] as List?)
          ?.map((item) => DailyCommissionData.fromJson(item))
          .toList() ?? [],
      totals: CommissionTotals.fromJson(json['totals'] ?? {}),
    );
  }
}

class DailyCommissionData {
  final String date;
  final String agentName;
  final String agentCode;
  final double milkLitres;
  final double milkAmount;
  final double commission;
  final double sgmMilkLitres;
  final double sgmMilkAmount;
  final double sgmCommission;
  final double grossCommission;
  final double tds5Percent;
  final double totalCommission;

  DailyCommissionData({
    required this.date,
    required this.agentName,
    required this.agentCode,
    required this.milkLitres,
    required this.milkAmount,
    required this.commission,
    required this.sgmMilkLitres,
    required this.sgmMilkAmount,
    required this.sgmCommission,
    required this.grossCommission,
    required this.tds5Percent,
    required this.totalCommission,
  });

  factory DailyCommissionData.fromJson(Map<String, dynamic> json) {
    return DailyCommissionData(
      date: json['date'] ?? '',
      agentName: json['agent_name'] ?? '',
      agentCode: json['agent_code'] ?? '',
      milkLitres: (json['milk_litres'] ?? 0).toDouble(),
      milkAmount: (json['milk_amount'] ?? 0).toDouble(),
      commission: (json['commission'] ?? 0).toDouble(),
      sgmMilkLitres: (json['sgm_milk_litres'] ?? 0).toDouble(),
      sgmMilkAmount: (json['sgm_milk_amount'] ?? 0).toDouble(),
      sgmCommission: (json['sgm_commission'] ?? 0).toDouble(),
      grossCommission: (json['gross_commission'] ?? 0).toDouble(),
      tds5Percent: (json['tds_5_percent'] ?? 0).toDouble(),
      totalCommission: (json['total_commission'] ?? 0).toDouble(),
    );
  }
}

class CommissionTotals {
  final double totalMilkLitres;
  final double totalMilkAmount;
  final double totalCommission;
  final double totalSgmMilkLitres;
  final double totalSgmMilkAmount;
  final double totalSgmCommission;
  final double totalGrossCommission;
  final double totalTds;
  final double finalTotalCommission;
  final double slipCharge;
  final double netCommission;

  CommissionTotals({
    required this.totalMilkLitres,
    required this.totalMilkAmount,
    required this.totalCommission,
    required this.totalSgmMilkLitres,
    required this.totalSgmMilkAmount,
    required this.totalSgmCommission,
    required this.totalGrossCommission,
    required this.totalTds,
    required this.finalTotalCommission,
    required this.slipCharge,
    required this.netCommission,
  });

  factory CommissionTotals.fromJson(Map<String, dynamic> json) {
    return CommissionTotals(
      totalMilkLitres: (json['total_milk_litres'] ?? 0).toDouble(),
      totalMilkAmount: (json['total_milk_amount'] ?? 0).toDouble(),
      totalCommission: (json['total_commission'] ?? 0).toDouble(),
      totalSgmMilkLitres: (json['total_sgm_milk_litres'] ?? 0).toDouble(),
      totalSgmMilkAmount: (json['total_sgm_milk_amount'] ?? 0).toDouble(),
      totalSgmCommission: (json['total_sgm_commission'] ?? 0).toDouble(),
      totalGrossCommission: (json['total_gross_commission'] ?? 0).toDouble(),
      totalTds: (json['total_tds'] ?? 0).toDouble(),
      finalTotalCommission: (json['final_total_commission'] ?? 0).toDouble(),
      slipCharge: (json['slip_charge'] ?? 0).toDouble(),
      netCommission: (json['net_commission'] ?? 0).toDouble(),
    );
  }
}