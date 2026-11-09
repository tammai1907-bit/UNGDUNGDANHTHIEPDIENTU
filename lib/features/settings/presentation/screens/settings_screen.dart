import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../card_design/presentation/providers/card_repository_provider.dart' show useMockDataProvider;
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi Mật Khẩu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại *'),
                validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu hiện tại' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới (tối thiểu 8 ký tự) *'),
                validator: AuthValidators.validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Xác nhận lại mật khẩu mới *'),
                validator: (v) => AuthValidators.validateConfirmPassword(v, newPassController.text),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await ref.read(authControllerProvider.notifier).changePassword(
                    currentPassword: currentPassController.text,
                    newPassword: newPassController.text,
                  );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (ok) {
                  AppSnackBar.showSuccess(context, 'Đổi mật khẩu thành công!');
                } else {
                  AppSnackBar.showError(context, 'Mật khẩu hiện tại không đúng');
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      title: 'Xóa Vĩnh Viễn Tài Khoản?',
      content:
          'Hành động này không thể hoàn tác. Mọi danh thiếp, danh bạ và dữ liệu của bạn sẽ bị xóa vĩnh viễn khỏi hệ thống.',
      confirmText: 'Xóa Tài Khoản',
      cancelText: 'Hủy',
      isDestructive: true,
    );

    if (confirm && context.mounted) {
      final ok = await ref.read(authControllerProvider.notifier).deleteAccount();
      if (ok && context.mounted) {
        AppSnackBar.showSuccess(context, 'Đã xóa tài khoản thành công');
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final useMock = ref.watch(useMockDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt & Quyền Riêng Tư'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 1. GIAO DIỆN & CHỦ ĐỀ
          const Text(
            'GIAO DIỆN & HIỂN THỊ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chế độ màn hình:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_brightness), label: Text('Hệ thống')),
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Sáng')),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Tối')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        settingsNotifier.setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. BẢO MẬT & QUYỀN RIÊNG TƯ
          const Text(
            'BẢO MẬT & QUYỀN RIÊNG TƯ',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.search_rounded, color: Color(0xFF1E88E5)),
                  title: const Text('Cho phép tìm kiếm công khai', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Người khác có thể tìm thấy danh thiếp của bạn qua email hoặc tên', style: TextStyle(fontSize: 12)),
                  value: settings.allowPublicSearch,
                  onChanged: (val) => settingsNotifier.setAllowPublicSearch(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.shield_outlined, color: Color(0xFF1E88E5)),
                  title: const Text('Yêu cầu xác nhận khi xem thẻ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Ẩn thông tin nhạy cảm (SĐT, Email riêng tư) khi người lạ quét thẻ', style: TextStyle(fontSize: 12)),
                  value: settings.requireAuthToViewCard,
                  onChanged: (val) => settingsNotifier.setRequireAuthToViewCard(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. TÀI KHOẢN & BẢO MẬT
          const Text(
            'QUẢN LÝ TÀI KHOẢN',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password_rounded, color: Color(0xFF1E88E5)),
                  title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.science_outlined, color: Colors.amber),
                  title: const Text('Chế độ Dữ liệu Mock / Firebase', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(useMock ? 'Đang chạy Fake In-Memory' : 'Đang kết nối Firebase thật', style: const TextStyle(fontSize: 12)),
                  value: useMock,
                  activeThumbColor: Colors.amber,
                  onChanged: (val) {
                    ref.read(useMockDataProvider.notifier).state = val;
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Xóa vĩnh viễn tài khoản', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                  onTap: () => _handleDeleteAccount(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Thông tin ứng dụng
          Center(
            child: Column(
              children: [
                Text(
                  'Danh Thiếp Điện Tử v1.0.0',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giải pháp kết nối số thông minh cho doanh nghiệp',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
