class MerchantCoupon {
  final String id;
  final String name;
  final double discountValue;
  final String tierRequired;
  final bool isActive;
  final int quantity;

  const MerchantCoupon({
    required this.id,
    required this.name,
    required this.discountValue,
    required this.tierRequired,
    required this.isActive,
    this.quantity = 1,
  });

  factory MerchantCoupon.fromJson(Map<String, dynamic> json) => MerchantCoupon(
        id: (json['id'] ?? json['_id'] ?? 'yapa_${DateTime.now().millisecondsSinceEpoch}').toString(),
        name: (json['name'] as String?) ?? (json['code'] as String?) ?? 'Yapa Especial',
        discountValue: _parseDouble(json['discountValue'] ?? json['value']),
        tierRequired: (json['tierRequired'] as String?) ?? 'Bronce',
        isActive: !(json['isRedeemed'] as bool? ?? false),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class TierDistribution {
  final int tier1;
  final int tier2;
  final int tier3;

  const TierDistribution({this.tier1 = 0, this.tier2 = 0, this.tier3 = 0});

  int get total => tier1 + tier2 + tier3;

  factory TierDistribution.fromJson(Map<String, dynamic> json) =>
      TierDistribution(
        tier1: (json['tier1'] as num?)?.toInt() ?? 0,
        tier2: (json['tier2'] as num?)?.toInt() ?? 0,
        tier3: (json['tier3'] as num?)?.toInt() ?? 0,
      );

  static const empty = TierDistribution();
}

class MerchantStats {
  final String merchantName;
  final double balance;
  final TierDistribution tierDistribution;
  final double yapaInvestmentTotal;
  final int totalTransactions;
  final double totalRevenue;
  final bool loyaltyEnabled;

  int get totalCustomers => tierDistribution.total;
  int get returningCustomers => tierDistribution.tier2 + tierDistribution.tier3;
  int get newCustomersThisMonth => tierDistribution.tier1;
  int get returningCustomersThisMonth => tierDistribution.tier2 + tierDistribution.tier3;

  final int activeLoyaltyCoupons;

  const MerchantStats({
    required this.merchantName,
    required this.balance,
    required this.tierDistribution,
    required this.yapaInvestmentTotal,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.loyaltyEnabled,
    this.activeLoyaltyCoupons = 0,
  });

  factory MerchantStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final tierJson = data['tierDistribution'] as Map<String, dynamic>? ?? {};
    return MerchantStats(
      merchantName: (data['businessName'] as String?) ?? (data['merchantName'] as String?) ?? '',
      balance: (data['couponFundingBalance'] as num?)?.toDouble() ??
          (data['balance'] as num?)?.toDouble() ??
          0.0,
      tierDistribution: TierDistribution.fromJson(tierJson),
      yapaInvestmentTotal: (data['pendingSubsidyAmount'] as num?)?.toDouble() ??
          (data['yapaInvestmentTotal'] as num?)?.toDouble() ??
          0.0,
      totalTransactions: (data['totalCompletedTransactions'] as num?)?.toInt() ??
          (data['totalTransactions'] as num?)?.toInt() ??
          0,
      totalRevenue: (data['totalGmv'] as num?)?.toDouble() ??
          (data['totalRevenue'] as num?)?.toDouble() ??
          0.0,
      loyaltyEnabled: (data['loyaltyEnabled'] as bool?) ?? true,
      activeLoyaltyCoupons: (data['activeLoyaltyCoupons'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = MerchantStats(
    merchantName: '',
    balance: 0,
    tierDistribution: TierDistribution.empty,
    yapaInvestmentTotal: 0,
    totalTransactions: 0,
    totalRevenue: 0,
    loyaltyEnabled: true,
  );
}
