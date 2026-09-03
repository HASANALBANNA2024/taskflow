import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';


class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}


class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();
  static const String baseUrl = 'https://task.teamrabbil.com/api/v1';
  Uri _uri(String path) => Uri.parse('$baseUrl$path');
  Future<Map<String, String>> _headers({bool withToken = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withToken) {
      final token = await SessionManager.instance.getToken();
      if (token != null && token.isNotEmpty) {
        headers['token'] = token;
      }
    }
    return headers;
  }

  Map<String, dynamic> _unwrap(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Unexpected response from server (${res.statusCode}).');
    }

    final status = body['status'];
    if (status == 'fail' || res.statusCode >= 400) {
      final data = body['data'];
      final msg = data is String ? data : (body['message']?.toString() ?? 'Something went wrong.');
      throw ApiException(msg);
    }
    return body;
  }

  Future<Map<String, dynamic>> get(String path, {bool withToken = true}) async {
    final res = await http.get(_uri(path), headers: await _headers(withToken: withToken));
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withToken = true,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(withToken: withToken),
      body: body != null ? jsonEncode(body) : null,
    );
    return _unwrap(res);
  }
}
