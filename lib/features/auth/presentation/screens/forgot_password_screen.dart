import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/validators/auth_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../card_design/presentation/providers/card_repository_provider.dart' show useMockDataProvider;
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEmailSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    final email = _emailController.text.trim();
    final err = AuthValidators.validateEmail(email);
    if (err != null) {
      AppSnackBar.showError(context, err);
      return;
    }

    setState(() => _isLoading = true);
    final controller = ref.read(authControllerProvider.notifier);
    final success = await controller.sendPasswordResetEmail(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isEmailSent = success;
      });

      if (success) {
        final useMock = ref.read(useMockDataProvider);
        if (useMock) {
          _otpController.text = '123456';
          AppSnackBar.showSuccess(
            context,
            'Mã OTP thử nghiệm của bạn là: 123456 (Đã tự động điền)',
          );
        } else {
          AppSnackBar.showSuccess(
            context,
            'Đã gửi liên kết đặt lại mật khẩu đến email của bạn!',
          );
        }
      } else {
        AppSnackBar.showError(context, 'Không thể gửi yêu cầu đặt lại mật khẩu');
      }
    }
  }

  Future<void> _handleConfirmReset() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final otpErr = AuthValidators.validateOtp(otp);
    if (otpErr != null) {
      AppSnackBar.showError(context, otpErr);
      return;
    }

    final passErr = AuthValidators.validatePassword(newPassword);
    if (passErr != null) {
      AppSnackBar.showError(context, passErr);
      return;
    }

    final confirmErr = AuthValidators.validateConfirmPassword(confirmPassword, newPassword);
    if (confirmErr != null) {
      AppSnackBar.showError(context, confirmErr);
      return;
    }

    setState(() => _isLoading = true);
    final controller = ref.read(authControllerProvider.notifier);
    final success = await controller.confirmPasswordResetWithOtp(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        AppSnackBar.showSuccess(context, 'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.');
        context.pop();
      } else {
        AppSnackBar.showError(context, 'Mã OTP không đúng hoặc đã hết hạn');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final useMock = ref.watch(useMockDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên Mật Khẩu'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, size: 36, color: Color(0xFF1E88E5)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Khôi Phục Mật Khẩu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
              ),
              const SizedBox(height: 8),
              Text(
                _isEmailSent
                    ? 'Nhập mã xác nhận 6 số và mật khẩu mới của bạn bên dưới.'
                    : 'Nhập địa chỉ email đăng ký tài khoản của bạn để nhận hướng dẫn đặt lại mật khẩu.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Ô nhập Email
              TextFormField(
                controller: _emailController,
                enabled: !_isEmailSent,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ Email *',
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              if (!_isEmailSent) ...[
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleSendReset,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Gửi Yêu Cầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                // Banner thông báo OTP cho chế độ Mock
                if (useMock) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chế độ Mock: Mã OTP thử nghiệm là 123456',
                            style: TextStyle(fontSize: 13, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Mã OTP
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Mã xác nhận OTP (6 số) *',
                    hintText: '123456',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 10),

                // Mật khẩu mới
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới (tối thiểu 8 ký tự) *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),

                // Xác nhận mật khẩu mới
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận lại mật khẩu mới *',
                    prefixIcon: const Icon(Icons.lock_clock_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),

                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleConfirmReset,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Đặt Lại Mật Khẩu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isEmailSent = false),
                  child: const Text('Gửi lại tới email khác'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
