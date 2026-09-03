import 'package:flutter/foundation.dart';

import '../core/session_manager.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  /// Checked once on app start to decide Splash → Home vs Splash → Login.
  Future<void> restoreSession() async {
    final hasSession = await SessionManager.instance.hasSession();
    if (!hasSession) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      currentUser = await _authService.fetchProfile();
      status = AuthStatus.authenticated;
    } catch (_) {
      await SessionManager.instance.clear();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _run(() async {
      final token = await _authService.login(email: email, password: password);
      if (token.isEmpty) {
        throw Exception('Login did not return a session token.');
      }
      await SessionManager.instance.saveSession(token: token, email: email);
      currentUser = await _authService.fetchProfile();
      status = AuthStatus.authenticated;
    });
  }

  Future<bool> register({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    required String password,
  }) async {
    return _run(() async {
      await _authService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        password: password,
      );
    });
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
    String? password,
  }) async {
    return _run(() async {
      final email = currentUser!.email;
      await _authService.updateProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
        password: password,
      );
      currentUser = await _authService.fetchProfile();
    });
  }

  Future<bool> requestOtp(String email) =>
      _run(() => _authService.requestPasswordRecoveryOtp(email));

  Future<bool> verifyOtp({required String email, required String otp}) =>
      _run(() => _authService.verifyRecoveryOtp(email: email, otp: otp));

  /// ✅ FIXED: Added confirmPassword parameter
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword, // ✅ NEW PARAMETER
  }) =>
      _run(() => _authService.resetPassword(
            email: email,
            otp: otp,
            newPassword: newPassword,
            confirmPassword: confirmPassword, // ✅ PASS TO SERVICE
          ));

  Future<void> logout() async {
    await SessionManager.instance.clear();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Runs [action], centralising loading/error state so every screen
  /// doesn't have to repeat the same try/catch/setState dance.
  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
