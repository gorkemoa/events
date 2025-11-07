import 'dart:convert';
import 'dart:developer' as developer;
import '../models/login_models.dart';
import 'api_helper.dart';
import 'constants.dart';

/// Authentication service for handling login and auth operations
class AuthService {
  /// Login user with username and password
  /// 
  /// Returns [LoginResponse] with success status
  /// If status code is 200, login is successful
  /// If status code is 417, login failed with error message
  Future<LoginResponse> login({
    required String userName,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        userName: userName,
        password: password,
      );

      developer.log('🔐 Login Request', name: 'AuthService');
      developer.log('URL: ${ApiConstants.login}', name: 'AuthService');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'AuthService');

      final response = await ApiHelper.post(
        ApiConstants.login,
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'AuthService');
      developer.log('📥 Response Body: ${response.body}', name: 'AuthService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${loginResponse.success}', name: 'AuthService');
      if (!loginResponse.success) {
        developer.log('❌ Error Message: ${loginResponse.errorMessage}', name: 'AuthService');
      }
      
      return loginResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'AuthService', error: e, stackTrace: stackTrace);
      return LoginResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }
}
