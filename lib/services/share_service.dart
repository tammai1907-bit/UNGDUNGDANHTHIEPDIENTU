import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../models/business_card_model.dart';

class ShareService {
  static final ShareService instance = ShareService._init();
  ShareService._init();

  /// Chia sẻ danh thiếp dạng text hoặc đường link
  Future<void> shareText({required String text, String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Xuất và chia sẻ tệp danh thiếp điện tử chuẩn vCard (.vcf)
  Future<void> shareVCardFile(BusinessCardModel card) async {
    try {
      final vcardContent = card.toVCard();
      final tempDir = await getTemporaryDirectory();
      final fileName = '${card.fullName.replaceAll(RegExp(r'\s+'), '_')}.vcf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(vcardContent);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/vcard')],
        subject: 'Danh thiếp điện tử của ${card.fullName}',
        text: 'Lưu thông tin liên hệ của ${card.fullName} (${card.company})',
      );
    } catch (e) {
      debugPrint('Error sharing vCard file: $e');
    }
  }

  /// Chụp giao diện danh thiếp và chia sẻ dưới dạng ảnh PNG
  Future<void> captureAndShareCardImage(ScreenshotController screenshotController, String cardName) async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.5,
      );

      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'BusinessCard_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          subject: 'Danh thiếp: $cardName',
          text: 'Danh thiếp điện tử được chia sẻ từ ứng dụng Smart Business Card',
        );
      }
    } catch (e) {
      debugPrint('Error sharing card image: $e');
    }
  }
}
