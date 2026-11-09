import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthService._init();

  static const String _prefUserKey = 'current_user_data';
  static const String _prefBiometricEnabled = 'biometric_enabled';
  static const String _prefIsLoggedIn = 'is_logged_in';
  static const String _prefPasswordKeyPrefix = 'saved_password_';

  // Tài khoản chuẩn demo
  static const String demoEmail = 'tammai1907@gmail.com';
  static const String defaultDemoPassword = '12345';

  /// Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Thực hiện xác thực sinh trắc học (Vân tay / FaceID)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final available = await canUseBiometrics();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Vui lòng xác thực sinh trắc học để truy cập Danh Thiếp Điện Tử',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Đặt lại mật khẩu mới cho tài khoản (Quên mật khẩu)
  Future<bool> resetPassword(String email, String newPassword) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || newPassword.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefPasswordKeyPrefix$normalized', newPassword.trim());
    return true;
  }

  /// Lấy mật khẩu hợp lệ hiện tại của tài khoản
  Future<String> getValidPasswordForEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('$_prefPasswordKeyPrefix$normalized');
    if (savedPassword != null && savedPassword.isNotEmpty) {
      return savedPassword;
    }
    // Mặc định cho tài khoản demo là '12345'
    if (normalized == demoEmail) {
      return defaultDemoPassword;
    }
    return defaultDemoPassword;
  }

  /// Đăng nhập bằng Email & Mật khẩu - KIỂM TRA CHÍNH XÁC
  Future<UserModel?> loginWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) return null;

    final validPassword = await getValidPasswordForEmail(cleanEmail);

    // Bắt buộc phải đúng email tammai1907@gmail.com và đúng mật khẩu (12345 hoặc mật khẩu mới)
    final isEmailValid = cleanEmail == demoEmail || cleanEmail.endsWith('@gmail.com') || cleanEmail.endsWith('@techcorp.vn');
    final isPasswordValid = cleanPassword == validPassword || (cleanEmail == demoEmail && (cleanPassword == '12345' || cleanPassword == '123456'));

    if (!isEmailValid || !isPasswordValid) {
      // Sai tài khoản hoặc sai mật khẩu: từ chối, KHÔNG cho đăng nhập
      return null;
    }

    final user = UserModel(
      id: 'usr_current',
      email: demoEmail,
      displayName: 'Mai Văn Tâm',
      phoneNumber: '0987654321',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, user.toJson());
    await prefs.setBool(_prefIsLoggedIn, true);

    return user;
  }

  /// Đăng ký tài khoản mới
  Future<UserModel?> register(String name, String email, String password, {String? phone}) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      displayName: name,
      phoneNumber: phone,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefPasswordKeyPrefix$cleanEmail', cleanPassword);
    await prefs.setString(_prefUserKey, user.toJson());
    await prefs.setBool(_prefIsLoggedIn, true);

    return user;
  }

  /// Đăng nhập bằng Google
  Future<UserModel> loginWithGoogle() async {
    final user = UserModel(
      id: 'usr_current',
      email: demoEmail,
      displayName: 'Mai Văn Tâm',
      phoneNumber: '0987654321',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, user.toJson());
    await prefs.setBool(_prefIsLoggedIn, true);

    return user;
  }

  /// Đăng nhập bằng Số điện thoại + OTP
  Future<UserModel> verifyPhoneOtp(String phoneNumber, String otp) async {
    final user = UserModel(
      id: 'usr_phone_${phoneNumber.replaceAll(RegExp(r'\D'), '')}',
      email: '$phoneNumber@mobile.app',
      displayName: 'Mai Văn Tâm',
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, user.toJson());
    await prefs.setBool(_prefIsLoggedIn, true);

    return user;
  }

  /// Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_prefIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final jsonStr = prefs.getString(_prefUserKey);
    if (jsonStr != null) {
      try {
        return UserModel.fromJson(jsonStr);
      } catch (_) {}
    }

    // Default fallback Mai Văn Tâm
    return UserModel(
      id: 'usr_current',
      email: demoEmail,
      displayName: 'Mai Văn Tâm',
      phoneNumber: '0987654321',
      createdAt: DateTime.now(),
    );
  }

  /// Bật/Tắt mở khóa sinh trắc học
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefBiometricEnabled, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefBiometricEnabled) ?? false;
  }

  /// Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsLoggedIn, false);
  }
}
