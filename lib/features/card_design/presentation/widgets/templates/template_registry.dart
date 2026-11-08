import 'package:flutter/material.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'template_classic.dart';
import 'template_modern.dart';
import 'template_minimal.dart';
import 'template_creative.dart';

/// Chứa thông tin mô tả và hàm khởi tạo của một mẫu danh thiếp
class TemplateInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Widget Function(BusinessCard card, {bool isInteractive}) builder;

  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.builder,
  });
}

/// Sổ bộ đăng ký danh mục các mẫu giao diện (Template Registry)
class TemplateRegistry {
  TemplateRegistry._();

  static final List<TemplateInfo> _templates = [
    TemplateInfo(
      id: 'modern',
      name: 'Hiện Đại',
      description: 'Ảnh bìa banner ấn tượng, avatar nổi và bố cục thẻ tinh tế',
      icon: Icons.dashboard_customize_rounded,
      builder: (card, {isInteractive = true}) =>
          TemplateModern(card: card, isInteractive: isInteractive),
    ),
    TemplateInfo(
      id: 'classic',
      name: 'Cổ Điển',
      description: 'Phong cách doanh nghiệp chỉn chu, trang trọng và chuyên nghiệp',
      icon: Icons.business_center_rounded,
      builder: (card, {isInteractive = true}) =>
          TemplateClassic(card: card, isInteractive: isInteractive),
    ),
    TemplateInfo(
      id: 'minimal',
      name: 'Tối Giản',
      description: 'Tập trung vào kiểu chữ thanh lịch, tinh giản và khoảng trắng thông thoáng',
      icon: Icons.border_clear_rounded,
      builder: (card, {isInteractive = true}) =>
          TemplateMinimal(card: card, isInteractive: isInteractive),
    ),
    TemplateInfo(
      id: 'creative',
      name: 'Sáng Tạo',
      description: 'Nền gradient rực rỡ, hiệu ứng kính mờ và phong cách cá tính',
      icon: Icons.auto_awesome_rounded,
      builder: (card, {isInteractive = true}) =>
          TemplateCreative(card: card, isInteractive: isInteractive),
    ),
  ];

  /// Lấy toàn bộ danh sách template đang có trong ứng dụng
  static List<TemplateInfo> getAll() => List.unmodifiable(_templates);

  /// Lấy template theo ID (mặc định fallback về modern nếu không tìm thấy)
  static TemplateInfo getById(String id) {
    return _templates.firstWhere(
      (t) => t.id == id,
      orElse: () => _templates.first,
    );
  }

  /// Dựng widget thẻ tương ứng với template được chọn trong card.design
  static Widget buildCard({
    required BusinessCard card,
    bool isInteractive = true,
  }) {
    final info = getById(card.design.templateId);
    return info.builder(card, isInteractive: isInteractive);
  }
}
