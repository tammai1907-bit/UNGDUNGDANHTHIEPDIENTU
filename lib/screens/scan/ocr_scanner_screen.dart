import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/ocr_service.dart';
import '../../models/saved_contact_model.dart';
import '../../models/business_card_model.dart';
import '../../providers/wallet_provider.dart';
import '../home/card_builder_screen.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  OcrResult? _ocrResult;

  final _nameCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _jobCtrl.dispose();
    _companyCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (file == null) return;

      setState(() {
        _selectedImage = File(file.path);
        _isProcessing = true;
      });

      // Bắt đầu bóc tách OCR thông minh
      final result = await OcrService.instance.processBusinessCardImage(file.path);

      setState(() {
        _ocrResult = result;
        _isProcessing = false;
        _nameCtrl.text = result.fullName;
        _jobCtrl.text = result.jobTitle;
        _companyCtrl.text = result.company;
        _phoneCtrl.text = result.phone;
        _emailCtrl.text = result.email;
        _websiteCtrl.text = result.website;
        _addressCtrl.text = result.address;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chụp/chọn ảnh: $e')),
        );
      }
    }
  }

  void _saveToWallet() async {
    if (_nameCtrl.text.isEmpty && _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin họ tên hoặc SĐT')),
      );
      return;
    }

    final newContact = SavedContactModel(
      id: 'ocr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Danh thiếp giấy OCR',
      jobTitle: _jobCtrl.text,
      company: _companyCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      website: _websiteCtrl.text,
      address: _addressCtrl.text,
      tags: ['Đối tác'],
      notes: 'Bóc tách tự động bằng AI OCR từ ảnh danh thiếp giấy.',
      metAt: DateTime.now(),
    );

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.addContactWithLocation(newContact, fetchGps: true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Đã lưu danh thiếp giấy vào Ví (+ Tự động lấy GPS)!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _openInCardBuilder() {
    final draftCard = BusinessCardModel(
      id: 'ocr_profile_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_current',
      cardName: 'Hồ sơ từ Danh thiếp giấy',
      fullName: _nameCtrl.text,
      jobTitle: _jobCtrl.text,
      company: _companyCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      website: _websiteCtrl.text,
      address: _addressCtrl.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CardBuilderScreen(existingCard: draftCard)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Danh Thiếp Giấy (AI OCR)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chụp danh thiếp giấy truyền thống, AI Google ML Kit sẽ tự động bóc tách Tên, SĐT, Email, Công ty và Chức danh.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Image Preview or Placeholder
            Center(
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner_outlined, size: 54, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('Chưa có ảnh danh thiếp', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Camera / Gallery Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp Ảnh'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Chọn Từ Thư Viện'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isProcessing) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('AI đang phân tích và bóc tách chữ từ danh thiếp...', style: TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
            ],

            // Parsed Extracted Form
            if (_ocrResult != null && !_isProcessing) ...[
              const Text(
                'Dữ liệu bóc tách được (Có thể chỉnh sửa):',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _jobCtrl,
                decoration: const InputDecoration(labelText: 'Chức danh', prefixIcon: Icon(Icons.work_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _companyCtrl,
                decoration: const InputDecoration(labelText: 'Công ty', prefixIcon: Icon(Icons.business_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _websiteCtrl,
                decoration: const InputDecoration(labelText: 'Website', prefixIcon: Icon(Icons.language_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Địa chỉ', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 20),

              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                  onPressed: _saveToWallet,
                  icon: const Icon(Icons.bookmark_added),
                  label: const Text('Lưu Vào Ví Danh Thiếp (+ Tọa Độ GPS)'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openInCardBuilder,
                  icon: const Icon(Icons.tune),
                  label: const Text('Tạo Thành Mẫu Danh Thiếp Cá Nhân Mới'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}
