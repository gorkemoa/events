import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';

/// API Helper for common HTTP operations with Basic Auth
class ApiHelper {
  /// Get common headers with Basic Auth
  static Map<String, String> getHeaders({Map<String, String>? additionalHeaders}) {
    final basicAuth = 'Basic ${base64Encode(
      utf8.encode('${ApiConstants.basicAuthUsername}:${ApiConstants.basicAuthPassword}')
    )}';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// POST request with Basic Auth
  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? additionalHeaders,
  }) async {
    return await http.post(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
      body: jsonEncode(body),
    );
  }

  /// GET request with Basic Auth
  static Future<http.Response> get(
    String url, {
    Map<String, String>? additionalHeaders,
  }) async {
    return await http.get(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
    );
  }

  /// PUT request with Basic Auth
  static Future<http.Response> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? additionalHeaders,
  }) async {
    return await http.put(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
      body: jsonEncode(body),
    );
  }

  /// DELETE request with Basic Auth
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? additionalHeaders,
  }) async {
    return await http.delete(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
    );
  }
}
