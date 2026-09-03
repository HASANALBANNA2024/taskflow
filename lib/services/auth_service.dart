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
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'password': password,
      },
    );
    return UserModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /// Returns the JWT token on success. Caller is responsible for
  /// persisting it via SessionManager.
  Future<String> login({required String email, required String password}) async {
    final res = await _api.post(
      '/Login',
      withToken: false,
      body: {'email': email, 'password': password},
    );
    return res['token']?.toString() ?? '';
  }

  Future<UserModel> fetchProfile() async {
    final res = await _api.get('/ProfileDetails');
    final data = res['data'];
    final userJson = data is List ? data.first as Map<String, dynamic> : data as Map<String, dynamic>;
    return UserModel.fromJson(userJson);
  }

  Future<void> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    String? password,
  }) async {
    await _api.post(
      '/ProfileUpdate',
      body: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        if (password != null && password.isNotEmpty) 'password': password,
      },
    );
  }

  /// Step 1 of forgot-password: sends an OTP to the given email.
  Future<void> requestPasswordRecoveryOtp(String email) async {
    await _api.get('/RecoverVerifyEmail/$email', withToken: false);
  }

  /// Step 2: verifies the OTP the user received by email.
  Future<void> verifyRecoveryOtp({required String email, required String otp}) async {
    await _api.get('/RecoverVerifyOtp/$email/$otp', withToken: false);
  }

  /// Step 3: sets a new password once the OTP has been verified.
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _api.post(
      '/RecoverResetPassword',
      withToken: false,
      body: {'email': email, 'OTP': otp, 'password': newPassword},
    );
  }
}
