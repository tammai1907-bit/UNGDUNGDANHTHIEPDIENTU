import 'package:flutter/material.dart';
import '../../../../core/constants/card_constants.dart';

/// Cấu hình giao diện và thiết kế của một danh thiếp
class CardDesign {
  final String templateId;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final double cornerRadius;
  final bool showBanner;

  const CardDesign({
    this.templateId = CardConstants.templateModern,
    this.primaryColor = const Color(0xFF1E3A8A),
    this.secondaryColor = const Color(0xFF3B82F6),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF0F172A),
    this.fontFamily = 'Roboto',
    this.cornerRadius = 20.0,
    this.showBanner = true,
  });

  /// Khởi tạo từ mã màu HEX
  factory CardDesign.fromHex({
    String templateId = CardConstants.templateModern,
    String primaryColorHex = '#1E3A8A',
    String secondaryColorHex = '#3B82F6',
    String backgroundColorHex = '#FFFFFF',
    String textColorHex = '#0F172A',
    String fontFamily = 'Roboto',
    double cornerRadius = 20.0,
    bool showBanner = true,
  }) {
    return CardDesign(
      templateId: templateId,
      primaryColor: CardConstants.parseColor(primaryColorHex),
      secondaryColor: CardConstants.parseColor(secondaryColorHex),
      backgroundColor: CardConstants.parseColor(backgroundColorHex),
      textColor: CardConstants.parseColor(textColorHex),
      fontFamily: fontFamily,
      cornerRadius: cornerRadius,
      showBanner: showBanner,
    );
  }

  /// Cấu hình mặc định / khởi tạo
  factory CardDesign.initial() => const CardDesign();
  factory CardDesign.defaultDesign() => const CardDesign();

  String get primaryColorHex =>
      '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  String get secondaryColorHex =>
      '#${secondaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  String get backgroundColorHex =>
      '#${backgroundColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  String get textColorHex =>
      '#${textColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  CardDesign copyWith({
    String? templateId,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    String? primaryColorHex,
    String? secondaryColorHex,
    String? backgroundColorHex,
    String? textColorHex,
    String? fontFamily,
    double? cornerRadius,
    bool? showBanner,
  }) {
    return CardDesign(
      templateId: templateId ?? this.templateId,
      primaryColor: primaryColorHex != null
          ? CardConstants.parseColor(primaryColorHex)
          : (primaryColor ?? this.primaryColor),
      secondaryColor: secondaryColorHex != null
          ? CardConstants.parseColor(secondaryColorHex)
          : (secondaryColor ?? this.secondaryColor),
      backgroundColor: backgroundColorHex != null
          ? CardConstants.parseColor(backgroundColorHex)
          : (backgroundColor ?? this.backgroundColor),
      textColor: textColorHex != null
          ? CardConstants.parseColor(textColorHex)
          : (textColor ?? this.textColor),
      fontFamily: fontFamily ?? this.fontFamily,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      showBanner: showBanner ?? this.showBanner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardDesign &&
          runtimeType == other.runtimeType &&
          templateId == other.templateId &&
          primaryColor.toARGB32() == other.primaryColor.toARGB32() &&
          secondaryColor.toARGB32() == other.secondaryColor.toARGB32() &&
          backgroundColor.toARGB32() == other.backgroundColor.toARGB32() &&
          textColor.toARGB32() == other.textColor.toARGB32() &&
          fontFamily == other.fontFamily &&
          cornerRadius == other.cornerRadius &&
          showBanner == other.showBanner;

  @override
  int get hashCode =>
      templateId.hashCode ^
      primaryColor.toARGB32().hashCode ^
      secondaryColor.toARGB32().hashCode ^
      backgroundColor.toARGB32().hashCode ^
      textColor.toARGB32().hashCode ^
      fontFamily.hashCode ^
      cornerRadius.hashCode ^
      showBanner.hashCode;
}
