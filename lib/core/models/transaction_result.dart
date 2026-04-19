class CouponApplied {
  final String id;
  final double discountAmount;

  const CouponApplied({required this.id, required this.discountAmount});

  factory CouponApplied.fromJson(Map<String, dynamic> json) => CouponApplied(
        id: json['id'] as String,
        discountAmount: (json['discountAmount'] as num).toDouble(),
      );
}

class CouponUnlocked {
  final String id;
  final double value;
  final String message;

  const CouponUnlocked({
    required this.id,
    required this.value,
    required this.message,
  });

  factory CouponUnlocked.fromJson(Map<String, dynamic> json) => CouponUnlocked(
        id: json['id'] as String,
        value: (json['value'] as num).toDouble(),
        message: json['message'] as String,
      );
}

class TransactionResult {
  final String transactionId;
  final double trustPointsEarned;
  final double totalTrustPoints;
  final int tierLevel;
  final double? pointsToNextCoupon;
  final int activeYapasCount;
  final CouponApplied? couponApplied;
  final CouponUnlocked? couponUnlocked;
  final bool antifraudBlocked;

  const TransactionResult({
    required this.transactionId,
    required this.trustPointsEarned,
    required this.totalTrustPoints,
    required this.tierLevel,
    required this.pointsToNextCoupon,
    required this.activeYapasCount,
    required this.couponApplied,
    required this.couponUnlocked,
    required this.antifraudBlocked,
  });

  factory TransactionResult.fromJson(Map<String, dynamic> json) =>
      TransactionResult(
        transactionId: json['transactionId'] as String,
        trustPointsEarned: (json['trustPointsEarned'] as num).toDouble(),
        totalTrustPoints: (json['totalTrustPoints'] as num).toDouble(),
        tierLevel: json['tierLevel'] as int,
        pointsToNextCoupon: json['pointsToNextCoupon'] == null
            ? null
            : (json['pointsToNextCoupon'] as num).toDouble(),
        activeYapasCount: json['activeYapasCount'] as int,
        couponApplied: json['couponApplied'] == null
            ? null
            : CouponApplied.fromJson(
                json['couponApplied'] as Map<String, dynamic>),
        couponUnlocked: json['couponUnlocked'] == null
            ? null
            : CouponUnlocked.fromJson(
                json['couponUnlocked'] as Map<String, dynamic>),
        antifraudBlocked: json['antifraudBlocked'] as bool,
      );

  String get tierName {
    switch (tierLevel) {
      case 1:
        return 'Bronce';
      case 2:
        return 'Plata';
      case 3:
        return 'Oro';
      default:
        return 'Bronce';
    }
  }
}
