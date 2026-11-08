import 'package:flutter/material.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'template_base.dart';

/// Mẫu danh thiếp Tối giản (Minimalist & Typographic)
class TemplateMinimal extends StatelessWidget {
  final BusinessCard card;
  final bool isInteractive;

  const TemplateMinimal({
    super.key,
    required this.card,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final d = card.design;
    final primaryColor = d.primaryColor;
    final bgColor = d.backgroundColor;
    final textColor = d.textColor;
    final fontStyle = CardConstants.getFontStyle(d.fontFamily);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(d.cornerRadius),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar khối bo tròn nhẹ
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: textColor.withValues(alpha: 0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: buildCardImage(
                    imageUrl: card.avatarUrl,
                    width: 56,
                    height: 56,
                    placeholder: Container(
                      color: textColor.withValues(alpha: 0.05),
                      child: Center(
                        child: Text(
                          card.fullName.isNotEmpty
                              ? card.fullName[0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName.isNotEmpty ? card.fullName : 'Họ và Tên',
                      style: fontStyle.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.jobTitle.isNotEmpty ? card.jobTitle : 'Chức danh',
                      style: fontStyle.copyWith(
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      card.company.isNotEmpty ? card.company : 'Công ty',
                      style: fontStyle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (card.bio != null && card.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: primaryColor, width: 2),
                ),
              ),
              child: Text(
                card.bio!,
                style: fontStyle.copyWith(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: textColor.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 18),
          Container(height: 0.5, color: textColor.withValues(alpha: 0.15)),
          const SizedBox(height: 14),

          // Contacts
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (card.phone != null && card.phone!.isNotEmpty)
                _buildMinimalContact(Icons.phone_outlined, card.phone!, textColor),
              if (card.email != null && card.email!.isNotEmpty)
                _buildMinimalContact(Icons.email_outlined, card.email!, textColor),
              if (card.website != null && card.website!.isNotEmpty)
                _buildMinimalContact(Icons.link_rounded, card.website!, textColor),
              if (card.address != null && card.address!.isNotEmpty)
                _buildMinimalContact(Icons.place_outlined, card.address!, textColor),
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
                      compact: true,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMinimalContact(IconData icon, String text, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
