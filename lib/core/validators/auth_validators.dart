/// Bộ kiểm tra tính hợp lệ cho Phân hệ Xác thực & Tài khoản
class AuthValidators {
  /// Kiểm tra định dạng Email chuẩn
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Địa chỉ email không đúng định dạng';
    }
    return null;
  }

  /// Kiểm tra mật khẩu: tối thiểu 8 ký tự, gồm ít nhất 1 chữ cái và 1 số
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasLetter || !hasDigit) {
      return 'Mật khẩu phải bao gồm cả chữ cái và chữ số';
    }
    return null;
  }

  /// Kiểm tra xác nhận mật khẩu
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không trùng khớp';
    }
    return null;
  }

  /// Kiểm tra họ tên
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên quá ngắn';
    }
    return null;
  }

  /// Kiểm tra mã OTP 6 số
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mã OTP';
    }
    if (value.trim().length != 6 || !RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Mã OTP gồm đúng 6 chữ số';
    }
    return null;
  }
}
