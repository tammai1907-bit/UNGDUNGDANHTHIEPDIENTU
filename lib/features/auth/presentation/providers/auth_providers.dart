import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../card_design/presentation/providers/card_repository_provider.dart' show useMockDataProvider;
import '../../data/repositories/fake_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

/// Provider cung cấp phiên bản AuthRepository (Fake hoặc Firebase) tùy theo cờ useMockData
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  if (useMock) {
    return FakeAuthRepository(startLoggedIn: false);
  }
  return FirebaseAuthRepository();
});

/// Luồng Stream lắng nghe trạng thái đăng nhập thời gian thực
final authStateStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Provider lưu giữ thông tin người dùng đang đăng nhập
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  final asyncUser = ref.watch(authStateStreamProvider);
  return asyncUser.value;
});

/// Controller quản lý các tác vụ Authentication
class AuthController extends StateNotifier<AsyncValue<UserProfile?>> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AsyncValue.data(null));

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _repo.signInWithEmailPassword(email: email, password: password);
    return res.when(
      success: (user) {
        state = AsyncValue.data(user);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    final res = await _repo.signUpWithEmailPassword(
      email: email,
      password: password,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
    return res.when(
      success: (user) {
        state = AsyncValue.data(user);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final res = await _repo.signInWithGoogle();
    return res.when(
      success: (user) {
        state = AsyncValue.data(user);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    final res = await _repo.sendPasswordResetEmail(email);
    return res.when(
      success: (_) => true,
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> confirmPasswordResetWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await _repo.confirmPasswordResetWithOtp(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );
    return res.when(
      success: (_) => true,
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> signOut() async {
    state = const AsyncValue.loading();
    final res = await _repo.signOut();
    return res.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    final res = await _repo.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );
    return res.when(
      success: (updated) {
        state = AsyncValue.data(updated);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return res.when(
      success: (_) => true,
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> deleteAccount() async {
    state = const AsyncValue.loading();
    final res = await _repo.deleteAccount();
    return res.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (err) {
        state = AsyncValue.error(err, StackTrace.current);
        return false;
      },
    );
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserProfile?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
