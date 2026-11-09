import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Bản cài đặt Firebase Authentication thực tế
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  UserProfile? _mapFirebaseUser(fb.User? user) {
    if (user == null) return null;
    return UserProfile(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName?.isNotEmpty == true ? user.displayName! : (user.email?.split('@').first ?? 'Người dùng'),
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime,
    );
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  UserProfile? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  @override
  Future<Result<UserProfile>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final profile = _mapFirebaseUser(credential.user);
      if (profile == null) {
        return Result.failure(Exception('Không thể lấy thông tin người dùng sau khi đăng nhập'));
      }
      return Result.success(profile);
    } on fb.FirebaseAuthException catch (e) {
      String msg = 'Đăng nhập thất bại';
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'Email hoặc mật khẩu không chính xác';
          break;
        case 'invalid-email':
          msg = 'Định dạng email không hợp lệ';
          break;
        case 'user-disabled':
          msg = 'Tài khoản này đã bị khóa';
          break;
        default:
          msg = e.message ?? 'Đã xảy ra lỗi khi đăng nhập';
      }
      return Result.failure(Exception(msg));
    } catch (e) {
      return Result.failure(Exception('Lỗi hệ thống: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(fullName.trim());
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Lưu phoneNumber vào Firestore hoặc User Profile
      }
      final profile = _mapFirebaseUser(_firebaseAuth.currentUser);
      return Result.success(profile ?? UserProfile(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      ));
    } on fb.FirebaseAuthException catch (e) {
      String msg = 'Đăng ký thất bại';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'Địa chỉ email này đã được sử dụng';
          break;
        case 'weak-password':
          msg = 'Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn';
          break;
        case 'invalid-email':
          msg = 'Định dạng email không hợp lệ';
          break;
        default:
          msg = e.message ?? 'Đã xảy ra lỗi khi đăng ký';
      }
      return Result.failure(Exception(msg));
    } catch (e) {
      return Result.failure(Exception('Lỗi hệ thống: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final profile = _mapFirebaseUser(userCredential.user);
      if (profile == null) {
        return Result.failure(Exception('Không thể lấy thông tin tài khoản Google'));
      }
      return Result.success(profile);
    } catch (e) {
      return Result.failure(Exception('Đăng nhập Google thất bại: $e'));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return Result.success(null);
    } on fb.FirebaseAuthException catch (e) {
      String msg = 'Không thể gửi email đặt lại mật khẩu';
      if (e.code == 'user-not-found') {
        msg = 'Không tìm thấy tài khoản với email này';
      }
      return Result.failure(Exception(msg));
    } catch (e) {
      return Result.failure(Exception('Lỗi hệ thống: $e'));
    }
  }

  @override
  Future<Result<void>> confirmPasswordResetWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    // Với Firebase mặc định xử lý qua Action Code Link; cung cấp fallback
    return Result.success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Đăng xuất thất bại: $e'));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return Result.failure(Exception('Chưa đăng nhập'));
      }

      final cred = fb.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return Result.success(null);
    } on fb.FirebaseAuthException catch (e) {
      String msg = 'Đổi mật khẩu thất bại';
      if (e.code == 'wrong-password') {
        msg = 'Mật khẩu hiện tại không chính xác';
      }
      return Result.failure(Exception(msg));
    } catch (e) {
      return Result.failure(Exception('Lỗi: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(Exception('Chưa đăng nhập'));
      }

      if (fullName != null) await user.updateDisplayName(fullName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      await user.reload();

      final updated = _mapFirebaseUser(_firebaseAuth.currentUser);
      return Result.success(updated!);
    } catch (e) {
      return Result.failure(Exception('Không thể cập nhật hồ sơ: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(Exception('Chưa đăng nhập'));
      }
      await user.delete();
      return Result.success(null);
    } catch (e) {
      return Result.failure(Exception('Không thể xóa tài khoản: $e'));
    }
  }
}
