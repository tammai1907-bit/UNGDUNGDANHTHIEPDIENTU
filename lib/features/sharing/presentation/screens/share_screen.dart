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
import 'package:digital_business_card/features/auth/presentation/providers/auth_providers.dart';
import 'package:digital_business_card/features/card_design/domain/entities/business_card.dart';
import 'package:digital_business_card/features/card_design/presentation/providers/card_list_controller.dart';
import 'package:digital_business_card/features/sharing/utils/vcard_generator.dart';
import 'nfc_exchange_screen.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _selectedCardId;
  bool _isSavingImage = false;

  Future<void> _shareQrAsImage(BusinessCard card) async {
    setState(() => _isSavingImage = true);
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_${card.id}.png');
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          subject: 'Mã QR Danh thiếp: ${card.fullName}',
          text: 'Quét mã QR này để kết nối với ${card.fullName} (${card.jobTitle})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu ảnh QR: $e')),
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

  void _shareLink(String url, String name) {
    Share.share(
      'Xem và lưu danh thiếp điện tử của $name tại: $url',
      subject: 'Danh thiếp điện tử - $name',
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
            tooltip: 'Quét mã QR',
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
                  const Icon(Icons.credit_card_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Bạn chưa có danh thiếp nào để chia sẻ', style: TextStyle(fontSize: 16)),
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
            orElse: () => cards.firstWhere((c) => c.isDefault, orElse: () => cards.first),
          );

          final shareUrl = AppConstants.buildCardShareUrl(
            ownerId: ownerId,
            cardId: currentCard.id,
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chọn thẻ nếu có nhiều hơn 1 thẻ
                  if (cards.length > 1) ...[
                    const Text('Chọn danh thiếp cần chia sẻ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                                  Icon(c.isDefault ? Icons.star : Icons.credit_card, size: 18, color: const Color(0xFF2563EB)),
                                  const SizedBox(width: 8),
                                  Text(c.cardName, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    const SizedBox(height: 20),
                  ],

                  // Khung QR Code chụp được để lưu thành ảnh
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
                              data: shareUrl,
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
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            if (currentCard.jobTitle.isNotEmpty)
                              Text(
                                currentCard.jobTitle,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Đường dẫn chia sẻ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 20, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shareUrl,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
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

                  const SizedBox(height: 20),

                  // Nhóm các nút hành động
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _shareLink(shareUrl, currentCard.fullName),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Chia Sẻ Link'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isSavingImage ? null : () => _shareQrAsImage(currentCard),
                          icon: _isSavingImage
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                          icon: const Icon(Icons.nfc_rounded, size: 18, color: Color(0xFFEA580C)),
                          label: const Text('Chạm Ghi NFC'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => VCardGenerator.shareVCard(currentCard),
                          icon: const Icon(Icons.contact_page_outlined, size: 18, color: Color(0xFF16A34A)),
                          label: const Text('Xuất vCard'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nút quét QR nhanh
                  Center(
                    child: TextButton.icon(
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
