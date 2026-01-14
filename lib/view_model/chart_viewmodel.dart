// lib/view_model/chart_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/renteechartservice.dart';
import 'chart_ui_data.dart';

enum ChartRange { monthly, overall }

class ChartViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  ChartRange selectedRange = ChartRange.monthly;

  List<ChartBarData> chartData = [];
  double totalEarned = 0;

  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _renteeId => _supabase.auth.currentUser?.id;

  Future<void> loadEarnings() async {
    if (_renteeId == null) {
      errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      totalEarned = await RenteeChartService.fetchTotalEarned(_renteeId!);

      if (selectedRange == ChartRange.monthly) {
        final backendData =
            await RenteeChartService.fetchMonthlySummary(_renteeId!);

        // Map backend model to UI-friendly DTO
        chartData = backendData
            .map((e) => ChartBarData(
                  label: _monthName(e.month),
                  value: e.totalEarnedOrSpent,
                ))
            .toList();
      } else {
        chartData = [
          ChartBarData(label: "Overall", value: totalEarned),
        ];
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> changeRange(ChartRange range) async {
    selectedRange = range;
    await loadEarnings();
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month < 1 || month > 12) return 'Unknown';
    return names[month - 1];
  }
}
