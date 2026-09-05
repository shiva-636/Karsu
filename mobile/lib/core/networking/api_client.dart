import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl})
      : baseUrl = (baseUrl ??
              const String.fromEnvironment(
                'KARSU_API_URL',
                defaultValue: 'https://karsu.onrender.com/api',
              ))
          .replaceAll(RegExp(r'/+$'), '');

  final String baseUrl;

  String? token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) {
    return _request(
      () => http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> get(String path) {
    return _request(
      () => http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) {
    return _request(
      () => http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(String path) {
    return _request(
      () => http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      ),
    );
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(
        const Duration(seconds: 15),
      );

      dynamic decoded;

      if (response.body.isNotEmpty) {
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = <String, dynamic>{};
        }
      }

      decoded ??= <String, dynamic>{};

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final message = decoded is Map
            ? (decoded['message'] is List
                ? (decoded['message'] as List).join(', ')
                : decoded['message']?.toString() ??
                    'Request failed')
            : 'Request failed';

        throw ApiException(
          message,
          response.statusCode,
        );
      }

      return decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{'data': decoded};
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Unable to reach KARSU. Check your connection or API URL.',
        null,
      );
    }
  }
}

final apiClient = ApiClient();
