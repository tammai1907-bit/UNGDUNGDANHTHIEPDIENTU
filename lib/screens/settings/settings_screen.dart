import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt & Tài Khoản'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    child: Text(
                      user?.displayName.isNotEmpty == true ? user!.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Người dùng',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty)
                          Text(
                            user.phoneNumber!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bảo mật & Phần cứng
            const Text(
              'BẢO MẬT & PHẦN CỨNG',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint, color: Color(0xFF2563EB)),
                    title: const Text('Mở Khóa Bằng Sinh Trắc Học', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Sử dụng Vân tay hoặc FaceID khi mở ứng dụng', style: TextStyle(fontSize: 12)),
                    value: authProvider.isBiometricEnabled,
                    onChanged: authProvider.canUseBiometrics
                        ? (val) => authProvider.toggleBiometric(val)
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.nfc, color: Color(0xFF8B5CF6)),
                    title: const Text('Trạng Thái Chip NFC', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Sẵn sàng cho NDEF Read/Write & HCE', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Color(0xFFE11D48)),
                    title: const Text('Dịch Vụ Định Vị GPS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Tự động gắn tọa độ khi lưu danh thiếp', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thông tin đồ án
            const Text(
              'THÔNG TIN ĐỒ ÁN',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đề tài: ỨNG DỤNG DANH THIẾP ĐIỆN TỬ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  SizedBox(height: 4),
                  Text('Môn học: Lập trình trên thiết bị di động', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                  Text('Công nghệ: Flutter, ML Kit AI, NFC Manager, Geolocator, SQLite', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                  Text('Phiên bản: 1.0.0 (Final Release)', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nút Đăng xuất
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng Xuất Tài Khoản'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
