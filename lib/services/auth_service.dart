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

  /// Đăng nhập bằng Email & Mật khẩu
  Future<UserModel?> loginWithEmail(String email, String password) async {
    // Giả lập xác thực hoặc lấy user lưu trữ
    if (email.isEmpty || password.isEmpty) return null;

    final user = UserModel(
      id: 'usr_${email.hashCode.abs()}',
      email: email,
      displayName: (email == 'tam.mai@techcorp.vn' || email == 'an.nguyen@techcorp.vn')
          ? 'Mai Văn Tâm'
          : email.split('@').first,
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
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: name,
      phoneNumber: phone,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefUserKey, user.toJson());
    await prefs.setBool(_prefIsLoggedIn, true);

    return user;
  }

  /// Đăng nhập bằng Google
  Future<UserModel> loginWithGoogle() async {
    final user = UserModel(
      id: 'usr_google_demo',
      email: 'maivantam.tech@gmail.com',
      displayName: 'Mai Văn Tâm (Google)',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
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
      displayName: 'Khách hàng $phoneNumber',
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

    // Default fallback
    return UserModel(
      id: 'usr_current',
      email: 'tam.mai@techcorp.vn',
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
