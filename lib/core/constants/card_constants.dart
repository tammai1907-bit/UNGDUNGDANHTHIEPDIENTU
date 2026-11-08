import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Các hằng số cấu hình cho phân hệ Thiết kế & Quản lý Danh thiếp (Thành viên 2)
class CardConstants {
  CardConstants._();

  /// Giới hạn tối đa số danh thiếp trên 1 tài khoản
  static const int maxCardsPerUser = 5;

  /// Giới hạn ký tự phần giới thiệu (Bio)
  static const int maxBioLength = 200;

  /// Dung lượng ảnh tối đa trước khi nén: 5MB
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Dung lượng ảnh mục tiêu sau khi nén: 1MB
  static const int targetCompressedSizeBytes = 1 * 1024 * 1024;

  /// Template IDs được hỗ trợ
  static const String templateClassic = 'classic';
  static const String templateModern = 'modern';
  static const String templateMinimal = 'minimal';
  static const String templateCreative = 'creative';

  /// Danh sách template mặc định
  static const List<String> supportedTemplates = [
    templateModern,
    templateClassic,
    templateMinimal,
    templateCreative,
  ];

  /// Danh sách 8 Google Fonts hỗ trợ tiếng Việt
  static const List<String> supportedFonts = [
    'Roboto',
    'Montserrat',
    'Inter',
    'Playfair Display',
    'Poppins',
    'Open Sans',
    'Merriweather',
    'Oswald',
  ];

  /// Hàm lấy TextStyle từ tên Google Font
  static TextStyle getFontStyle(String fontName, {TextStyle? baseStyle}) {
    switch (fontName.toLowerCase()) {
      case 'montserrat':
        return GoogleFonts.montserrat(textStyle: baseStyle);
      case 'inter':
        return GoogleFonts.inter(textStyle: baseStyle);
      case 'playfair display':
        return GoogleFonts.playfairDisplay(textStyle: baseStyle);
      case 'poppins':
        return GoogleFonts.poppins(textStyle: baseStyle);
      case 'open sans':
        return GoogleFonts.openSans(textStyle: baseStyle);
      case 'merriweather':
        return GoogleFonts.merriweather(textStyle: baseStyle);
      case 'oswald':
        return GoogleFonts.oswald(textStyle: baseStyle);
      case 'roboto':
      default:
        return GoogleFonts.roboto(textStyle: baseStyle);
    }
  }

  /// Phân tích mã HEX sang Color an toàn
  static Color parseColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF1E88E5);
    }
  }

  /// Bảng màu gợi ý Material 3
  static const List<SuggestedColor> suggestedPalette = [
    SuggestedColor(name: 'Xanh Lam', hex: '#1E88E5'),
    SuggestedColor(name: 'Xanh Đậm', hex: '#0D47A1'),
    SuggestedColor(name: 'Tím Hoàng Gia', hex: '#6A1B9A'),
    SuggestedColor(name: 'Xanh Lục', hex: '#2E7D32'),
    SuggestedColor(name: 'Cam Hoàng Hôn', hex: '#E65100'),
    SuggestedColor(name: 'Đỏ Ruby', hex: '#C62828'),
    SuggestedColor(name: 'Đen Trầm', hex: '#212121'),
    SuggestedColor(name: 'Trắng Tinh Khôi', hex: '#FFFFFF'),
    SuggestedColor(name: 'Xám Khói', hex: '#ECEFF1'),
    SuggestedColor(name: 'Vàng Kim', hex: '#F9A825'),
  ];

  /// Metadata cho các loại liên kết xã hội
  static SocialMeta getSocialMeta(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'phone':
        return const SocialMeta(name: 'Gọi điện', icon: Icons.phone, placeholder: '0987 654 321');
      case 'sms':
        return const SocialMeta(name: 'Nhắn tin SMS', icon: Icons.sms, placeholder: '0987 654 321');
      case 'email':
        return const SocialMeta(name: 'Email', icon: Icons.email, placeholder: 'name@example.com');
      case 'zalo':
        return const SocialMeta(name: 'Zalo', icon: Icons.chat_bubble_outline, placeholder: '0987654321 hoặc zalo.me/username');
      case 'facebook':
        return const SocialMeta(name: 'Facebook', icon: Icons.facebook, placeholder: 'facebook.com/username');
      case 'linkedin':
        return const SocialMeta(name: 'LinkedIn', icon: Icons.business, placeholder: 'linkedin.com/in/username');
      case 'github':
        return const SocialMeta(name: 'GitHub', icon: Icons.code, placeholder: 'github.com/username');
      case 'website':
      default:
        return const SocialMeta(name: 'Website', icon: Icons.language, placeholder: 'https://example.com');
    }
  }
}

class SuggestedColor {
  final String name;
  final String hex;

  const SuggestedColor({required this.name, required this.hex});
}

class SocialMeta {
  final String name;
  final IconData icon;
  final String placeholder;

  const SocialMeta({
    required this.name,
    required this.icon,
    required this.placeholder,
  });
}
