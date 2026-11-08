import 'package:flutter/material.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';
import 'template_base.dart';

/// Mẫu danh thiếp Sáng tạo (Creative Vibrant Gradient)
class TemplateCreative extends StatelessWidget {
  final BusinessCard card;
  final bool isInteractive;

  const TemplateCreative({
    super.key,
    required this.card,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    final d = card.design;
    final primaryColor = d.primaryColor;
    final secondaryColor = d.secondaryColor;
    final fontStyle = CardConstants.getFontStyle(d.fontFamily);

    // Để đảm bảo tính nghệ thuật & tương phản, template này dùng text sáng màu trên nền gradient
    const contentColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(d.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Vòng tròn trang trí mờ nghệ thuật phía sau
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar với viền phát sáng nhẹ
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: buildCardImage(
                          imageUrl: card.avatarUrl,
                          width: 64,
                          height: 64,
                          placeholder: Container(
                            color: Colors.white.withValues(alpha: 0.2),
                            child: Center(
                              child: Text(
                                card.fullName.isNotEmpty
                                    ? card.fullName[0].toUpperCase()
                                    : 'A',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                              fontWeight: FontWeight.w800,
                              color: contentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.jobTitle.isNotEmpty ? card.jobTitle : 'Nghệ danh / Chức danh',
                            style: fontStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: contentColor.withValues(alpha: 0.9),
                            ),
                          ),
                          Text(
                            card.company.isNotEmpty ? card.company : 'Studio / Agency',
                            style: fontStyle.copyWith(
                              fontSize: 11,
                              color: contentColor.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (card.bio != null && card.bio!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      card.bio!,
                      style: fontStyle.copyWith(
                        fontSize: 12,
                        color: contentColor.withValues(alpha: 0.95),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Danh sách liên hệ frosted glass
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (card.phone != null && card.phone!.isNotEmpty)
                      _buildCreativePill(Icons.phone_rounded, card.phone!),
                    if (card.email != null && card.email!.isNotEmpty)
                      _buildCreativePill(Icons.email_rounded, card.email!),
                    if (card.website != null && card.website!.isNotEmpty)
                      _buildCreativePill(Icons.link_rounded, card.website!),
                    if (card.address != null && card.address!.isNotEmpty)
                      _buildCreativePill(Icons.place_rounded, card.address!),
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
                            primaryColor: Colors.white,
                            textColor: Colors.white,
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

  Widget _buildCreativePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
