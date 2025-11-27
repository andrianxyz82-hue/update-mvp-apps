import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    // Test Supabase connection
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').select().limit(1);
      debugPrint('✅ Supabase connected successfully!');
    } catch (e) {
      debugPrint('❌ Supabase connection failed: $e');
    }
    
    // Wait for 5 seconds to let animation play fully
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f1e2c),
      body: Center(
        child: Image.asset(
          'assetsimages/foto.png',
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 100,
                  color: Color(0xFF7C7CFF),
                ),
                SizedBox(height: 24),
                Text(
                  'Safe Exam App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
