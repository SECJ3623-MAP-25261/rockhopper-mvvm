// lib/services/renter_chart_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chart_model.dart';

class RenterChartService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch overall total rentals count (integer) for this renter
  static Future<int> fetchOverallRentals(String renterId) async {
    final response = await _supabase.rpc(
      'get_renter_overall_rentals', // RPC name in Supabase
      params: {'uid': renterId},
    );

    return response == null ? 0 : response as int;
  }

  /// Fetch monthly summary for renter spending
  /// Returns List<EarningDataPoint> like { label: "Jan 2025", amount: 320, date: "2025-01-01" }
  static Future<List<EarningDataPoint>> fetchMonthlySummary(
      String renterId) async {
    final response = await _supabase.rpc(
      'get_renter_monthly_summary',
      params: {'uid': renterId},
    );

    if (response == null) return [];

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);

    return data.map((map) => EarningDataPoint.fromMap(map)).toList();
  }

  /// Fetch total spent (RM) across all completed bookings
  static Future<double> fetchTotalSpent(String renterId) async {
    final response = await _supabase.rpc(
      'get_renter_total_spent',
      params: {'uid': renterId},
    );

    return response == null ? 0 : (response as num).toDouble();
  }
}
