import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) {
      if (savedTheme == 'light') {
        emit(ThemeMode.light);
      } else if (savedTheme == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.system);
      }
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    emit(newMode);
  }
}
