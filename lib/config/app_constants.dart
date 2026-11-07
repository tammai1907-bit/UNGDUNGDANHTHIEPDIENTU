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

  static Map<String, dynamic> getThemeColorById(String id) {
    return themeColors.firstWhere(
      (theme) => theme['id'] == id,
      orElse: () => themeColors[0],
    );
  }
}
