import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cung cấp userId hiện tại.
/// Mặc định trả về 'demo_user' (Mai Văn Tâm) để dễ dàng ghép nối với module Auth của thành viên khác.
final currentUserIdProvider = Provider<String>((ref) {
  return 'user_current';
});
