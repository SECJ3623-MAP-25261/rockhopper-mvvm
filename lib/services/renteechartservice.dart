import 'package:supabase_flutter/supabase_flutter.dart';

class RenteeChartService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  // Overall total rentals
  static Future<int> fetchOverallRentals(String renteeId) async {
    final response = await _supabase.rpc(
      'get_rentee_overall_rentals',
      params: {'uid': renteeId},
    );

    return response == null ? 0 : response as int;
  }

  // Monthly rentals
static Future<List<Map<String, dynamic>>> fetchMonthlySummary(
    String renteeId) async {
  final response = await Supabase.instance.client.rpc(
    'get_rentee_monthly_summary',
    params: {'uid': renteeId},
  );

  return response == null
      ? []
      : List<Map<String, dynamic>>.from(response);
}


  // Total earned (RM)
  static Future<double> fetchTotalEarned(String renteeId) async {
    final response = await _supabase.rpc(
      'get_rentee_total_earned',
      params: {'uid': renteeId},
    );

    return response == null
        ? 0
        : (response as num).toDouble();
  }
}
