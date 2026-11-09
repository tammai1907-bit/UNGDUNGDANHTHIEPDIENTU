import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/core/validators/auth_validators.dart';

void main() {
  group('AuthValidators Tests', () {
    test('validateEmail - hợp lệ và không hợp lệ', () {
      expect(AuthValidators.validateEmail('tammai1907@gmail.com'), isNull);
      expect(AuthValidators.validateEmail('user@gmail.com'), isNull);
      expect(AuthValidators.validateEmail(''), 'Vui lòng nhập địa chỉ email');
      expect(AuthValidators.validateEmail('tam.mai'), 'Địa chỉ email không đúng định dạng');
      expect(AuthValidators.validateEmail('tam@.com'), 'Địa chỉ email không đúng định dạng');
    });

    test('validatePassword - tối thiểu 8 ký tự, có chữ và số', () {
      expect(AuthValidators.validatePassword('Password123'), isNull);
      expect(AuthValidators.validatePassword('Abc12345'), isNull);
      expect(AuthValidators.validatePassword(''), 'Vui lòng nhập mật khẩu');
      expect(AuthValidators.validatePassword('short'), 'Mật khẩu phải có ít nhất 8 ký tự');
      expect(AuthValidators.validatePassword('passwordonly'), 'Mật khẩu phải bao gồm cả chữ cái và chữ số');
      expect(AuthValidators.validatePassword('1234567890'), 'Mật khẩu phải bao gồm cả chữ cái và chữ số');
    });

    test('validateConfirmPassword - trùng khớp', () {
      expect(AuthValidators.validateConfirmPassword('Password123', 'Password123'), isNull);
      expect(AuthValidators.validateConfirmPassword('', 'Password123'), 'Vui lòng xác nhận lại mật khẩu');
      expect(AuthValidators.validateConfirmPassword('Password456', 'Password123'), 'Mật khẩu xác nhận không trùng khớp');
    });

    test('validateFullName - tối thiểu 2 ký tự', () {
      expect(AuthValidators.validateFullName('Mai Văn Tâm'), isNull);
      expect(AuthValidators.validateFullName('An'), isNull);
      expect(AuthValidators.validateFullName(''), 'Vui lòng nhập họ và tên');
      expect(AuthValidators.validateFullName('A'), 'Họ và tên quá ngắn');
    });

    test('validateOtp - mã OTP 6 chữ số', () {
      expect(AuthValidators.validateOtp('123456'), isNull);
      expect(AuthValidators.validateOtp(''), 'Vui lòng nhập mã OTP');
      expect(AuthValidators.validateOtp('12345'), 'Mã OTP gồm đúng 6 chữ số');
      expect(AuthValidators.validateOtp('12345a'), 'Mã OTP gồm đúng 6 chữ số');
    });
  });
}
