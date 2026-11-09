import 'package:flutter/material.dart';

class ContactsPlaceholderScreen extends StatelessWidget {
  const ContactsPlaceholderScreen({super.key});

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
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.contacts_rounded, size: 54, color: Color(0xFF0D9488)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ví Danh Bạ Thông Minh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý liên hệ nhận được từ QR/NFC, gắn nhãn Tags và ghi chú (Triển khai trong Giai đoạn 3)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
