import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../config/app_constants.dart';
import '../../../../models/business_card_model.dart';
import '../../domain/entities/business_card.dart';
import '../../domain/entities/card_design.dart';
import '../../domain/entities/social_link.dart';

/// Tiện ích chuyển đổi đồng bộ giữa BusinessCard (Phân hệ Thiết kế) và BusinessCardModel (SQLite Database)
class CardSyncMapper {
  /// Chuyển từ BusinessCard (Member 2) sang BusinessCardModel (SQLite DB)
  static BusinessCardModel toModel(BusinessCard card) {
    CardTemplateType templateType;
    switch (card.design.templateId) {
      case 'classic':
        templateType = CardTemplateType.elegant;
        break;
      case 'minimal':
        templateType = CardTemplateType.minimalist;
        break;
      case 'creative':
        templateType = CardTemplateType.creative;
        break;
      case 'modern':
      default:
        templateType = CardTemplateType.modern;
        break;
    }

    final socialMap = <String, String>{};
    for (final l in card.socialLinks) {
      if (l.isVisible && l.value.isNotEmpty) {
        socialMap[l.type.name] = l.value;
      }
    }

    // Mã hóa cấu hình thiết kế đầy đủ (Màu sắc, font, banner, radius) vào themeColorId
    final designJson = jsonEncode({
      'primary': card.design.primaryColorHex,
      'secondary': card.design.secondaryColorHex,
      'bg': card.design.backgroundColorHex,
      'text': card.design.textColorHex,
      'font': card.design.fontFamily,
      'radius': card.design.cornerRadius,
      'banner': card.design.showBanner,
    });

    return BusinessCardModel(
      id: card.id,
      userId: card.ownerId,
      cardName: card.cardName,
      fullName: card.fullName,
      jobTitle: card.jobTitle,
      company: card.company,
      phone: card.phone ?? '',
      email: card.email ?? '',
      website: card.website ?? '',
      address: card.address ?? '',
      bio: card.bio ?? '',
      avatarUrl: card.avatarUrl,
      coverUrl: card.bannerUrl,
      socialLinks: socialMap,
      template: templateType,
      themeColorId: designJson,
      isDefault: card.isDefault,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
    );
  }

  /// Chuyển từ BusinessCardModel (SQLite DB) sang BusinessCard (Member 2)
  static BusinessCard toDomain(BusinessCardModel model) {
    String templateId;
    switch (model.template) {
      case CardTemplateType.elegant:
        templateId = 'classic';
        break;
      case CardTemplateType.minimalist:
        templateId = 'minimal';
        break;
      case CardTemplateType.creative:
        templateId = 'creative';
        break;
      case CardTemplateType.modern:
      default:
        templateId = 'modern';
        break;
    }

    final links = <SocialLink>[];
    int order = 0;
    model.socialLinks.forEach((platform, val) {
      links.add(
        SocialLink(
          id: 'link_${platform}_${model.id}',
          type: SocialLinkType.fromString(platform),
          value: val,
          label: platform[0].toUpperCase() + platform.substring(1),
          order: order++,
          isVisible: true,
        ),
      );
    });

    CardDesign design;
    try {
      if (model.themeColorId.startsWith('{')) {
        final map = jsonDecode(model.themeColorId) as Map<String, dynamic>;
        design = CardDesign.fromHex(
          templateId: templateId,
          primaryColorHex: map['primary'] as String? ?? '#1E3A8A',
          secondaryColorHex: map['secondary'] as String? ?? '#3B82F6',
          backgroundColorHex: map['bg'] as String? ?? '#FFFFFF',
          textColorHex: map['text'] as String? ?? '#0F172A',
          fontFamily: map['font'] as String? ?? 'Roboto',
          cornerRadius: (map['radius'] as num?)?.toDouble() ?? 20.0,
          showBanner: map['banner'] as bool? ?? true,
        );
      } else if (model.themeColorId.startsWith('#')) {
        final parts = model.themeColorId.split('_');
        design = CardDesign.fromHex(
          templateId: templateId,
          primaryColorHex: parts[0],
          secondaryColorHex: parts.length > 1 ? parts[1] : '#3B82F6',
        );
      } else {
        final theme = AppConstants.getThemeColorById(model.themeColorId);
        design = CardDesign(
          templateId: templateId,
          primaryColor: theme['primary'] as Color,
          secondaryColor: theme['secondary'] as Color,
        );
      }
    } catch (_) {
      design = CardDesign.fromHex(templateId: templateId);
    }

    return BusinessCard(
      id: model.id,
      ownerId: model.userId,
      cardName: model.cardName,
      fullName: model.fullName,
      jobTitle: model.jobTitle,
      company: model.company,
      phone: model.phone.isNotEmpty ? model.phone : null,
      email: model.email.isNotEmpty ? model.email : null,
      website: model.website.isNotEmpty ? model.website : null,
      address: model.address.isNotEmpty ? model.address : null,
      bio: model.bio.isNotEmpty ? model.bio : null,
      avatarUrl: model.avatarUrl,
      bannerUrl: model.coverUrl,
      design: design,
      socialLinks: links,
      isDefault: model.isDefault,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
