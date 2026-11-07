import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/contact_service.dart';
import '../../models/saved_contact_model.dart';
import '../../config/app_constants.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    _handleScannedData(code);
  }

  void _handleScannedData(String data) {
    SavedContactModel contact;

    if (data.contains('BEGIN:VCARD')) {
      contact = ContactService.parseVCard(data);
    } else {
      // Dữ liệu text hoặc URL
      contact = SavedContactModel(
        id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: 'Liên hệ quét từ QR',
        jobTitle: '',
        company: '',
        phone: data.startsWith('tel:') ? data.replaceFirst('tel:', '') : '',
        email: data.startsWith('mailto:') ? data.replaceFirst('mailto:', '') : '',
        website: (data.startsWith('http://') || data.startsWith('https://')) ? data : '',
        notes: 'Quét từ mã QR: $data',
        metAt: DateTime.now(),
      );
    }

    _showSaveContactDialog(contact);
  }

  void _showSaveContactDialog(SavedContactModel initialContact) {
    final nameCtrl = TextEditingController(text: initialContact.fullName);
    final phoneCtrl = TextEditingController(text: initialContact.phone);
    final emailCtrl = TextEditingController(text: initialContact.email);
    final companyCtrl = TextEditingController(text: initialContact.company);
    final jobTitleCtrl = TextEditingController(text: initialContact.jobTitle);
    final notesCtrl = TextEditingController(text: initialContact.notes);
    String selectedTag = AppConstants.defaultTags.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        const Text(
                          'Đã Quét Thành Công Danh Thiếp!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _resumeScanner();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            decoration: const InputDecoration(labelText: 'Số điện thoại'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: companyCtrl,
                            decoration: const InputDecoration(labelText: 'Công ty'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: jobTitleCtrl,
                            decoration: const InputDecoration(labelText: 'Chức danh'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'Ghi chú ngữ cảnh gặp gỡ'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Gắn thẻ phân loại (Tag):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.defaultTags.map((tag) {
                        final isSel = selectedTag == tag;
                        return ChoiceChip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          selected: isSel,
                          onSelected: (_) => setModalState(() => selectedTag = tag),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final updatedContact = initialContact.copyWith(
                            fullName: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            company: companyCtrl.text.trim(),
                            jobTitle: jobTitleCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                            tags: [selectedTag],
                          );

                          // Tự động đính kèm GPS tọa độ & vị trí thực tế!
                          final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                          final messenger = ScaffoldMessenger.of(context);
                          await walletProvider.addContactWithLocation(updatedContact, fetchGps: true);

                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('✓ Đã lưu danh thiếp kèm vị trí GPS gặp gỡ vào ví!'),
                                backgroundColor: Color(0xFF16A34A),
                              ),
                            );
                            _resumeScanner();
                          }
                        },
                        icon: const Icon(Icons.bookmark_add),
                        label: const Text('Lưu Vào Ví Danh Thiếp (+ GPS)'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _resumeScanner());
  }

  void _resumeScanner() {
    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Mã QR Danh Thiếp'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                return Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Scanner Overlay Frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2563EB), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hướng camera vào mã QR danh thiếp để quét và tự động ghi nhận vị trí GPS',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
