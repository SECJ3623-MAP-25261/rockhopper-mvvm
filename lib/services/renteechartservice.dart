// lib/services/renteechartservice.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chart_model.dart';

class RenteeChartService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch overall total rentals count (integer)
  static Future<int> fetchOverallRentals(String renteeId) async {
    final response = await _supabase.rpc(
      'get_rentee_overall_rentals',
      params: {'uid': renteeId},
    );

    return response == null ? 0 : response as int;
  }

  /// Fetch monthly summary
  /// Returns a list of { label: "Jan 2025", amount: 320, date: "2025-01-01" }
  static Future<List<EarningDataPoint>> fetchMonthlySummary(
      String renteeId) async {
    final response = await _supabase.rpc(
      'get_rentee_monthly_summary',
      params: {'uid': renteeId},
    );

    if (response == null) return [];

    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(response);

    return data.map((map) => EarningDataPoint.fromMap(map)).toList();
  }

  /// Fetch total earned (RM) across all bookings
  static Future<double> fetchTotalEarned(String renteeId) async {
    final response = await _supabase.rpc(
      'get_rentee_total_earned',
      params: {'uid': renteeId},
    );

    return response == null ? 0 : (response as num).toDouble();
  }
}
