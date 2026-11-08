import 'package:flutter/material.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'template_base.dart';

/// Mẫu danh thiếp Cổ điển (Classic Corporate)
class TemplateClassic extends StatelessWidget {
  final BusinessCard card;
  final bool isInteractive;

  const TemplateClassic({
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dải màu trang trí phía trên
          Container(
            height: 8,
            color: primaryColor,
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2.5),
                      ),
                      child: ClipOval(
                        child: buildCardImage(
                          imageUrl: card.avatarUrl,
                          width: 68,
                          height: 68,
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
                    const SizedBox(width: 16),

                    // Tên, chức danh, công ty
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.fullName.isNotEmpty ? card.fullName : 'Họ và Tên',
                            style: fontStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            card.jobTitle.isNotEmpty ? card.jobTitle : 'Chức vụ / Nghề nghiệp',
                            style: fontStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            card.company.isNotEmpty ? card.company : 'Tên Công ty / Doanh nghiệp',
                            style: fontStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (card.bio != null && card.bio!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    card.bio!,
                    style: fontStyle.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: textColor.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Divider(color: Colors.grey.withValues(alpha: 0.25), height: 1),
                const SizedBox(height: 12),

                // Danh sách liên hệ
                if (card.phone != null && card.phone!.isNotEmpty)
                  _buildContactRow(
                    Icons.phone_rounded,
                    card.phone!,
                    textColor,
                    primaryColor,
                  ),
                if (card.email != null && card.email!.isNotEmpty)
                  _buildContactRow(
                    Icons.email_rounded,
                    card.email!,
                    textColor,
                    primaryColor,
                  ),
                if (card.website != null && card.website!.isNotEmpty)
                  _buildContactRow(
                    Icons.language_rounded,
                    card.website!,
                    textColor,
                    primaryColor,
                  ),
                if (card.address != null && card.address!.isNotEmpty)
                  _buildContactRow(
                    Icons.location_on_rounded,
                    card.address!,
                    textColor,
                    primaryColor,
                  ),

                // Social Links
                if (card.socialLinks.any((l) => l.isVisible)) ...[
                  const SizedBox(height: 12),
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
                            compact: true,
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

  Widget _buildContactRow(
    IconData icon,
    String text,
    Color textColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
