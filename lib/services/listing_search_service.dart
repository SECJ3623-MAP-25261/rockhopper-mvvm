// lib/services/listing_search_service.dart
/*import 'package:supabase_flutter/supabase_flutter.dart';

class ListingSearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Search available listings
  Future<List<Map<String, dynamic>>> searchAvailableListings({
    String query = '',
    String? category,
    String? brand,
    String? location,
    double? maxPrice,
    String? condition,
    int? maxRentalDays,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var searchQuery = _supabase
          .from('listings')
          .select('*')
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(limit);

      // Text search across multiple columns
      if (query.isNotEmpty) {
        searchQuery = searchQuery.or('''
          name.ilike.%$query%,
          description.ilike.%$query%,
          brand.ilike.%$query%,
          category.ilike.%$query%
        ''');
      }

      // Apply filters
      if (category != null && category.isNotEmpty) {
        searchQuery = searchQuery.eq('category', category);
      }

      if (brand != null && brand.isNotEmpty) {
        searchQuery = searchQuery.eq('brand', brand);
      }

      if (location != null && location.isNotEmpty) {
        searchQuery = searchQuery.ilike('location', '%$location%');
      }

      if (maxPrice != null) {
        searchQuery = searchQuery.lte('price_per_day', maxPrice);
      }

      final data = await searchQuery;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Get distinct categories
  Future<List<String>> getCategories() async {
    try {
      final response = await _supabase
          .from('listings')
          .select('category')
          .eq('is_available', true);

      final categories = response
          .map((item) => item['category'] as String)
          .toSet()
          .toList()
          ..sort();

      return categories;
    } catch (e) {
      print('Categories error: $e');
      return [];
    }
  }
}*/