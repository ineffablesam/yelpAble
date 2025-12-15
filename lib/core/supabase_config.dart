import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yelpable/modules/Auth/Controller/auth_controller.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://pconfbgwtzgrubgkvotc.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBjb25mYmd3dHpncnViZ2t2b3RjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyMzYzNjksImV4cCI6MjA4MDgxMjM2OX0.Qb-NKFS8VSwZBYed6si1HXXQZfwQu1g1aJK9XIZUiN4';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    final authController = Get.put(AuthController());
    // authController.loadUserFromLocal();
  }

  static SupabaseClient get client => Supabase.instance.client;
}
