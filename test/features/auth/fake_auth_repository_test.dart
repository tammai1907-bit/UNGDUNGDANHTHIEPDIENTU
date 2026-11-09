import 'package:flutter_test/flutter_test.dart';
import 'package:digital_business_card/features/auth/data/repositories/fake_auth_repository.dart';

void main() {
  group('FakeAuthRepository Tests', () {
    late FakeAuthRepository authRepo;
    final demoEmail = FakeAuthRepository.demoUser.email;
    const demoPassword = FakeAuthRepository.demoPassword;

    setUp(() {
      authRepo = FakeAuthRepository(startLoggedIn: false);
    });

    test('Đăng nhập với tài khoản demo thành công', () async {
      final result = await authRepo.signInWithEmailPassword(
        email: demoEmail,
        password: demoPassword,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.email, demoEmail);
      expect(result.dataOrNull?.fullName, 'Mai Văn Tâm');
      expect(authRepo.currentUser?.email, demoEmail);
    });

    test('Đăng nhập sai mật khẩu báo lỗi', () async {
      final result = await authRepo.signInWithEmailPassword(
        email: demoEmail,
        password: 'wrong_password',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, contains('Email hoặc mật khẩu không chính xác'));
    });

    test('Đăng ký tài khoản mới và đăng nhập', () async {
      final signUpResult = await authRepo.signUpWithEmailPassword(
        email: 'newuser@test.vn',
        password: 'Password123',
        fullName: 'Nguyễn Văn Test',
        phoneNumber: '0901234567',
      );

      expect(signUpResult.isSuccess, isTrue);
      expect(signUpResult.dataOrNull?.fullName, 'Nguyễn Văn Test');
      expect(authRepo.currentUser?.email, 'newuser@test.vn');

      // Đăng xuất
      await authRepo.signOut();
      expect(authRepo.currentUser, isNull);

      // Đăng nhập lại
      final loginResult = await authRepo.signInWithEmailPassword(
        email: 'newuser@test.vn',
        password: 'Password123',
      );
      expect(loginResult.isSuccess, isTrue);
    });

    test('Đăng ký trùng email báo lỗi', () async {
      final result = await authRepo.signUpWithEmailPassword(
        email: demoEmail,
        password: 'Password123',
        fullName: 'Mai Văn Tâm',
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, contains('đã được đăng ký'));
    });

    test('Quên mật khẩu và xác thực OTP mock 123456', () async {
      final sendOtpResult = await authRepo.sendPasswordResetEmail(demoEmail);
      expect(sendOtpResult.isSuccess, isTrue);

      final wrongOtpResult = await authRepo.confirmPasswordResetWithOtp(
        email: demoEmail,
        otp: '999999',
        newPassword: 'NewPassword456',
      );
      expect(wrongOtpResult.isFailure, isTrue);

      final rightOtpResult = await authRepo.confirmPasswordResetWithOtp(
        email: demoEmail,
        otp: '123456',
        newPassword: 'NewPassword456',
      );
      expect(rightOtpResult.isSuccess, isTrue);

      // Đăng nhập với mật khẩu mới
      final loginResult = await authRepo.signInWithEmailPassword(
        email: demoEmail,
        password: 'NewPassword456',
      );
      expect(loginResult.isSuccess, isTrue);
    });

    test('Cập nhật thông tin hồ sơ và đổi mật khẩu', () async {
      await authRepo.signInWithEmailPassword(
        email: demoEmail,
        password: demoPassword,
      );

      final updateResult = await authRepo.updateProfile(
        fullName: 'Mai Văn Tâm (Updated)',
        phoneNumber: '0988888888',
      );
      expect(updateResult.isSuccess, isTrue);
      expect(authRepo.currentUser?.fullName, 'Mai Văn Tâm (Updated)');
      expect(authRepo.currentUser?.phoneNumber, '0988888888');

      // Đổi mật khẩu
      final changePwResult = await authRepo.changePassword(
        currentPassword: demoPassword,
        newPassword: 'Password789',
      );
      expect(changePwResult.isSuccess, isTrue);
    });
  });
}
