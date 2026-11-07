import 'package:flutter/material.dart';
import 'qr_scanner_screen.dart';
import 'ocr_scanner_screen.dart';
import 'nfc_screen.dart';

class ScanHubScreen extends StatelessWidget {
  const ScanHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung Tâm Thu Thập & Quét'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tích Hợp Phần Cứng Di Động 🚀',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Khai thác tối đa Camera, Chip NFC, AI Vision và GPS để trao đổi danh thiếp.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            // Card 1: Camera QR Code
            _buildFeatureCard(
              context,
              title: 'Quét Mã QR Danh Thiếp',
              subtitle: 'Nhận diện tức thì vCard và tự động lấy tọa độ GPS địa điểm gặp gỡ.',
              icon: Icons.qr_code_scanner,
              color: const Color(0xFF2563EB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Card 2: AI OCR CameraX
            _buildFeatureCard(
              context,
              title: 'Số Hóa Danh Thiếp Giấy (AI OCR)',
              subtitle: 'Chụp danh thiếp giấy, Google ML Kit tự động trích xuất Tên, SĐT, Email, Công ty.',
              icon: Icons.document_scanner,
              color: const Color(0xFF16A34A),
              badge: 'Trí Tuệ Nhân Tạo (ML Kit)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OcrScannerScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Card 3: NFC Tap
            _buildFeatureCard(
              context,
              title: 'Giao Tiếp Không Dây NFC',
              subtitle: 'Đọc & Ghi thẻ NFC vật lý, giả lập chạm 2 máy truyền danh thiếp (HCE Demo).',
              icon: Icons.nfc,
              color: const Color(0xFF8B5CF6),
              badge: 'Chip NFC & HCE',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NfcScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
