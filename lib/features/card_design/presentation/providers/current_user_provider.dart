import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provider cung cấp userId hiện tại.
/// Tự động liên kết với người dùng đang đăng nhập từ Phân hệ Auth, fallback về 'user_current'.
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProfileProvider);
  return user?.id ?? 'user_current';
});
