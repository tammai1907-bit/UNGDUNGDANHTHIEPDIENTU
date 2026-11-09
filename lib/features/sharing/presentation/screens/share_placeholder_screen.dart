import 'package:flutter/material.dart';

class SharePlaceholderScreen extends StatelessWidget {
  const SharePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 54, color: Color(0xFF1E88E5)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Phân Hệ Chia Sẻ Thông Minh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mã QR cá nhân lớn, Chạm NFC và Xuất vCard 3.0 (Triển khai trong Giai đoạn 2)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
