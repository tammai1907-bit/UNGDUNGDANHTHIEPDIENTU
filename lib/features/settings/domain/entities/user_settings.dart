import 'package:flutter/material.dart';

/// Thực thể lưu cấu hình cá nhân và quyền riêng tư của người dùng
class UserSettings {
  final ThemeMode themeMode;
  final bool allowPublicSearch;
  final bool requireAuthToViewCard;
  final bool enableBiometric;

  const UserSettings({
    this.themeMode = ThemeMode.system,
    this.allowPublicSearch = true,
    this.requireAuthToViewCard = false,
    this.enableBiometric = false,
  });

  UserSettings copyWith({
    ThemeMode? themeMode,
    bool? allowPublicSearch,
    bool? requireAuthToViewCard,
    bool? enableBiometric,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      allowPublicSearch: allowPublicSearch ?? this.allowPublicSearch,
      requireAuthToViewCard: requireAuthToViewCard ?? this.requireAuthToViewCard,
      enableBiometric: enableBiometric ?? this.enableBiometric,
    );
  }
}
