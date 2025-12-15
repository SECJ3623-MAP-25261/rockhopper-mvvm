import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadImage(File image) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';

    await _supabase.storage.from('listing-images').upload(
      fileName,
      image,
      fileOptions: const FileOptions(upsert: true),
    );

    return _supabase.storage.from('listing-images').getPublicUrl(fileName);
  }
}
