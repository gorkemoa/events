import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'navigation_service.dart';
import 'storage_helper.dart';
import 'dart:developer' as developer;

/// API Helper for common HTTP operations with Basic Auth
class ApiHelper {
  /// Handle 403 Forbidden responses by clearing session and redirecting to login
  static Future<void> _handle403() async {
    developer.log('🚫 403 Forbidden - Redirecting to login', name: 'ApiHelper');
    await StorageHelper.clearUserSession();
    await NavigationService.navigateToLogin();
  }

  /// Check response status and handle 403
  static Future<void> _checkResponse(http.Response response) async {
    if (response.statusCode == 403) {
      await _handle403();
    }
  }
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
    final response = await http.post(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
      body: jsonEncode(body),
    );
    
    await _checkResponse(response);
    return response;
  }

  /// GET request with Basic Auth
  static Future<http.Response> get(
    String url, {
    Map<String, String>? additionalHeaders,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
    );
    
    await _checkResponse(response);
    return response;
  }

  /// PUT request with Basic Auth
  static Future<http.Response> put(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? additionalHeaders,
  }) async {
    final response = await http.put(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
      body: jsonEncode(body),
    );
    
    await _checkResponse(response);
    return response;
  }

  /// DELETE request with Basic Auth
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? additionalHeaders,
  }) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: getHeaders(additionalHeaders: additionalHeaders),
    );
    
    await _checkResponse(response);
    return response;
  }
}
