import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  
  User? get currentUser => client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  // Test connection
  Future<bool> testConnection() async {
    try {
      // Try to fetch from a table (will fail if not connected)
      await client.from('profiles').select().limit(1);
      return true;
    } catch (e) {
      print('Supabase connection test failed: $e');
      return false;
    }
  }
}
