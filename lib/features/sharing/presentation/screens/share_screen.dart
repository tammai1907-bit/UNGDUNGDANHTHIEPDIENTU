import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:digital_business_card/config/app_constants.dart';
import 'package:digital_business_card/features/analytics/presentation/providers/analytics_providers.dart';
import 'package:digital_business_card/features/auth/presentation/providers/auth_providers.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/sharing/presentation/widgets/share_options_bottom_sheet.dart';
import 'package:digital_business_card/features/sharing/services/gallery_saver_service.dart';
import 'package:digital_business_card/features/sharing/utils/vcard_generator.dart';
import 'nfc_exchange_screen.dart';

enum QrCodeType { webUrl, vCard }

class ShareScreen extends ConsumerStatefulWidget {
  final Future<Uint8List?> Function()? captureQrOverride;

  const ShareScreen({super.key, this.captureQrOverride});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _selectedCardId;
  QrCodeType _qrType = QrCodeType.webUrl;
  bool _isSavingImage = false;
  bool _isSavingContact = false;

  Future<Uint8List?> _captureQrImageBytes() {
    if (widget.captureQrOverride != null) {
      return widget.captureQrOverride!();
    }
    return _screenshotController.capture(
      delay: const Duration(milliseconds: 80),
      pixelRatio: 3.0,
    );
  }

  /// Lưu thẳng ảnh mã QR vào thư viện Photo của điện thoại
  Future<void> _saveQrToPhotos(BusinessCard card) async {
    setState(() => _isSavingImage = true);
    try {
      final imageBytes = await _captureQrImageBytes();
      if (imageBytes == null) {
        throw Exception('Không thể chụp ảnh mã QR');
      }

      final fileName =
          'QR_${card.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      await GallerySaverService.saveQrImage(imageBytes, fileName: fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Đã lưu về photo',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Lỗi khi lưu ảnh QR: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  /// Chia sẻ file ảnh mã QR qua ứng dụng khác
  Future<void> _shareQrAsImageFile(BusinessCard card) async {
    setState(() => _isSavingImage = true);
    try {
      final imageBytes = await _captureQrImageBytes();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_${card.id}.png');
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          subject: 'Mã QR Danh thiếp: ${card.fullName}',
          text:
              'Quét mã QR này để kết nối với ${card.fullName} (${card.jobTitle})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chia sẻ ảnh QR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingImage = false);
    }
  }

  void _copyLinkToClipboard(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        content: Text('Đã sao chép liên kết danh thiếp vào bộ nhớ tạm!'),
      ),
    );
  }

  void _recordShareEvent(String cardId, String platform) {
    ref.read(analyticsRepositoryProvider).recordEvent(
          cardId: cardId,
          eventType: 'link_click',
          linkType: platform,
        );
  }

  void _openShareSheet(BusinessCard card, String shareUrl) {
    showShareOptionsBottomSheet(
      context,
      card: card,
      shareUrl: shareUrl,
      onShareQrImage: () => _shareQrAsImageFile(card),
      onSharedEvent: (platform) => _recordShareEvent(card.id, platform),
    );
  }

  Future<void> _shareDirectPlatform(
    BusinessCard card,
    String shareUrl,
    SharePlatformType platform,
  ) {
    return ShareOptionsBottomSheet.shareViaPlatform(
      context,
      platform: platform,
      card: card,
      shareUrl: shareUrl,
      onSharedEvent: (p) => _recordShareEvent(card.id, p),
    );
  }

  void _showVCardOptionsModal(BusinessCard card) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contact_phone_rounded,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xuất Danh Bạ Chuẩn vCard (.vcf)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Lưu trực tiếp vào điện thoại hoặc chia sẻ tệp',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tùy chọn 1: Lưu trực tiếp vào danh bạ của điện thoại
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Colors.grey.withValues(alpha: 0.08),
                leading: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF2563EB),
                ),
                title: const Text('Lưu vào Danh bạ điện thoại'),
                subtitle: const Text(
                  'Tự động ghi thông tin vào ứng dụng Danh bạ của máy',
                ),
                trailing: _isSavingContact
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _isSavingContact
                    ? null
                    : () async {
                        setState(() => _isSavingContact = true);
                        Navigator.pop(ctx);
                        final success =
                            await VCardGenerator.saveToDeviceContacts(card);
                        if (!mounted) return;
                        setState(() => _isSavingContact = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                success ? const Color(0xFF16A34A) : Colors.red,
                            content: Text(
                              success
                                  ? '✓ Đã lưu danh thiếp "${card.fullName}" vào Danh bạ điện thoại!'
                                  : 'Không thể lưu danh bạ. Vui lòng cấp quyền truy cập Danh bạ cho ứng dụng.',
                            ),
                          ),
                        );
                      },
              ),

              const SizedBox(height: 10),

              // Tùy chọn 2: Chia sẻ file .vcf qua Zalo, Mail, v.v.
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: Colors.grey.withValues(alpha: 0.08),
                leading: const Icon(
                  Icons.share_outlined,
                  color: Color(0xFF16A34A),
                ),
                title: const Text('Chia sẻ Tệp vCard (.vcf)'),
                subtitle: const Text(
                  'Gửi file danh bạ qua Zalo, Messenger, Email, Bluetooth...',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(ctx);
                  VCardGenerator.shareVCard(card);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(myCardsStreamProvider);
    final userProfile = ref.watch(currentUserProfileProvider);
    final ownerId = userProfile?.id ?? 'user_current';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia Sẻ Danh Thiếp'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Quét mã QR đối tác',
            onPressed: () => context.push('/scan-qr'),
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.credit_card_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có danh thiếp nào để chia sẻ',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.push('/create-card'),
                    child: const Text('Tạo danh thiếp ngay'),
                  ),
                ],
              ),
            );
          }

          // Lấy thẻ đang chọn
          final currentCard = cards.firstWhere(
            (c) => c.id == _selectedCardId,
            orElse: () =>
                cards.firstWhere((c) => c.isDefault, orElse: () => cards.first),
          );

          final shareUrl = AppConstants.buildCardShareUrl(
            ownerId: ownerId,
            cardId: currentCard.id,
          );

          final vcardData = VCardGenerator.generateVCardString(currentCard);
          final qrData = _qrType == QrCodeType.webUrl ? shareUrl : vcardData;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chọn thẻ nếu có nhiều hơn 1 thẻ
                  if (cards.length > 1) ...[
                    const Text(
                      'Chọn danh thiếp cần tạo mã QR:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentCard.id,
                          isExpanded: true,
                          items: cards.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(
                                    c.isDefault
                                        ? Icons.star
                                        : Icons.credit_card,
                                    size: 18,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c.cardName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              setState(() => _selectedCardId = newId);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Chuyển đổi loại QR Code (Link Web hoặc Danh Bạ vCard)
                  Center(
                    child: SegmentedButton<QrCodeType>(
                      segments: const [
                        ButtonSegment<QrCodeType>(
                          value: QrCodeType.webUrl,
                          icon: Icon(Icons.link_rounded, size: 16),
                          label: Text('QR Link Web'),
                        ),
                        ButtonSegment<QrCodeType>(
                          value: QrCodeType.vCard,
                          icon: Icon(Icons.contact_page_rounded, size: 16),
                          label: Text('QR vCard Danh Bạ'),
                        ),
                      ],
                      selected: {_qrType},
                      onSelectionChanged: (set) {
                        setState(() => _qrType = set.first);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Khung QR Code tự động sinh và chụp ảnh
                  Center(
                    child: Screenshot(
                      controller: _screenshotController,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Mã QR lớn
                            QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 220.0,
                              gapless: true,
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                size: Size(40, 40),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentCard.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (currentCard.jobTitle.isNotEmpty)
                              Text(
                                currentCard.jobTitle,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _qrType == QrCodeType.webUrl
                                    ? const Color(0xFF2563EB)
                                        .withValues(alpha: 0.1)
                                    : const Color(0xFF16A34A)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _qrType == QrCodeType.webUrl
                                    ? 'Quét để mở trang web danh thiếp'
                                    : 'Quét để lưu thẳng vào danh bạ (Không cần mạng)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _qrType == QrCodeType.webUrl
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Đường dẫn chia sẻ
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shareUrl,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Sao chép',
                          onPressed: () => _copyLinkToClipboard(shareUrl),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Nhóm các nút hành động chính
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () =>
                              _openShareSheet(currentCard, shareUrl),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Chia Sẻ Link'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSavingImage
                              ? null
                              : () => _saveQrToPhotos(currentCard),
                          icon: _isSavingImage
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.image_outlined, size: 18),
                          label: const Text('Lưu Ảnh QR'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Nút NFC & Xuất vCard
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NfcExchangeScreen(
                                  cardUrl: shareUrl,
                                  cardName: currentCard.cardName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.nfc_rounded,
                            size: 18,
                            color: Color(0xFFEA580C),
                          ),
                          label: const Text('Đọc / Ghi NFC'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _showVCardOptionsModal(currentCard),
                          icon: const Icon(
                            Icons.contact_phone_outlined,
                            size: 18,
                            color: Color(0xFF16A34A),
                          ),
                          label: const Text('Xuất vCard'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Dải ứng dụng chia sẻ nhanh phổ biến
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chia sẻ nhanh qua ứng dụng',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final platform in const [
                                SharePlatformType.messenger,
                                SharePlatformType.zalo,
                                SharePlatformType.facebook,
                                SharePlatformType.instagram,
                                SharePlatformType.tiktok,
                                SharePlatformType.telegram,
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _QuickShareAppTile(
                                    platform: platform,
                                    onTap: () => _shareDirectPlatform(
                                      currentCard,
                                      shareUrl,
                                      platform,
                                    ),
                                  ),
                                ),
                              _QuickShareAppTile(
                                platform: SharePlatformType.system,
                                customLabel: 'Xem thêm',
                                onTap: () =>
                                    _openShareSheet(currentCard, shareUrl),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nút quét QR camera nhanh
                  Center(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => context.push('/scan-qr'),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Quét mã QR của người khác'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickShareAppTile extends StatelessWidget {
  final SharePlatformType platform;
  final String? customLabel;
  final VoidCallback onTap;

  const _QuickShareAppTile({
    required this.platform,
    this.customLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SharePlatformIconBadge(platform: platform, size: 42),
              const SizedBox(height: 5),
              Text(
                customLabel ?? platform.label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
