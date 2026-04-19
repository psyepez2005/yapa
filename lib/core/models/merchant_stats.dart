class MerchantCoupon {
  final String id;
  final String name;
  final double discountValue;
  final String tierRequired;
  final bool isActive;

  const MerchantCoupon({
    required this.id,
    required this.name,
    required this.discountValue,
    required this.tierRequired,
    required this.isActive,
  });

  factory MerchantCoupon.fromJson(Map<String, dynamic> json) => MerchantCoupon(
        id: (json['id'] ?? json['_id'] ?? 'yapa_${DateTime.now().millisecondsSinceEpoch}').toString(),
        name: (json['name'] as String?) ?? (json['code'] as String?) ?? 'Yapa Especial',
        discountValue: _parseDouble(json['discountValue'] ?? json['value']),
        tierRequired: (json['tierRequired'] as String?) ?? 'Bronce',
        isActive: (json['isActive'] as bool?) ?? true,
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class MerchantStats {
  final String merchantName;
  final double balance;
  final int totalCustomers;
  final int returningCustomers;
  final double yapaInvestmentTotal;
  final double yapaCashbackRate;
  final int totalTransactions;
  final double totalRevenue;
  final int newCustomersThisMonth;
  final int returningCustomersThisMonth;
  final bool loyaltyEnabled;

  const MerchantStats({
    required this.merchantName,
    required this.balance,
    required this.totalCustomers,
    required this.returningCustomers,
    required this.yapaInvestmentTotal,
    required this.yapaCashbackRate,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.newCustomersThisMonth,
    required this.returningCustomersThisMonth,
    required this.loyaltyEnabled,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MerchantStats(
      merchantName: (data['businessName'] as String?) ?? (data['merchantName'] as String?) ?? '',
      balance: (data['balance'] as num?)?.toDouble() ??
          (data['couponFundingBalance'] as num?)?.toDouble() ??
          0.0,
      totalCustomers: (data['totalCustomers'] as num?)?.toInt() ?? 0,
      returningCustomers: (data['returningCustomers'] as num?)?.toInt() ?? 0,
      yapaInvestmentTotal: (data['yapaInvestmentTotal'] as num?)?.toDouble() ??
          (data['totalYapasIssued'] as num?)?.toDouble() ??
          0.0,
      yapaCashbackRate: (data['yapaCashbackRate'] as num?)?.toDouble() ??
          (data['cashbackRate'] as num?)?.toDouble() ??
          0.02,
      totalTransactions:
          (data['totalTransactions'] as num?)?.toInt() ??
          (data['totalCompletedTransactions'] as num?)?.toInt() ??
          0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ??
          (data['totalGmv'] as num?)?.toDouble() ??
          0.0,
      newCustomersThisMonth:
          (data['newCustomersThisMonth'] as num?)?.toInt() ?? 0,
      returningCustomersThisMonth:
          (data['returningCustomersThisMonth'] as num?)?.toInt() ??
              (data['returningCustomers'] as num?)?.toInt() ??
              0,
      loyaltyEnabled: (data['loyaltyEnabled'] as bool?) ?? true,
    );
  }

  static const empty = MerchantStats(
    merchantName: '',
    balance: 0,
    totalCustomers: 0,
    returningCustomers: 0,
    yapaInvestmentTotal: 0,
    yapaCashbackRate: 0.02,
    totalTransactions: 0,
    totalRevenue: 0,
    newCustomersThisMonth: 0,
    returningCustomersThisMonth: 0,
    loyaltyEnabled: true,
  );
}
