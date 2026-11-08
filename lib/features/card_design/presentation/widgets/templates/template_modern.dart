import 'package:flutter/material.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'template_base.dart';

/// Mẫu danh thiếp Hiện đại (Modern Banner & Floating Avatar)
class TemplateModern extends StatelessWidget {
  final BusinessCard card;
  final bool isInteractive;

  const TemplateModern({
    super.key,
    required this.card,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final d = card.design;
    final primaryColor = d.primaryColor;
    final secondaryColor = d.secondaryColor;
    final bgColor = d.backgroundColor;
    final textColor = d.textColor;
    final fontStyle = CardConstants.getFontStyle(d.fontFamily);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(d.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner phần trên
          if (d.showBanner)
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 95,
                  width: double.infinity,
                  child: card.bannerUrl != null && card.bannerUrl!.isNotEmpty
                      ? buildCardImage(
                          imageUrl: card.bannerUrl,
                          width: double.infinity,
                          height: 95,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                ),
                // Vị trí avatar nổi đè lên mép banner
                Positioned(
                  left: 20,
                  bottom: -32,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                      border: Border.all(color: bgColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: buildCardImage(
                        imageUrl: card.avatarUrl,
                        width: 66,
                        height: 66,
                        placeholder: Container(
                          color: primaryColor.withValues(alpha: 0.15),
                          child: Center(
                            child: Text(
                              card.fullName.isNotEmpty
                                  ? card.fullName[0].toUpperCase()
                                  : 'A',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: EdgeInsets.fromLTRB(20, d.showBanner ? 38 : 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên & Chức danh
                Text(
                  card.fullName.isNotEmpty ? card.fullName : 'Họ và Tên',
                  style: fontStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        card.jobTitle.isNotEmpty ? card.jobTitle : 'Chức vụ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.company.isNotEmpty ? card.company : 'Công ty',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (card.bio != null && card.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    card.bio!,
                    style: fontStyle.copyWith(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Quick Contacts Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (card.phone != null && card.phone!.isNotEmpty)
                      _buildInfoPill(Icons.phone_rounded, card.phone!, textColor, primaryColor),
                    if (card.email != null && card.email!.isNotEmpty)
                      _buildInfoPill(Icons.email_rounded, card.email!, textColor, primaryColor),
                    if (card.website != null && card.website!.isNotEmpty)
                      _buildInfoPill(Icons.language_rounded, card.website!, textColor, primaryColor),
                    if (card.address != null && card.address!.isNotEmpty)
                      _buildInfoPill(Icons.place_rounded, card.address!, textColor, primaryColor),
                  ],
                ),

                // Social Links
                if (card.socialLinks.any((l) => l.isVisible)) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: card.socialLinks
                        .where((l) => l.isVisible)
                        .map(
                          (link) => buildSocialActionChip(
                            context: context,
                            link: link,
                            primaryColor: primaryColor,
                            textColor: textColor,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color textColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: primaryColor),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.85)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
