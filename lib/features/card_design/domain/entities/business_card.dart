import 'card_design.dart';
import 'social_link.dart';

/// Đại diện cho một Danh thiếp điện tử của người dùng trong hệ thống
class BusinessCard {
  final String id;
  final String ownerId;
  final String cardName;
  final String fullName;
  final String jobTitle;
  final String company;
  final String? bio;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? avatarUrl;
  final String? bannerUrl;
  final CardDesign design;
  final List<SocialLink> socialLinks;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessCard({
    required this.id,
    required this.ownerId,
    required this.cardName,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    this.bio,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.avatarUrl,
    this.bannerUrl,
    required this.design,
    this.socialLinks = const [],
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Tạo một bản sao có chỉnh sửa (immutability)
  BusinessCard copyWith({
    String? id,
    String? ownerId,
    String? cardName,
    String? fullName,
    String? jobTitle,
    String? company,
    String? bio,
    String? phone,
    String? email,
    String? website,
    String? address,
    String? avatarUrl,
    String? bannerUrl,
    CardDesign? design,
    List<SocialLink>? socialLinks,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      cardName: cardName ?? this.cardName,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      design: design ?? this.design,
      socialLinks: socialLinks ?? this.socialLinks,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Danh thiếp mẫu rỗng để bắt đầu tạo mới
  factory BusinessCard.empty({
    required String id,
    required String ownerId,
    String cardName = 'Danh thiếp mới',
    String fullName = '',
  }) {
    final now = DateTime.now();
    return BusinessCard(
      id: id,
      ownerId: ownerId,
      cardName: cardName,
      fullName: fullName,
      jobTitle: '',
      company: '',
      design: CardDesign.initial(),
      socialLinks: const [],
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessCard &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ownerId == other.ownerId &&
          cardName == other.cardName &&
          fullName == other.fullName &&
          jobTitle == other.jobTitle &&
          company == other.company &&
          bio == other.bio &&
          phone == other.phone &&
          email == other.email &&
          website == other.website &&
          address == other.address &&
          avatarUrl == other.avatarUrl &&
          bannerUrl == other.bannerUrl &&
          design == other.design &&
          isDefault == other.isDefault &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      ownerId.hashCode ^
      cardName.hashCode ^
      fullName.hashCode ^
      jobTitle.hashCode ^
      company.hashCode ^
      design.hashCode ^
      isDefault.hashCode;
}
