import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

/// Interface trừu tượng quản lý xác thực và thông tin tài khoản người dùng
abstract class AuthRepository {
  /// Luồng theo dõi trạng thái xác thực người dùng trong thời gian thực
  Stream<UserProfile?> get authStateChanges;

  /// Người dùng hiện tại đang đăng nhập (hoặc null nếu chưa đăng nhập)
  UserProfile? get currentUser;

  /// Đăng nhập bằng Email và Mật khẩu
  Future<Result<UserProfile>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Đăng ký tài khoản mới
  Future<Result<UserProfile>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  });

  /// Đăng nhập bằng tài khoản Google
  Future<Result<UserProfile>> signInWithGoogle();

  /// Gửi email hoặc mã OTP đặt lại mật khẩu
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Xác nhận đặt lại mật khẩu bằng mã OTP (chế độ mock / custom backend)
  Future<Result<void>> confirmPasswordResetWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Đăng xuất khỏi hệ thống
  Future<Result<void>> signOut();

  /// Đổi mật khẩu tài khoản
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Cập nhật thông tin hồ sơ gốc (Họ tên, SĐT, Avatar)
  Future<Result<UserProfile>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  });

  /// Xóa vĩnh viễn tài khoản người dùng
  Future<Result<void>> deleteAccount();
}
