class SocietySupply {
  int? societyId;
  int slotId;
  String supplyDate;
  int shift;

  double collectionTotalSamples;
  double collectionTotalQty;
  double collectionTotalLocalSalesQty;
  double collectionTotalSentToUnionQty;
  double collectionAvgSnf;
  double collectionAvgFat;
  double collectionAvgPurchaseRate;

  double sampleTotal;
  double sampleMilkQty;
  double sampleFreeMilkStaffQty;
  double sampleNetSampleQty;
  double sampleMpcsAccountQty;
  double sampleSaleAccountQty;

  double openingBalance;
  double localSalesValue;
  double otherIncome;
  double totalExpenditure;
  double closingBalance;

  double cfStockBags;
  double cfSalesBags;
  double cfClosingBags;

  double fssNos;
  double fssOpeningBalance;
  double fssReceipt;
  double fssTotal;
  double fssIssue;
  double fssClosingBalance;

  SocietySupply({
    this.societyId,
    required this.slotId,
    required this.supplyDate,
    required this.shift,
    required this.collectionTotalSamples,
    required this.collectionTotalQty,
    required this.collectionTotalLocalSalesQty,
    required this.collectionTotalSentToUnionQty,
    required this.collectionAvgSnf,
    required this.collectionAvgFat,
    required this.collectionAvgPurchaseRate,
    required this.sampleTotal,
    required this.sampleMilkQty,
    required this.sampleFreeMilkStaffQty,
    required this.sampleNetSampleQty,
    required this.sampleMpcsAccountQty,
    required this.sampleSaleAccountQty,
    required this.openingBalance,
    required this.localSalesValue,
    required this.otherIncome,
    required this.totalExpenditure,
    required this.closingBalance,
    required this.cfStockBags,
    required this.cfSalesBags,
    required this.cfClosingBags,
    required this.fssNos,
    required this.fssOpeningBalance,
    required this.fssReceipt,
    required this.fssTotal,
    required this.fssIssue,
    required this.fssClosingBalance,
  });

  /// FROM JSON
  factory SocietySupply.fromJson(Map<String, dynamic> json) {
    return SocietySupply(
      societyId: json["society_id"],
      slotId: json["slot_id"],
      supplyDate: json["supply_date"],
      shift: json["shift"],

      collectionTotalSamples: (json["collection_total_samples"] ?? 0)
          .toDouble(),
      collectionTotalQty: (json["collection_total_qty"] ?? 0).toDouble(),
      collectionTotalLocalSalesQty:
          (json["collection_total_local_sales_qty"] ?? 0).toDouble(),
      collectionTotalSentToUnionQty:
          (json["collection_total_sent_to_union_qty"] ?? 0).toDouble(),
      collectionAvgSnf: (json["collection_avg_snf"] ?? 0).toDouble(),
      collectionAvgFat: (json["collection_avg_fat"] ?? 0).toDouble(),
      collectionAvgPurchaseRate: (json["collection_avg_purchase_rate"] ?? 0)
          .toDouble(),

      sampleTotal: (json["sample_total"] ?? 0).toDouble(),
      sampleMilkQty: (json["sample_milk_qty"] ?? 0).toDouble(),
      sampleFreeMilkStaffQty: (json["sample_free_milk_staff_qty"] ?? 0)
          .toDouble(),
      sampleNetSampleQty: (json["sample_net_sample_qty"] ?? 0).toDouble(),
      sampleMpcsAccountQty: (json["sample_mpcs_account_qty"] ?? 0).toDouble(),
      sampleSaleAccountQty: (json["sample_sale_account_qty"] ?? 0).toDouble(),

      openingBalance: (json["opening_balance"] ?? 0).toDouble(),
      localSalesValue: (json["local_sales_value"] ?? 0).toDouble(),
      otherIncome: (json["other_income"] ?? 0).toDouble(),
      totalExpenditure: (json["total_expenditure"] ?? 0).toDouble(),
      closingBalance: (json["closing_balance"] ?? 0).toDouble(),

      cfStockBags: (json["cf_stock_bags"] ?? 0).toDouble(),
      cfSalesBags: (json["cf_sales_bags"] ?? 0).toDouble(),
      cfClosingBags: (json["cf_closing_bags"] ?? 0).toDouble(),

      fssNos: (json["fss_nos"] ?? 0).toDouble(),
      fssOpeningBalance: (json["fss_opening_balance"] ?? 0).toDouble(),
      fssReceipt: (json["fss_receipt"] ?? 0).toDouble(),
      fssTotal: (json["fss_total"] ?? 0).toDouble(),
      fssIssue: (json["fss_issue"] ?? 0).toDouble(),
      fssClosingBalance: (json["fss_closing_balance"] ?? 0).toDouble(),
    );
  }
  Map<String, dynamic> toJson() => {
    if (societyId != null) "societyId": societyId,
    "slotId": slotId,
    "supplyDate": supplyDate,
    "shift": shift,

    "collectionTotalSamples": collectionTotalSamples,
    "collectionTotalQty": collectionTotalQty,
    "collectionTotalLocalSalesQty": collectionTotalLocalSalesQty,
    "collectionTotalSentToUnionQty": collectionTotalSentToUnionQty,
    "collectionAvgSnf": collectionAvgSnf,
    "collectionAvgFat": collectionAvgFat,
    "collectionAvgPurchaseRate": collectionAvgPurchaseRate,

    "sampleTotal": sampleTotal,
    "sampleMilkQty": sampleMilkQty,
    "sampleFreeMilkStaffQty": sampleFreeMilkStaffQty,
    "sampleNetSampleQty": sampleNetSampleQty,
    "sampleMpcsAccountQty": sampleMpcsAccountQty,
    "sampleSaleAccountQty": sampleSaleAccountQty,

    "openingBalance": openingBalance,
    "localSalesValue": localSalesValue,
    "otherIncome": otherIncome,
    "totalExpenditure": totalExpenditure,
    "closingBalance": closingBalance,

    "cfStockBags": cfStockBags,
    "cfSalesBags": cfSalesBags,
    "cfClosingBags": cfClosingBags,

    "fssNos": fssNos,
    "fssOpeningBalance": fssOpeningBalance,
    "fssReceipt": fssReceipt,
    "fssTotal": fssTotal,
    "fssIssue": fssIssue,
    "fssClosingBalance": fssClosingBalance,
  };
}
