import 'dart:convert';
import 'package:flutter/material.dart';

enum CardTemplateType {
  modern,
  minimalist,
  elegant,
  tech,
  creative,
}

extension CardTemplateTypeExtension on CardTemplateType {
  String get displayName {
    switch (this) {
      case CardTemplateType.modern:
        return 'Hiện Đại (Modern)';
      case CardTemplateType.minimalist:
        return 'Tối Giản (Minimalist)';
      case CardTemplateType.elegant:
        return 'Sang Trọng (Elegant)';
      case CardTemplateType.tech:
        return 'Công Nghệ (Cyber Tech)';
      case CardTemplateType.creative:
        return 'Sáng Tạo (Creative)';
    }
  }

  IconData get icon {
    switch (this) {
      case CardTemplateType.modern:
        return Icons.auto_awesome;
      case CardTemplateType.minimalist:
        return Icons.crop_portrait;
      case CardTemplateType.elegant:
        return Icons.workspace_premium;
      case CardTemplateType.tech:
        return Icons.terminal;
      case CardTemplateType.creative:
        return Icons.palette;
    }
  }
}

class AppConstants {
  /// Domain cấu hình duy nhất dùng cho liên kết danh thiếp trực tuyến và mã QR
  static const String cardBaseDomain = 'https://card.antigravity.dev';

  /// Sinh đường dẫn xem danh thiếp công khai theo chuẩn: `https://<domain>/c/{ownerId}/{cardId}`
  static String buildCardShareUrl({required String ownerId, required String cardId}) {
    return '$cardBaseDomain/c/$ownerId/$cardId';
  }

  static const List<String> defaultTags = [
    'Khách hàng',
    'Đối tác',
    'Đồng nghiệp',
    'Bạn bè',
    'Hội thảo',
    'VIP',
  ];

  static const List<Map<String, dynamic>> themeColors = [
    {
      'id': 'navy_blue',
      'name': 'Xanh Doanh Nghiệp',
      'primary': Color(0xFF1E3A8A),
      'secondary': Color(0xFF3B82F6),
      'textColor': Colors.white,
    },
    {
      'id': 'emerald',
      'name': 'Ngọc Lục Bảo',
      'primary': Color(0xFF065F46),
      'secondary': Color(0xFF10B981),
      'textColor': Colors.white,
    },
    {
      'id': 'royal_purple',
      'name': 'Tím Hoàng Gia',
      'primary': Color(0xFF4C1D95),
      'secondary': Color(0xFF8B5CF6),
      'textColor': Colors.white,
    },
    {
      'id': 'ruby_red',
      'name': 'Đỏ Ruby',
      'primary': Color(0xFF881337),
      'secondary': Color(0xFFE11D48),
      'textColor': Colors.white,
    },
    {
      'id': 'sunset_orange',
      'name': 'Cam Hoàng Hôn',
      'primary': Color(0xFF9A3412),
      'secondary': Color(0xFFF97316),
      'textColor': Colors.white,
    },
    {
      'id': 'midnight_dark',
      'name': 'Đen Huyền Bí',
      'primary': Color(0xFF111827),
      'secondary': Color(0xFF374151),
      'textColor': Colors.white,
    },
    {
      'id': 'gold_luxury',
      'name': 'Vàng Gold Sang Trọng',
      'primary': Color(0xFF262626),
      'secondary': Color(0xFFD97706),
      'textColor': Color(0xFFFEF3C7),
    },
  ];

  static Color _parseHexColor(String hex) {
    String cleanHex = hex.replaceAll('#', '').trim();
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    return Color(int.parse(cleanHex, radix: 16));
  }

  static Color _generateSecondaryColor(Color primary) {
    final hsl = HSLColor.fromColor(primary);
    final newHue = (hsl.hue + 25) % 360;
    final newLightness = (hsl.lightness > 0.5) ? hsl.lightness - 0.15 : hsl.lightness + 0.15;
    return hsl.withHue(newHue).withLightness(newLightness.clamp(0.0, 1.0)).toColor();
  }

  static Map<String, dynamic> getThemeColorById(String id) {
    // 1. Kiểm tra ID màu có sẵn (navy_blue, emerald, ...)
    final found = themeColors.where((theme) => theme['id'] == id);
    if (found.isNotEmpty) {
      return found.first;
    }

    // 2. Nếu id là JSON cấu hình thiết kế từ Member 2 (chứa primary, secondary, text...)
    if (id.startsWith('{')) {
      try {
        final map = jsonDecode(id) as Map<String, dynamic>;
        final p = _parseHexColor(map['primary'] as String? ?? '#1E3A8A');
        final s = map['secondary'] != null
            ? _parseHexColor(map['secondary'] as String)
            : _generateSecondaryColor(p);
        final textColor = map['text'] != null
            ? _parseHexColor(map['text'] as String)
            : (ThemeData.estimateBrightnessForColor(p) == Brightness.dark ? Colors.white : const Color(0xFF0F172A));
        return {
          'id': id,
          'name': 'Màu tùy chỉnh',
          'primary': p,
          'secondary': s,
          'textColor': textColor,
        };
      } catch (_) {}
    }

    // 3. Nếu id là mã HEX đơn hoặc cặp HEX (vd: "#8BC34A" hoặc "#8BC34A_#3B82F6")
    if (id.startsWith('#')) {
      try {
        final parts = id.split('_');
        final primaryColor = _parseHexColor(parts[0]);
        final secondaryColor = parts.length > 1
            ? _parseHexColor(parts[1])
            : _generateSecondaryColor(primaryColor);

        return {
          'id': id,
          'name': 'Màu tùy chỉnh',
          'primary': primaryColor,
          'secondary': secondaryColor,
          'textColor': ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
              ? Colors.white
              : const Color(0xFF0F172A),
        };
      } catch (_) {}
    }

    return themeColors[0];
  }
}
