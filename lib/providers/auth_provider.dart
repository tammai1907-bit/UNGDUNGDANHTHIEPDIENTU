import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isBiometricEnabled = false;
  bool _canUseBiometrics = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get canUseBiometrics => _canUseBiometrics;

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    _canUseBiometrics = await AuthService.instance.canUseBiometrics();
    _isBiometricEnabled = await AuthService.instance.isBiometricEnabled();
    _currentUser = await AuthService.instance.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> loginWithBiometrics() async {
    final success = await AuthService.instance.authenticateWithBiometrics();
    if (success) {
      _currentUser = await AuthService.instance.getCurrentUser() ??
          UserModel(
            id: 'usr_biometric',
            email: 'tammai1907@gmail.com',
            displayName: 'Mai Văn Tâm',
            phoneNumber: '0987654321',
            createdAt: DateTime.now(),
          );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await AuthService.instance.loginWithEmail(email, password);
    _isLoading = false;
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    final success = await AuthService.instance.resetPassword(email, newPassword);
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> register(String name, String email, String password, {String? phone}) async {
    _isLoading = true;
    notifyListeners();

    final user = await AuthService.instance.register(name, email, password, phone: phone);
    _isLoading = false;
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await AuthService.instance.loginWithGoogle();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await AuthService.instance.verifyPhoneOtp(phone, otp);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleBiometric(bool enable) async {
    await AuthService.instance.setBiometricEnabled(enable);
    _isBiometricEnabled = enable;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _currentUser = null;
    notifyListeners();
  }
}
