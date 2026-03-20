class WalletTransactionModel {
  final int id;
  final int walletId;
  final int agentId;
  final int transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final int? referenceType;
  final int? referenceId;
  final String? description;
  final int status;
  final String createdAt;
  final String? transactionId; // Added for payment gateway transaction ID

  WalletTransactionModel({
    required this.id,
    required this.walletId,
    required this.agentId,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.description,
    required this.status,
    required this.createdAt,
    this.transactionId,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? json['walletId'] ?? 0,
      agentId: json['agent_id'] ?? json['agentId'] ?? 0,
      transactionType: json['transaction_type'] ?? json['transactionType'] ?? 1,
      amount: (json['amount'] ?? 0).toDouble(),
      balanceBefore: (json['balance_before'] ?? json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balance_after'] ?? json['balanceAfter'] ?? 0).toDouble(),
      referenceType: json['reference_type'] ?? json['referenceType'],
      referenceId: json['reference_id'] ?? json['referenceId'],
      description: json['description'],
      status: json['status'] ?? 1,
      createdAt: json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      transactionId: json['transaction_id'] ?? json['transactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'agent_id': agentId,
      'transaction_type': transactionType,
      'amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'description': description,
      'status': status,
      'created_at': createdAt,
      'transaction_id': transactionId,
    };
  }

  // Helper methods
  String get transactionTypeText {
    switch (transactionType) {
      case 1:
        return 'Credit';
      case 2:
        return 'Debit';
      default:
        return 'Unknown';
    }
  }

  String get statusText {
    switch (status) {
      case 1:
        return 'Completed';
      case 0:
        return 'Pending';
      case -1:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  bool get isCredit => transactionType == 1;
  bool get isDebit => transactionType == 2;
  bool get isCompleted => status == 1;
}