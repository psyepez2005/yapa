import 'package:flutter/material.dart';

class ActiveYapa {
  final String id;
  final double value;
  final int tierEarnedAt;
  final DateTime expiresAt;

  const ActiveYapa({
    required this.id,
    required this.value,
    required this.tierEarnedAt,
    required this.expiresAt,
  });

  factory ActiveYapa.fromJson(Map<String, dynamic> json) => ActiveYapa(
        id: json['id'] as String,
        value: (json['value'] as num).toDouble(),
        tierEarnedAt: json['tierEarnedAt'] as int,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  bool get isExpiringSoon =>
      expiresAt.difference(DateTime.now()).inDays <= 7;

  int get daysUntilExpiry =>
      expiresAt.difference(DateTime.now()).inDays;
}

class LoyaltyProfileEntry {
  final String merchantId;
  final String merchantName;
  final int tierLevel;
  final double trustPoints;
  final double? pointsToNextCoupon;
  final List<ActiveYapa> activeYapas;
  final int yapasCount;
  final double totalYapasValue;
  final DateTime? degradationDueDate;

  const LoyaltyProfileEntry({
    required this.merchantId,
    required this.merchantName,
    required this.tierLevel,
    required this.trustPoints,
    required this.pointsToNextCoupon,
    required this.activeYapas,
    required this.yapasCount,
    required this.totalYapasValue,
    this.degradationDueDate,
  });

  factory LoyaltyProfileEntry.fromJson(Map<String, dynamic> json) {
    final yapasRaw = json['activeYapas'] as List? ?? [];
    final degradationRaw = json['degradationDueDate'] as String?;
    return LoyaltyProfileEntry(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      tierLevel: json['tierLevel'] as int,
      trustPoints: (json['trustPoints'] as num).toDouble(),
      pointsToNextCoupon: json['pointsToNextCoupon'] == null
          ? null
          : (json['pointsToNextCoupon'] as num).toDouble(),
      activeYapas: yapasRaw
          .map((e) => ActiveYapa.fromJson(e as Map<String, dynamic>))
          .toList(),
      yapasCount: json['yapasCount'] as int,
      totalYapasValue: (json['totalYapasValue'] as num).toDouble(),
      degradationDueDate:
          degradationRaw != null ? DateTime.tryParse(degradationRaw) : null,
    );
  }

  int? get degradationRiskDays {
    if (degradationDueDate == null) return null;
    return degradationDueDate!.difference(DateTime.now()).inDays;
  }

  bool get isDegradationRisk {
    final days = degradationRiskDays;
    return days != null && days <= 7 && days >= 0;
  }

  // ── Tier helpers ──────────────────────────────────────────────────────────

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

  String get nextTierName {
    switch (tierLevel) {
      case 1:
        return 'Plata (2%)';
      case 2:
        return 'Oro (3%)';
      case 3:
        return 'Nivel Máximo';
      default:
        return 'Plata';
    }
  }

  String get cashbackLabel {
    switch (tierLevel) {
      case 1:
        return '1%';
      case 2:
        return '2%';
      case 3:
        return '3%';
      default:
        return '1%';
    }
  }

  Color get tierColor {
    switch (tierLevel) {
      case 1:
        return const Color(0xFFCE8946);
      case 2:
        return const Color(0xFF78909C);
      case 3:
        return const Color(0xFFF57F17);
      default:
        return const Color(0xFFCE8946);
    }
  }

  Color get tierBgColor {
    switch (tierLevel) {
      case 1:
        return const Color(0xFFFBE9E7);
      case 2:
        return const Color(0xFFECEFF1);
      case 3:
        return const Color(0xFFFFF9C4);
      default:
        return const Color(0xFFFBE9E7);
    }
  }

  // ── Progress helpers ──────────────────────────────────────────────────────

  double get progressValue {
    if (pointsToNextCoupon == null) return 1.0;
    final total = trustPoints + pointsToNextCoupon!;
    if (total <= 0) return 0.0;
    return (trustPoints / total).clamp(0.0, 1.0);
  }

  double get targetPoints => trustPoints + (pointsToNextCoupon ?? 0);
}
