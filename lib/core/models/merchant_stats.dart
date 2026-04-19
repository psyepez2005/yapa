class MerchantCoupon {
  final String id;
  final double discountValue;
  final String tierRequired;
  final bool isActive;

  const MerchantCoupon({
    required this.id,
    required this.discountValue,
    required this.tierRequired,
    required this.isActive,
  });

  factory MerchantCoupon.fromJson(Map<String, dynamic> json) => MerchantCoupon(
        id: json['id'] as String,
        discountValue: (json['discountValue'] as num).toDouble(),
        tierRequired: (json['tierRequired'] as String?) ?? 'Bronce',
        isActive: (json['isActive'] as bool?) ?? true,
      );
}

class MerchantStats {
  final double balance;
  final int totalCustomers;
  final int returningCustomers;
  final double yapaInvestmentTotal;
  final double yapaCashbackRate;
  final int totalTransactions;
  final double totalRevenue;
  final int newCustomersThisMonth;
  final int returningCustomersThisMonth;

  const MerchantStats({
    required this.balance,
    required this.totalCustomers,
    required this.returningCustomers,
    required this.yapaInvestmentTotal,
    required this.yapaCashbackRate,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.newCustomersThisMonth,
    required this.returningCustomersThisMonth,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    // Flexible parsing — backend may nest data differently
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MerchantStats(
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      totalCustomers: (data['totalCustomers'] as num?)?.toInt() ?? 0,
      returningCustomers: (data['returningCustomers'] as num?)?.toInt() ?? 0,
      yapaInvestmentTotal: (data['yapaInvestmentTotal'] as num?)?.toDouble() ??
          (data['totalYapasIssued'] as num?)?.toDouble() ??
          0.0,
      yapaCashbackRate: (data['yapaCashbackRate'] as num?)?.toDouble() ??
          (data['cashbackRate'] as num?)?.toDouble() ??
          0.02,
      totalTransactions: (data['totalTransactions'] as num?)?.toInt() ?? 0,
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      newCustomersThisMonth:
          (data['newCustomersThisMonth'] as num?)?.toInt() ?? 0,
      returningCustomersThisMonth:
          (data['returningCustomersThisMonth'] as num?)?.toInt() ??
              (data['returningCustomers'] as num?)?.toInt() ??
              0,
    );
  }

  // Fallback empty stats for error states
  static const empty = MerchantStats(
    balance: 0,
    totalCustomers: 0,
    returningCustomers: 0,
    yapaInvestmentTotal: 0,
    yapaCashbackRate: 0.02,
    totalTransactions: 0,
    totalRevenue: 0,
    newCustomersThisMonth: 0,
    returningCustomersThisMonth: 0,
  );
}
