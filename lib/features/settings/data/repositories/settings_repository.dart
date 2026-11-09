import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_settings.dart';

class SettingsRepository {
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyAllowPublic = 'settings_allow_public_search';
  static const String _keyRequireAuth = 'settings_require_auth_view';
  static const String _keyBiometric = 'settings_enable_biometric';

  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_keyThemeMode) ?? 'system';
    ThemeMode mode;
    switch (themeStr) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    return UserSettings(
      themeMode: mode,
      allowPublicSearch: prefs.getBool(_keyAllowPublic) ?? true,
      requireAuthToViewCard: prefs.getBool(_keyRequireAuth) ?? false,
      enableBiometric: prefs.getBool(_keyBiometric) ?? false,
    );
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, settings.themeMode.name);
    await prefs.setBool(_keyAllowPublic, settings.allowPublicSearch);
    await prefs.setBool(_keyRequireAuth, settings.requireAuthToViewCard);
    await prefs.setBool(_keyBiometric, settings.enableBiometric);
  }
}
