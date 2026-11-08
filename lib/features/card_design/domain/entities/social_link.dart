import 'package:flutter/material.dart';

/// Các loại liên kết mạng xã hội và kênh liên hệ được hỗ trợ
enum SocialLinkType {
  phone,
  sms,
  email,
  zalo,
  facebook,
  linkedin,
  github,
  website;

  String get displayName {
    return switch (this) {
      SocialLinkType.phone => 'Gọi điện (Phone)',
      SocialLinkType.sms => 'Nhắn tin (SMS)',
      SocialLinkType.email => 'Email',
      SocialLinkType.zalo => 'Zalo',
      SocialLinkType.facebook => 'Facebook',
      SocialLinkType.linkedin => 'LinkedIn',
      SocialLinkType.github => 'GitHub',
      SocialLinkType.website => 'Website cá nhân',
    };
  }

  IconData get icon {
    return switch (this) {
      SocialLinkType.phone => Icons.phone_rounded,
      SocialLinkType.sms => Icons.sms_rounded,
      SocialLinkType.email => Icons.email_rounded,
      SocialLinkType.zalo => Icons.chat_bubble_rounded,
      SocialLinkType.facebook => Icons.facebook_rounded,
      SocialLinkType.linkedin => Icons.business_center_rounded,
      SocialLinkType.github => Icons.code_rounded,
      SocialLinkType.website => Icons.language_rounded,
    };
  }

  Color get brandColor {
    return switch (this) {
      SocialLinkType.phone => const Color(0xFF10B981),
      SocialLinkType.sms => const Color(0xFFF59E0B),
      SocialLinkType.email => const Color(0xFFEF4444),
      SocialLinkType.zalo => const Color(0xFF0068FF),
      SocialLinkType.facebook => const Color(0xFF1877F2),
      SocialLinkType.linkedin => const Color(0xFF0A66C2),
      SocialLinkType.github => const Color(0xFF24292F),
      SocialLinkType.website => const Color(0xFF6366F1),
    };
  }

  String get placeholder {
    return switch (this) {
      SocialLinkType.phone => '0901234567 hoặc +84901234567',
      SocialLinkType.sms => '0901234567',
      SocialLinkType.email => 'example@gmail.com',
      SocialLinkType.zalo => 'Số điện thoại Zalo hoặc link zalo.me/id',
      SocialLinkType.facebook => 'username hoặc facebook.com/username',
      SocialLinkType.linkedin => 'username hoặc linkedin.com/in/username',
      SocialLinkType.github => 'username hoặc github.com/username',
      SocialLinkType.website => 'https://mywebsite.com',
    };
  }

  static SocialLinkType fromString(String val) {
    return SocialLinkType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SocialLinkType.website,
    );
  }
}

/// Entity biểu diễn một liên kết mạng xã hội / kênh liên lạc trên danh thiếp
class SocialLink {
  final String id;
  final SocialLinkType type;
  final String value;
  final String? label;
  final int order;
  final bool isVisible;

  const SocialLink({
    required this.id,
    required this.type,
    required this.value,
    this.label,
    required this.order,
    this.isVisible = true,
  });

  SocialLink copyWith({
    String? id,
    SocialLinkType? type,
    String? value,
    String? label,
    int? order,
    bool? isVisible,
  }) {
    return SocialLink(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      label: label ?? this.label,
      order: order ?? this.order,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialLink &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          value == other.value &&
          label == other.label &&
          order == other.order &&
          isVisible == other.isVisible;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      value.hashCode ^
      label.hashCode ^
      order.hashCode ^
      isVisible.hashCode;
}
