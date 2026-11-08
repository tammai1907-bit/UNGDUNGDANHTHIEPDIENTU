import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:digital_business_card/features/card_design/domain/entities/social_link.dart';
import 'package:digital_business_card/core/constants/card_constants.dart';

/// Helper chung cho việc hiển thị ảnh (hỗ trợ cả Network URL, Local File và Fallback)
Widget buildCardImage({
  required String? imageUrl,
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  Widget? placeholder,
}) {
  Widget imageWidget;

  if (imageUrl == null || imageUrl.isEmpty) {
    imageWidget = placeholder ?? Container(color: Colors.grey.shade300);
  } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) =>
          placeholder ?? Container(color: Colors.grey.shade300),
    );
  } else {
    // Local file path
    final file = File(imageUrl);
    if (file.existsSync()) {
      imageWidget = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
      );
    } else {
      imageWidget = placeholder ?? Container(color: Colors.grey.shade300);
    }
  }

  if (borderRadius != null) {
    return ClipRRect(borderRadius: borderRadius, child: imageWidget);
  }
  return imageWidget;
}

/// Helper hiển thị nút Social Link bấm mở ứng dụng ngoài (Call, SMS, Email, Web, Zalo...)
Widget buildSocialActionChip({
  required BuildContext context,
  required SocialLink link,
  required Color primaryColor,
  required Color textColor,
  bool compact = false,
}) {
  final meta = CardConstants.getSocialMeta(link.type.name);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () async {
        final uri = Uri.tryParse(link.value);
        if (uri != null) {
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Không thể mở liên kết: ${link.value}')),
              );
            }
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              meta.icon,
              size: compact ? 15 : 18,
              color: primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              link.label?.isNotEmpty == true ? link.label! : meta.name,
              style: GoogleFonts.roboto(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
