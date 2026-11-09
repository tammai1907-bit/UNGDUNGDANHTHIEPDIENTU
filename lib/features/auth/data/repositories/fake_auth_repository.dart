import 'dart:async';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Bản cài đặt Fake / In-Memory của AuthRepository
/// Cho phép chạy thử nghiệm độc lập toàn bộ tính năng xác thực không phụ thuộc Firebase
class FakeAuthRepository implements AuthRepository {
  static final UserProfile demoUser = UserProfile(
    id: 'user_current',
    email: 'tammai1907@gmail.com',
    fullName: 'Mai Văn Tâm',
    phoneNumber: '0987654321',
    photoUrl: null,
    isEmailVerified: true,
    createdAt: DateTime(2026, 1, 1),
  );

  static const String demoPassword = '12345';

  // Lưu trữ tài khoản và mật khẩu trong bộ nhớ RAM
  final Map<String, String> _passwords = {
    'tammai1907@gmail.com': demoPassword,
    'admin@techcorp.vn': 'Admin@123',
  };

  final Map<String, UserProfile> _users = {
    'tammai1907@gmail.com': demoUser,
  };

  final Map<String, String> _resetOtps = {};

  UserProfile? _currentUser;
  final StreamController<UserProfile?> _authController =
      StreamController<UserProfile?>.broadcast();

  FakeAuthRepository({bool startLoggedIn = false}) {
    if (startLoggedIn) {
      _currentUser = demoUser;
    }
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    // Phát ngay trạng thái hiện tại khi vừa lắng nghe
    Future.microtask(() => _authController.add(_currentUser));
    return _authController.stream;
  }

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Future<Result<UserProfile>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final normalizedEmail = email.trim().toLowerCase();

    final storedPassword = _passwords[normalizedEmail];
    final isMatch = storedPassword != null &&
        (storedPassword == password ||
            (normalizedEmail == demoUser.email &&
                (password == '12345' || password == '123456' || password == 'Password123')));

    if (!isMatch) {
      return Result.failure(Exception(
        'Email hoặc mật khẩu không chính xác! Vui lòng nhập đúng Email: tammai1907@gmail.com và Mật khẩu: 12345',
      ));
    }

    _currentUser = _users[normalizedEmail];
    _authController.add(_currentUser);
    return Result.success(_currentUser!);
  }

  @override
  Future<Result<UserProfile>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final normalizedEmail = email.trim().toLowerCase();

    if (_users.containsKey(normalizedEmail)) {
      return Result.failure(Exception('Địa chỉ email này đã được đăng ký tài khoản'));
    }

    final newUser = UserProfile(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: normalizedEmail,
      fullName: fullName.trim(),
      phoneNumber: phoneNumber?.trim(),
      isEmailVerified: true,
      createdAt: DateTime.now(),
    );

    _passwords[normalizedEmail] = password;
    _users[normalizedEmail] = newUser;
    _currentUser = newUser;
    _authController.add(_currentUser);

    return Result.success(newUser);
  }

  @override
  Future<Result<UserProfile>> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Giả lập tài khoản Google thành công
    const googleEmail = 'tam.mai.google@gmail.com';
    final user = _users[googleEmail] ??
        UserProfile(
          id: 'user_google_01',
          email: googleEmail,
          fullName: 'Mai Văn Tâm (Google)',
          phoneNumber: '0987654321',
          photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );

    _users[googleEmail] = user;
    _passwords[googleEmail] = 'GoogleAuthSecret123';
    _currentUser = user;
    _authController.add(_currentUser);

    return Result.success(user);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final normalizedEmail = email.trim().toLowerCase();

    // Sinh mã OTP 6 số cố định để dễ dàng kiểm thử demo
    _resetOtps[normalizedEmail] = '123456';
    return Result.success(null);
  }

  @override
  Future<Result<void>> confirmPasswordResetWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final normalizedEmail = email.trim().toLowerCase();

    final expectedOtp = _resetOtps[normalizedEmail] ?? '123456';
    if (otp.trim() != expectedOtp && otp.trim() != '123456') {
      return Result.failure(Exception('Mã xác nhận OTP không chính xác hoặc đã hết hạn'));
    }

    if (_users.containsKey(normalizedEmail)) {
      _passwords[normalizedEmail] = newPassword;
      _resetOtps.remove(normalizedEmail);
      return Result.success(null);
    } else {
      return Result.failure(Exception('Không tìm thấy tài khoản với email này'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _authController.add(null);
    return Result.success(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser == null) {
      return Result.failure(Exception('Chưa đăng nhập'));
    }

    final stored = _passwords[_currentUser!.email];
    if (stored != currentPassword) {
      return Result.failure(Exception('Mật khẩu hiện tại không chính xác'));
    }

    _passwords[_currentUser!.email] = newPassword;
    return Result.success(null);
  }

  @override
  Future<Result<UserProfile>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser == null) {
      return Result.failure(Exception('Chưa đăng nhập'));
    }

    final updated = _currentUser!.copyWith(
      fullName: fullName ?? _currentUser!.fullName,
      phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      updatedAt: DateTime.now(),
    );

    _currentUser = updated;
    _users[updated.email] = updated;
    _authController.add(updated);

    return Result.success(updated);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser == null) {
      return Result.failure(Exception('Chưa đăng nhập'));
    }

    _users.remove(_currentUser!.email);
    _passwords.remove(_currentUser!.email);
    _currentUser = null;
    _authController.add(null);

    return Result.success(null);
  }
}
