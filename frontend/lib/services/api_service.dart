import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

/// Single HTTP client for the REST API. Handles the JWT header, JSON and friendly errors.
class ApiService {
  static String? _token;
  static String? get token => _token;

  static Future<void> loadToken() async {
    _token = (await SharedPreferences.getInstance()).getString('token');
  }

  static Future<void> setToken(String? t) async {
    _token = t;
    final p = await SharedPreferences.getInstance();
    t == null ? await p.remove('token') : await p.setString('token', t);
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Uri _uri(String path, [Map<String, String>? q]) {
    final clean = Map<String, String>.from(q ?? {})..removeWhere((k, v) => v.isEmpty);
    return Uri.parse('${AppConfig.apiUrl}$path').replace(queryParameters: clean.isEmpty ? null : clean);
  }

  static Future<dynamic> _send(Future<http.Response> Function() call) async {
    try {
      final res = await call().timeout(const Duration(seconds: 20));
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) return body;
      final msg = (body is Map && body['message'] != null) ? body['message'].toString() : 'Request failed (${res.statusCode})';
      throw ApiException(msg, res.statusCode);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('Unexpected server response');
    } catch (_) {
      throw ApiException('Cannot reach the server. Check your connection and try again.');
    }
  }

  static Future<dynamic> get(String path, {Map<String, String>? query}) => _send(() => http.get(_uri(path, query), headers: _headers));
  static Future<dynamic> post(String path, Map<String, dynamic> body) => _send(() => http.post(_uri(path), headers: _headers, body: jsonEncode(body)));
  static Future<dynamic> put(String path, Map<String, dynamic> body) => _send(() => http.put(_uri(path), headers: _headers, body: jsonEncode(body)));
  static Future<dynamic> delete(String path) => _send(() => http.delete(_uri(path), headers: _headers));
}
