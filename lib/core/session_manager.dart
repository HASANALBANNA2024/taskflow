import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token and the logged-in user's email across app
/// restarts, backed by shared_preferences.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  Future<void> saveSession({required String token, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
  }
}
