import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final _supabase = SupabaseService().client;

  // Login
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up
  Future<AuthResponse> signUp(String email, String password, String role) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    
    // Create profile
    if (response.user != null) {
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'role': role,
        'full_name': email.split('@')[0], // Use email prefix as default name
      });
    }
    
    return response;
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user role
  Future<String?> getUserRole() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    
    try {
      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      
      return response['role'];
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }
  
  // Test if Supabase is connected
  Future<bool> testConnection() async {
    try {
      await _supabase.from('profiles').select().limit(1);
      return true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
