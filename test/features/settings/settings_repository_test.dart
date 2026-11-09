import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digital_business_card/features/settings/data/repositories/settings_repository.dart';
import 'package:digital_business_card/features/settings/domain/entities/user_settings.dart';

void main() {
  group('SettingsRepository Tests', () {
    late SettingsRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = SettingsRepository();
    });

    test('Load mặc định khi chưa có dữ liệu lưu', () async {
      final settings = await repository.loadSettings();
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.allowPublicSearch, isTrue);
      expect(settings.requireAuthToViewCard, isFalse);
      expect(settings.enableBiometric, isFalse);
    });

    test('Lưu và đọc lại cài đặt giao diện Dark mode và quyền riêng tư', () async {
      const newSettings = UserSettings(
        themeMode: ThemeMode.dark,
        allowPublicSearch: false,
        requireAuthToViewCard: true,
        enableBiometric: true,
      );

      await repository.saveSettings(newSettings);

      final loaded = await repository.loadSettings();
      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.allowPublicSearch, isFalse);
      expect(loaded.requireAuthToViewCard, isTrue);
      expect(loaded.enableBiometric, isTrue);
    });
  });
}
