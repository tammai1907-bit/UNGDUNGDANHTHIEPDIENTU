import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/user_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const UserSettings()) {
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.loadSettings();
    state = s;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.saveSettings(state);
  }

  Future<void> setAllowPublicSearch(bool value) async {
    state = state.copyWith(allowPublicSearch: value);
    await _repo.saveSettings(state);
  }

  Future<void> setRequireAuthToViewCard(bool value) async {
    state = state.copyWith(requireAuthToViewCard: value);
    await _repo.saveSettings(state);
  }

  Future<void> setEnableBiometric(bool value) async {
    state = state.copyWith(enableBiometric: value);
    await _repo.saveSettings(state);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

/// Provider trực tiếp cung cấp ThemeMode cho MaterialApp
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider.select((s) => s.themeMode));
});
