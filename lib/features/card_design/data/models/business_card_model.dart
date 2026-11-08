import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/business_card.dart';
import 'card_design_model.dart';
import 'social_link_model.dart';

/// Extension model hỗ trợ chuyển đổi BusinessCard sang Firestore Document / JSON Map
extension BusinessCardModelMapper on BusinessCard {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'cardName': cardName,
      'fullName': fullName,
      'jobTitle': jobTitle,
      'company': company,
      'bio': bio,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'design': design.toMap(),
      'socialLinks': socialLinks.map((link) => link.toMap()).toList(),
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static BusinessCard fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final rawLinks = map['socialLinks'] as List<dynamic>? ?? [];
    final links = rawLinks
        .map((l) => SocialLinkModel.fromMap(Map<String, dynamic>.from(l as Map)))
        .toList();

    final designMap = map['design'] is Map
        ? Map<String, dynamic>.from(map['design'] as Map)
        : <String, dynamic>{};

    return BusinessCard(
      id: (docId != null && docId.isNotEmpty) ? docId : (map['id'] as String? ?? ''),
      ownerId: map['ownerId'] as String? ?? '',
      cardName: map['cardName'] as String? ?? 'Danh thiếp',
      fullName: map['fullName'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      company: map['company'] as String? ?? '',
      bio: map['bio'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      address: map['address'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      bannerUrl: map['bannerUrl'] as String?,
      design: CardDesignModel.fromMap(designMap),
      socialLinks: links,
      isDefault: map['isDefault'] as bool? ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}
