import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:digital_business_card/features/sharing/utils/qr_link_parser.dart';
import 'package:digital_business_card/features/contacts/domain/entities/saved_contact.dart';
import 'package:digital_business_card/features/contacts/presentation/providers/contact_providers.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        _processScannedValue(rawValue);
        break;
      }
    }
  }

  void _processScannedValue(String rawValue) {
    setState(() => _isProcessing = true);

    final cardInfo = QrLinkParser.parse(rawValue);

    if (cardInfo != null) {
      // 1. Mở màn hình danh thiếp công khai của Thành viên 3 kèm tham số source=qr
      context
          .push(
            '/public-card?ownerId=${cardInfo.ownerId}&cardId=${cardInfo.cardId}&source=qr',
          )
          .then((_) {
            if (mounted) setState(() => _isProcessing = false);
          });
      return;
    }

    // 2. Nhận diện danh thiếp định dạng vCard thô trực tiếp
    if (rawValue.toUpperCase().contains('BEGIN:VCARD')) {
      _handleVCardScanned(rawValue);
      return;
    }

    // 3. Nội dung mã QR khác
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mã QR đã quét'),
        content: Text('Nội dung quét được:\n\n$rawValue'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            child: const Text('Tiếp tục quét'),
          ),
        ],
      ),
    );
  }

  void _handleVCardScanned(String vcardText) {
    final parsedContact = SavedContact.fromVCard(
      vcardText,
      source: 'Quét mã QR',
      tags: const ['Sự kiện'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_mail_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  'Đã Nhận Danh Thiếp vCard!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Họ và tên: ${parsedContact.fullName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (parsedContact.jobTitle != null)
              Text(
                'Chức vụ: ${parsedContact.jobTitle}',
                style: const TextStyle(color: Color(0xFF2563EB)),
              ),
            if (parsedContact.company != null)
              Text(
                'Công ty: ${parsedContact.company}',
                style: const TextStyle(color: Colors.grey),
              ),
            if (parsedContact.phone != null)
              Text('Điện thoại: ${parsedContact.phone}'),
            if (parsedContact.email != null)
              Text('Email: ${parsedContact.email}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Lưu Ngay Vào Ví Danh Bạ (CRM)'),
                onPressed: () async {
                  final result = await ref
                      .read(contactControllerProvider.notifier)
                      .addContact(parsedContact);
                  if (!result.isSuccess) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Không thể lưu danh thiếp: ${result.errorOrNull}',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF16A34A),
                        content: Text(
                          'Đã lưu danh thiếp "${parsedContact.fullName}" vào Ví!',
                        ),
                      ),
                    );
                    context.go('/contacts');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final barcodeCapture = await _controller.analyzeImage(image.path);
      if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
        final value = barcodeCapture.barcodes.first.rawValue;
        if (value != null) {
          _processScannedValue(value);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy mã QR trong hình ảnh đã chọn'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi khi phân tích ảnh: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Quét Mã QR Danh Thiếp',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            tooltip: 'Đèn Flash',
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            tooltip: 'Đổi Camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner view
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          // Khung ngắm quét (Overlay)
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2563EB), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // Lời nhắc
          Positioned(
            bottom: 110,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Căn chỉnh mã QR của danh thiếp đối tác vào khung ngắm để tự động nhận và lưu vào Ví',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          // Nút chọn ảnh từ thư viện
          Positioned(
            bottom: 36,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _pickImageFromGallery,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Chọn QR từ thư viện ảnh',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
