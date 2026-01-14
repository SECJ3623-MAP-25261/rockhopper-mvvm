// lib/models/chart_model.dart

enum ChartRange {
  monthly,
  overall,
}

class EarningDataPoint {
  final int month;           // keep int, since month is numeric
  final int totalRentals;
  final double totalEarnedOrSpent;  // renamed for neutrality

  EarningDataPoint({
    required this.month,
    required this.totalRentals,
    required this.totalEarnedOrSpent,
  });

  factory EarningDataPoint.fromMap(Map<String, dynamic> map) {
    return EarningDataPoint(
      month: (map['month'] ?? 0).toInt(),
      totalRentals: (map['total_rentals'] ?? 0).toInt(),
      totalEarnedOrSpent: (map['total_earned'] ?? map['total_spent'] ?? 0).toDouble(),
    );
  }
}
