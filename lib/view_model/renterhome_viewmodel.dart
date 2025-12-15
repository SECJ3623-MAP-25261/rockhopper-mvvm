/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/device_model.dart';

class RenterHomeViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Device> devices = [];
  bool isLoading = true;
  String? errorMessage;

  RenterHomeViewModel() {
    loadAvailableDevices();
  }

  Future<void> loadAvailableDevices() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('devices')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .execute();

      if (response.error != null) {
        throw response.error!;
      }

      final data = response.data as List<dynamic>;
      devices = data.map((e) => Device.fromMap(e)).toList();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
*/