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
      throw ApiException(res['data']?.toString() ?? 'Registration failed');
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
      throw ApiException(res['data']?.toString() ?? 'Login failed');
    }

    return res['token']?.toString() ?? '';
  }

  Future<UserModel> fetchProfile() async {
    final res = await _api.get('/ProfileDetails');

    if (res['status'] != 'success') {
      throw ApiException(res['data']?.toString() ?? 'Failed to fetch profile');
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
        if (password != null && password.trim().isNotEmpty)
          'password': password.trim(),
      },
    );

    if (res['status'] != 'success') {
      throw ApiException(res['data']?.toString() ?? 'Failed to update profile');
    }
  }

  /// Step 1 of forgot-password: sends an OTP to the given email.
  Future<void> requestPasswordRecoveryOtp(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw ApiException('ইমেইল খালি রাখা যাবে না');
    }

    final res = await _api.get(
      '/RecoverVerifyEmail/$cleanEmail',
      withToken: false,
    );

    if (res['status'] != 'success') {
      throw ApiException(res['data']?.toString() ?? 'Failed to send OTP');
    }
  }

  /// Step 2: verifies the OTP the user received by email.
  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();

    if (cleanEmail.isEmpty || cleanOtp.isEmpty) {
      throw ApiException('ইমেইল অথবা ওটিপি খালি রাখা যাবে না');
    }

    final res = await _api.get(
      '/RecoverVerifyOtp/$cleanEmail/$cleanOtp',
      withToken: false,
    );

    if (res['status'] != 'success') {
      throw ApiException(res['data']?.toString() ?? 'Invalid OTP');
    }
  }

  /// Step 3: sets a new password once the OTP has been verified.
  /// ✅ FIXED: confirmPassword নেবে কিন্তু API তে পাঠাবো না
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword, // ✅ Local validation এর জন্য
  }) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();
    final cleanPassword = newPassword.trim();
    final cleanConfirmPassword = confirmPassword.trim();

    // ✅ সকল field validate করো
    if (cleanEmail.isEmpty ||
        cleanOtp.isEmpty ||
        cleanPassword.isEmpty ||
        cleanConfirmPassword.isEmpty) {
      throw ApiException('সকল তথ্য সঠিকভাবে পূরণ করুন');
    }

    // ✅ দুটো password match করছে কিনা check করো
    if (cleanPassword != cleanConfirmPassword) {
      throw ApiException('নতুন password এবং confirm password একই নয়');
    }

    // ✅ Password strength check (minimum 4 characters)
    if (cleanPassword.length < 4) {
      throw ApiException('Password অন্তত ৪ টি ক্যারেক্টার এর হতে হবে');
    }

    // ✅ শুধু 3টি field পাঠাও (email, OTP, password)
    final res = await _api.post(
      '/RecoverResetPassword',
      withToken: false,
      body: {
        'email': cleanEmail,
        'OTP': cleanOtp,
        'password': cleanPassword,
        // ❌ confirmPassword এখানে নেই - শুধু backend এ password যাবে
      },
    );

    if (res['status'] != 'success') {
      throw ApiException(res['data']?.toString() ?? 'Failed to reset password');
    }
  }
}
