import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';

/// Các nền tảng ứng dụng phổ biến hỗ trợ chia sẻ danh thiếp
enum SharePlatformType {
  messenger,
  zalo,
  facebook,
  instagram,
  tiktok,
  telegram,
  whatsapp,
  sms,
  email,
  linkedin,
  qrImage,
  system,
}

extension SharePlatformTypeX on SharePlatformType {
  String get label {
    switch (this) {
      case SharePlatformType.messenger:
        return 'Messenger';
      case SharePlatformType.zalo:
        return 'Zalo';
      case SharePlatformType.facebook:
        return 'Facebook';
      case SharePlatformType.instagram:
        return 'Instagram';
      case SharePlatformType.tiktok:
        return 'TikTok';
      case SharePlatformType.telegram:
        return 'Telegram';
      case SharePlatformType.whatsapp:
        return 'WhatsApp';
      case SharePlatformType.sms:
        return 'Tin nhắn';
      case SharePlatformType.email:
        return 'Gmail';
      case SharePlatformType.linkedin:
        return 'LinkedIn';
      case SharePlatformType.qrImage:
        return 'Ảnh QR';
      case SharePlatformType.system:
        return 'Khác';
    }
  }
}

/// Hiển thị bảng chọn chia sẻ danh thiếp đa nền tảng chân thật (Messenger, Zalo, Instagram, Facebook...)
Future<void> showShareOptionsBottomSheet(
  BuildContext context, {
  required BusinessCard card,
  required String shareUrl,
  Future<void> Function()? onShareQrImage,
  void Function(String platform)? onSharedEvent,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => ShareOptionsBottomSheet(
      parentContext: context,
      card: card,
      shareUrl: shareUrl,
      onShareQrImage: onShareQrImage,
      onSharedEvent: onSharedEvent,
    ),
  );
}

class ShareOptionsBottomSheet extends StatelessWidget {
  final BuildContext parentContext;
  final BusinessCard card;
  final String shareUrl;
  final Future<void> Function()? onShareQrImage;
  final void Function(String platform)? onSharedEvent;

  const ShareOptionsBottomSheet({
    super.key,
    required this.parentContext,
    required this.card,
    required this.shareUrl,
    this.onShareQrImage,
    this.onSharedEvent,
  });

  static Future<void> shareViaPlatform(
    BuildContext context, {
    required SharePlatformType platform,
    required BusinessCard card,
    required String shareUrl,
    Future<void> Function()? onShareQrImage,
    void Function(String platform)? onSharedEvent,
  }) async {
    final shareText =
        'Xem và lưu danh thiếp điện tử của ${card.fullName} tại: $shareUrl';
    final encodedUrl = Uri.encodeComponent(shareUrl);
    final encodedText = Uri.encodeComponent(shareText);

    // Luôn sao chép sẵn vào clipboard để người dùng có thể dán ngay nếu app không tự điền text
    if (platform != SharePlatformType.qrImage &&
        platform != SharePlatformType.system) {
      await Clipboard.setData(ClipboardData(text: shareText));
    }

    onSharedEvent?.call(platform.name);

    switch (platform) {
      case SharePlatformType.qrImage:
        if (onShareQrImage != null) {
          await onShareQrImage();
        }
        return;

      case SharePlatformType.system:
        await Share.share(
          shareText,
          subject: 'Danh thiếp điện tử - ${card.fullName}',
        );
        return;

      case SharePlatformType.messenger:
        final opened = await _tryLaunchUrls([
          Uri.parse('fb-messenger://share?link=$encodedUrl'),
          Uri.parse('fb-messenger://'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Messenger',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;

      case SharePlatformType.zalo:
        final opened = await _tryLaunchUrls([
          Uri.parse('zalo://'),
        ]);
        if (context.mounted) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Zalo',
            shareText: shareText,
            cardName: card.fullName,
            openedApp: opened,
          );
        }
        return;

      case SharePlatformType.facebook:
        final opened = await _tryLaunchUrls([
          Uri.parse('fb://facewebmodal/f?href=https://www.facebook.com/sharer/sharer.php?u=$encodedUrl'),
          Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encodedUrl'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Facebook',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;

      case SharePlatformType.instagram:
        final opened = await _tryLaunchUrls([
          Uri.parse('instagram://app'),
          Uri.parse('instagram://'),
        ]);
        if (context.mounted) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Instagram',
            shareText: shareText,
            cardName: card.fullName,
            openedApp: opened,
          );
        }
        return;

      case SharePlatformType.tiktok:
        final opened = await _tryLaunchUrls([
          Uri.parse('snssdk1233://'),
          Uri.parse('musically://'),
        ]);
        if (context.mounted) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'TikTok',
            shareText: shareText,
            cardName: card.fullName,
            openedApp: opened,
          );
        }
        return;

      case SharePlatformType.telegram:
        final opened = await _tryLaunchUrls([
          Uri.parse('tg://msg_url?url=$encodedUrl&text=${Uri.encodeComponent('Danh thiếp điện tử - ${card.fullName}')}'),
          Uri.parse('https://t.me/share/url?url=$encodedUrl&text=${Uri.encodeComponent('Danh thiếp điện tử - ${card.fullName}')}'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Telegram',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;

      case SharePlatformType.whatsapp:
        final opened = await _tryLaunchUrls([
          Uri.parse('whatsapp://send?text=$encodedText'),
          Uri.parse('https://wa.me/?text=$encodedText'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'WhatsApp',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;

      case SharePlatformType.sms:
        final opened = await _tryLaunchUrls([
          Uri.parse('sms:?body=$encodedText'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Tin nhắn SMS',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;

      case SharePlatformType.email:
        final subject = Uri.encodeComponent('Danh thiếp điện tử - ${card.fullName}');
        final opened = await _tryLaunchUrls([
          Uri.parse('mailto:?subject=$subject&body=$encodedText'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'Gmail',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;

      case SharePlatformType.linkedin:
        final opened = await _tryLaunchUrls([
          Uri.parse('https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl'),
        ]);
        if (context.mounted && !opened) {
          _showCopyAndFallbackSnackBar(
            context,
            appName: 'LinkedIn',
            shareText: shareText,
            cardName: card.fullName,
          );
        }
        return;
    }
  }

  static Future<bool> _tryLaunchUrls(List<Uri> uris) async {
    for (final uri in uris) {
      try {
        if (await canLaunchUrl(uri)) {
          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (ok) return true;
        }
      } catch (_) {}
    }
    return false;
  }

  static void _showCopyAndFallbackSnackBar(
    BuildContext context, {
    required String appName,
    required String shareText,
    required String cardName,
    bool openedApp = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        content: Text(
          openedApp
              ? 'Đã sao chép danh thiếp & mở $appName — hãy dán link để gửi!'
              : 'Đã sao chép liên kết danh thiếp để chia sẻ qua $appName!',
        ),
        action: SnackBarAction(
          label: 'Mở khay máy',
          textColor: const Color(0xFF60A5FA),
          onPressed: () {
            Share.share(shareText, subject: 'Danh thiếp điện tử - $cardName');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final platforms = SharePlatformType.values;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tiêu đề
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.share_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chia sẻ danh thiếp',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${card.fullName}${card.jobTitle.isNotEmpty ? ' • ${card.jobTitle}' : ''}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Khung preview liên kết + copy nhanh
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shareUrl,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: shareUrl));
                      Navigator.pop(context);
                      if (parentContext.mounted) {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF16A34A),
                            behavior: SnackBarBehavior.floating,
                            content: Text('Đã sao chép liên kết danh thiếp vào bộ nhớ tạm!'),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text(
                            'Sao chép',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Text(
              'Gửi qua ứng dụng phổ biến',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 14),

            // Lưới 12 ứng dụng phổ biến
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: platforms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (itemCtx, index) {
                final platform = platforms[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    Navigator.pop(context);
                    await shareViaPlatform(
                      parentContext,
                      platform: platform,
                      card: card,
                      shareUrl: shareUrl,
                      onShareQrImage: onShareQrImage,
                      onSharedEvent: onSharedEvent,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SharePlatformIconBadge(platform: platform, size: 52),
                      const SizedBox(height: 6),
                      Text(
                        platform.label,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget biểu tượng thương hiệu đặc trưng cho từng ứng dụng chia sẻ
class SharePlatformIconBadge extends StatelessWidget {
  final SharePlatformType platform;
  final double size;

  const SharePlatformIconBadge({
    super.key,
    required this.platform,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.32);

    switch (platform) {
      case SharePlatformType.messenger:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF0099FF), Color(0xFFA033FF), Color(0xFFFF5280)],
            ),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: size * 0.56,
          ),
        );

      case SharePlatformType.zalo:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF0068FF),
          ),
          alignment: Alignment.center,
          child: Text(
            'Zalo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.31,
              letterSpacing: -0.5,
            ),
          ),
        );

      case SharePlatformType.facebook:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF1877F2),
          ),
          alignment: Alignment.center,
          child: Text(
            'f',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.62,
              height: 1.0,
            ),
          ),
        );

      case SharePlatformType.instagram:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: const LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFFF58529),
                Color(0xFFDD2A7B),
                Color(0xFF8134AF),
                Color(0xFF515BD4),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: size * 0.56,
              height: size * 0.56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.16),
                border: Border.all(color: Colors.white, width: 2.2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size * 0.24,
                    height: size * 0.24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                  Positioned(
                    top: size * 0.06,
                    right: size * 0.06,
                    child: Container(
                      width: size * 0.08,
                      height: size * 0.08,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case SharePlatformType.tiktok:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF0F172A),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-1.5, -1),
                child: Icon(
                  Icons.music_note_rounded,
                  color: const Color(0xFF25F4EE),
                  size: size * 0.56,
                ),
              ),
              Transform.translate(
                offset: const Offset(1.5, 1),
                child: Icon(
                  Icons.music_note_rounded,
                  color: const Color(0xFFFE2C55),
                  size: size * 0.56,
                ),
              ),
              Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: size * 0.56,
              ),
            ],
          ),
        );

      case SharePlatformType.telegram:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF26A5E4),
          ),
          child: Transform.rotate(
            angle: -0.35,
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        );

      case SharePlatformType.whatsapp:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF25D366),
          ),
          child: Icon(
            Icons.chat_rounded,
            color: Colors.white,
            size: size * 0.52,
          ),
        );

      case SharePlatformType.sms:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF16A34A),
          ),
          child: Icon(
            Icons.sms_rounded,
            color: Colors.white,
            size: size * 0.52,
          ),
        );

      case SharePlatformType.email:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFFEA4335),
          ),
          child: Icon(
            Icons.mail_rounded,
            color: Colors.white,
            size: size * 0.52,
          ),
        );

      case SharePlatformType.linkedin:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF0A66C2),
          ),
          alignment: Alignment.center,
          child: Text(
            'in',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.44,
              letterSpacing: -0.5,
            ),
          ),
        );

      case SharePlatformType.qrImage:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF7C3AED),
          ),
          child: Icon(
            Icons.qr_code_2_rounded,
            color: Colors.white,
            size: size * 0.54,
          ),
        );

      case SharePlatformType.system:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: const Color(0xFF475569),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
            size: size * 0.54,
          ),
        );
    }
  }
}
