class MerchantBroadcast {
  final String id;
  final String merchantId;
  final String merchantName;
  final String? couponId;
  final String message;
  final double? couponValue;
  final DateTime createdAt;

  const MerchantBroadcast({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    this.couponId,
    required this.message,
    this.couponValue,
    required this.createdAt,
  });

  factory MerchantBroadcast.fromJson(Map<String, dynamic> json) {
    return MerchantBroadcast(
      id: json['id']?.toString() ?? '',
      merchantId: json['merchantId']?.toString() ?? '',
      merchantName: json['merchantName']?.toString() ?? '',
      couponId: json['couponId']?.toString(),
      message: json['message']?.toString() ?? '',
      couponValue: json['couponValue'] != null
          ? double.tryParse(json['couponValue'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
