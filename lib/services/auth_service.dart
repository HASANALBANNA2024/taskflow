import '../core/api_client.dart';
import '../models/user_model.dart';

/// Wraps the "User Auth" folder of the Postman collection:
/// Registration, Login, ProfileUpdate, ProfileDetails,
/// RecoverVerifyEmail, RecoverVerifyOtp, RecoverResetPassword.
class AuthService {
  final ApiClient _api = ApiClient.instance;

  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    required String password,
  }) async {
    final res = await _api.post(
      '/Registration',
      withToken: false,
      body: {
        'email': email.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'mobile': mobile.trim(),
        'password': password.trim(),
      },
    );

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Registration failed');
    }

    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Returns the JWT token on success. Caller is responsible for
  /// persisting it via SessionManager.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      '/Login',
      withToken: false,
      body: {
        'email': email.trim(),
        'password': password.trim(),
      },
    );

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Login failed');
    }

    return res['token']?.toString() ?? '';
  }

  Future<UserModel> fetchProfile() async {
    final res = await _api.get('/ProfileDetails');

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Failed to fetch profile');
    }

    final data = res['data'];
    final userJson = data is List
        ? data.first as Map<String, dynamic>
        : data as Map<String, dynamic>;

    return UserModel.fromJson(userJson);
  }

  Future<void> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    String? password,
  }) async {
    final res = await _api.post(
      '/ProfileUpdate',
      body: {
        'email': email.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'mobile': mobile.trim(),
        if (password != null && password.isNotEmpty)
          'password': password.trim(),
      },
    );

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Failed to update profile');
    }
  }

  /// Step 1 of forgot-password: sends an OTP to the given email.
  Future<void> requestPasswordRecoveryOtp(String email) async {
    final cleanEmail = email.trim();
    final res = await _api.get(
      '/RecoverVerifyEmail/$cleanEmail',
      withToken: false,
    );

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Failed to send OTP');
    }
  }

  /// Step 2: verifies the OTP the user received by email.
  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();

    final res = await _api.get(
      '/RecoverVerifyOtp/$cleanEmail/$cleanOtp',
      withToken: false,
    );

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Invalid OTP');
    }
  }

  /// Step 3: sets a new password once the OTP has been verified.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final res = await _api.post(
      '/RecoverResetPassword',
      withToken: false,
      body: {
        'email': email.trim(),
        'OTP': otp.trim(), // Postman অনুযায়ী ক্যাপিটাল 'OTP'
        'password': newPassword.trim(),
      },
    );

    if (res['status'] != 'success') {
      throw Exception(res['data'] ?? 'Failed to reset password');
    }
  }
}
