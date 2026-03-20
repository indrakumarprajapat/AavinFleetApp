class CommissionPdfResponse {
  final String url;
  final int reportId;

  CommissionPdfResponse({
    required this.url,
    required this.reportId,
  });

  factory CommissionPdfResponse.fromJson(Map<String, dynamic> json) {
    return CommissionPdfResponse(
      url: json['url'] as String? ?? '',
      reportId: json['reportId'] as int? ?? 0,
    );
  }
}