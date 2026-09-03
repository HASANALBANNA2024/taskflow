import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// URL জোড়া লাগানোর সময় ডাবল স্ল্যাশ (//) এরর প্রতিরোধ করে
  Uri _uri(String path) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$cleanBase$cleanPath');
  }

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
      if (res.statusCode == 404) {
        throw ApiException(
            'Endpoint/URL পাওয়া যায়নি (404)। ইমেইল বা ওটিপি খালি যাচ্ছে কি না তা পরীক্ষা করুন।');
      }
      throw ApiException(
          'Unexpected response from server (${res.statusCode}).');
    }

    final status = body['status'];
    if (status == 'fail' || res.statusCode >= 400) {
      final data = body['data'];
      final msg = data is String
          ? data
          : (body['message']?.toString() ?? 'Something went wrong.');
      throw ApiException(msg);
    }
    return body;
  }

  Future<Map<String, dynamic>> get(String path, {bool withToken = true}) async {
    final url = _uri(path);
    if (kDebugMode) {
      print('--> GET Request URL: $url');
    }
    if (kDebugMode) print('--> GET Request URL: $url');
    final res =
        await http.get(url, headers: await _headers(withToken: withToken));
    if (kDebugMode) {
      print('--> GET Response: ${res.body}');
    }
    return _unwrap(res);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withToken = true,
  }) async {
    final url = _uri(path);
    if (kDebugMode) print('--> POST Request URL: $url');
    final res = await http.post(
      url,
      headers: await _headers(withToken: withToken),
      body: body != null ? jsonEncode(body) : null,
    );
    return _unwrap(res);
  }
}
