import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsLocalDataSource {
  static const String _themeKey = 'app_theme_mode';

  final SharedPreferences sharedPreferences;

  SettingsLocalDataSource({required this.sharedPreferences});

  Future<ThemeMode> getThemeMode() async {
    final themeString = sharedPreferences.getString(_themeKey);
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await sharedPreferences.setString(_themeKey, themeString);
  }
}
