import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/business_card_model.dart';
import '../config/app_constants.dart';
import '../features/card_design/presentation/widgets/templates/template_registry.dart';
import '../features/card_design/data/models/card_sync_mapper.dart';

class BusinessCardView extends StatelessWidget {
  final BusinessCardModel card;
  final bool isInteractive;
  final Function(String platform)? onSocialClick;

  const BusinessCardView({
    super.key,
    required this.card,
    this.isInteractive = true,
    this.onSocialClick,
  });

  @override
  Widget build(BuildContext context) {
    if (card.template == CardTemplateType.tech) {
      return _buildTechCard(context);
    }

    try {
      final domainCard = CardSyncMapper.toDomain(card);
      return TemplateRegistry.buildCard(
        card: domainCard,
        isInteractive: isInteractive,
      );
    } catch (_) {
      switch (card.template) {
        case CardTemplateType.minimalist:
          return _buildMinimalistCard(context);
        case CardTemplateType.elegant:
          return _buildElegantCard(context);
        case CardTemplateType.tech:
          return _buildTechCard(context);
        case CardTemplateType.creative:
          return _buildCreativeCard(context);
        case CardTemplateType.modern:
          return _buildModernCard(context);
      }
    }
  }

  // ================= 1. TEMPLATE: MODERN ================= //
  Widget _buildModernCard(BuildContext context) {
    final themeData = AppConstants.getThemeColorById(card.themeColorId);
    final Color primary = themeData['primary'] as Color;
    final Color secondary = themeData['secondary'] as Color;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative shapes
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Avatar & Company Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAvatar(radius: 32, border: Border.all(color: Colors.white, width: 2.5)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.company.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            card.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            card.jobTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 16),

                // Contact details
                _buildContactInfoRow(
                  icon: Icons.phone_android,
                  text: card.isPrivatePhone ? '••• ••• •••• (Đã ẩn bảo mật)' : card.phone,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 8),
                _buildContactInfoRow(
                  icon: Icons.email_outlined,
                  text: card.isPrivateEmail ? '••••••••@•••.com (Đã ẩn bảo mật)' : card.email,
                  textColor: Colors.white,
                ),
                if (card.website.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildContactInfoRow(
                    icon: Icons.language,
                    text: card.website,
                    textColor: Colors.white,
                  ),
                ],
                if (card.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildContactInfoRow(
                    icon: Icons.location_on_outlined,
                    text: card.address,
                    textColor: Colors.white.withValues(alpha: 0.9),
                  ),
                ],

                // Social Media Buttons
                if (card.socialLinks.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildSocialLinksBar(iconColor: Colors.white, bgColor: Colors.white.withValues(alpha: 0.18)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 2. TEMPLATE: MINIMALIST ================= //
  Widget _buildMinimalistCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildAvatar(radius: 28, border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      card.jobTitle,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      card.company,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          _buildContactInfoRow(
            icon: Icons.phone_outlined,
            text: card.isPrivatePhone ? '••• ••• ••••' : card.phone,
            textColor: const Color(0xFF334155),
            iconColor: const Color(0xFF64748B),
          ),
          const SizedBox(height: 8),
          _buildContactInfoRow(
            icon: Icons.alternate_email,
            text: card.isPrivateEmail ? '••••••••@•••' : card.email,
            textColor: const Color(0xFF334155),
            iconColor: const Color(0xFF64748B),
          ),
          if (card.website.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildContactInfoRow(
              icon: Icons.link,
              text: card.website,
              textColor: const Color(0xFF2563EB),
              iconColor: const Color(0xFF2563EB),
            ),
          ],
          if (card.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSocialLinksBar(
              iconColor: const Color(0xFF334155),
              bgColor: const Color(0xFFF1F5F9),
            ),
          ],
        ],
      ),
    );
  }

  // ================= 3. TEMPLATE: ELEGANT ================= //
  Widget _buildElegantCard(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const darkBg = Color(0xFF18181B);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(radius: 30, border: Border.all(color: goldColor, width: 2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.company.toUpperCase(),
                      style: const TextStyle(
                        color: goldColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        color: Color(0xFFF4F4F5),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'serif',
                      ),
                    ),
                    Text(
                      card.jobTitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.workspace_premium, color: goldColor, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: goldColor.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 14),
          _buildContactInfoRow(
            icon: Icons.phone_android,
            text: card.isPrivatePhone ? '••• ••• •••• (Riêng tư)' : card.phone,
            textColor: const Color(0xFFE4E4E7),
            iconColor: goldColor,
          ),
          const SizedBox(height: 8),
          _buildContactInfoRow(
            icon: Icons.mail_outline,
            text: card.isPrivateEmail ? '••••••••@•••' : card.email,
            textColor: const Color(0xFFE4E4E7),
            iconColor: goldColor,
          ),
          if (card.website.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildContactInfoRow(
              icon: Icons.public,
              text: card.website,
              textColor: goldColor,
              iconColor: goldColor,
            ),
          ],
          if (card.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSocialLinksBar(iconColor: goldColor, bgColor: const Color(0xFF27272A)),
          ],
        ],
      ),
    );
  }

  // ================= 4. TEMPLATE: CYBER TECH ================= //
  Widget _buildTechCard(BuildContext context) {
    const neonCyan = Color(0xFF00F5FF);
    const neonGreen = Color(0xFF00FF66);
    const techBg = Color(0xFF0B0F19);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: techBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonCyan.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: neonCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '// DEV_ID: 0x7F',
                  style: TextStyle(color: neonCyan, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Icon(Icons.code, color: neonGreen, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildAvatar(radius: 28, border: Border.all(color: neonGreen, width: 2)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '> ${card.jobTitle}',
                      style: const TextStyle(
                        color: neonCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '@${card.company}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactInfoRow(
            icon: Icons.terminal,
            text: card.isPrivatePhone ? 'tel:[ENCRYPTED]' : 'tel:${card.phone}',
            textColor: const Color(0xFF94A3B8),
            iconColor: neonGreen,
            fontFamily: 'monospace',
          ),
          const SizedBox(height: 6),
          _buildContactInfoRow(
            icon: Icons.alternate_email,
            text: card.isPrivateEmail ? 'email:[ENCRYPTED]' : card.email,
            textColor: const Color(0xFF94A3B8),
            iconColor: neonCyan,
            fontFamily: 'monospace',
          ),
          if (card.skills.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: card.skills.take(4).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    '#$s',
                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontFamily: 'monospace'),
                  ),
                );
              }).toList(),
            ),
          ],
          if (card.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildSocialLinksBar(iconColor: neonCyan, bgColor: Colors.white.withValues(alpha: 0.08)),
          ],
        ],
      ),
    );
  }

  // ================= 5. TEMPLATE: CREATIVE ================= //
  Widget _buildCreativeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF007A), Color(0xFF7928CA), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF007A).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildAvatar(radius: 30, border: Border.all(color: Colors.white, width: 2.5)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      card.jobTitle,
                      style: const TextStyle(
                        color: Color(0xFFFFE4E6),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      card.company,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.palette_outlined, color: Colors.white, size: 26),
            ],
          ),
          if (card.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '"${card.bio}"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 12),
          _buildContactInfoRow(
            icon: Icons.phone,
            text: card.isPrivatePhone ? '••• ••• ••••' : card.phone,
            textColor: Colors.white,
          ),
          const SizedBox(height: 6),
          _buildContactInfoRow(
            icon: Icons.mail,
            text: card.isPrivateEmail ? '••••••••@•••' : card.email,
            textColor: Colors.white,
          ),
          if (card.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSocialLinksBar(iconColor: Colors.white, bgColor: Colors.white.withValues(alpha: 0.2)),
          ],
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS ================= //
  Widget _buildAvatar({required double radius, BoxBorder? border}) {
    ImageProvider? imageProvider;
    final url = card.avatarUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        imageProvider = CachedNetworkImageProvider(url);
      } else {
        final filePath = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
        final file = File(filePath);
        if (file.existsSync()) {
          imageProvider = FileImage(file);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white.withValues(alpha: 0.25),
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                _getAvatarInitial(card.fullName),
                style: TextStyle(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  String _getAvatarInitial(String fullName) {
    final clean = fullName.trim();
    if (clean.isEmpty) return 'T';
    final parts = clean.split(RegExp(r'\s+'));
    return parts.last.isNotEmpty ? parts.last[0].toUpperCase() : clean[0].toUpperCase();
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required String text,
    required Color textColor,
    Color? iconColor,
    String? fontFamily,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? textColor.withValues(alpha: 0.85)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLinksBar({required Color iconColor, required Color bgColor}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: card.socialLinks.entries.map((entry) {
        final platform = entry.key;
        final url = entry.value;
        if (url.isEmpty) return const SizedBox.shrink();

        IconData iconData = Icons.link;
        switch (platform.toLowerCase()) {
          case 'linkedin':
            iconData = Icons.business_center;
            break;
          case 'facebook':
            iconData = Icons.facebook;
            break;
          case 'github':
            iconData = Icons.code;
            break;
          case 'twitter':
          case 'x':
            iconData = Icons.alternate_email;
            break;
          case 'zalo':
            iconData = Icons.chat_bubble_outline;
            break;
          case 'instagram':
            iconData = Icons.camera_alt_outlined;
            break;
        }

        return InkWell(
          onTap: isInteractive
              ? () async {
                  onSocialClick?.call(platform);
                  final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconData, size: 14, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  platform.toUpperCase(),
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
