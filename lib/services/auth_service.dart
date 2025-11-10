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

  /// Register a new user
  /// 
  /// Returns [RegisterResponse] with success status
  /// If status code is 200, registration is successful
  /// If status code is 417, registration failed with error message
  Future<RegisterResponse> register({
    required String userFirstname,
    required String userLastname,
    required String userName,
    required String userEmail,
    required String userPassword,
    required String version,
    required String platform,
  }) async {
    try {
      final request = RegisterRequest(
        userFirstname: userFirstname,
        userLastname: userLastname,
        userName: userName,
        userEmail: userEmail,
        userPassword: userPassword,
        version: version,
        platform: platform,
      );

      developer.log('📝 Register Request', name: 'AuthService');
      developer.log('URL: ${ApiConstants.register}', name: 'AuthService');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'AuthService');

      final response = await ApiHelper.post(
        ApiConstants.register,
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'AuthService');
      developer.log('📥 Response Body: ${response.body}', name: 'AuthService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final registerResponse = RegisterResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${registerResponse.success}', name: 'AuthService');
      if (!registerResponse.success) {
        developer.log('❌ Error Message: ${registerResponse.errorMessage}', name: 'AuthService');
      } else {
        developer.log('✅ Success Message: ${registerResponse.successMessage}', name: 'AuthService');
      }
      
      return registerResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'AuthService', error: e, stackTrace: stackTrace);
      return RegisterResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Verify code from email
  /// 
  /// Returns [CodeVerificationResponse] with success status
  /// If verification succeeds, returns userID and userToken
  Future<CodeVerificationResponse> verifyCode({
    required String code,
    required String codeToken,
  }) async {
    try {
      final request = CodeVerificationRequest(
        code: code,
        codeToken: codeToken,
      );

      developer.log('✉️ Code Verification Request', name: 'AuthService');
      developer.log('URL: ${ApiConstants.checkCode}', name: 'AuthService');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'AuthService');

      final response = await ApiHelper.post(
        ApiConstants.checkCode,
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'AuthService');
      developer.log('📥 Response Body: ${response.body}', name: 'AuthService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final verificationResponse = CodeVerificationResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${verificationResponse.success}', name: 'AuthService');
      if (!verificationResponse.success) {
        developer.log('❌ Error Message: ${verificationResponse.errorMessage}', name: 'AuthService');
      } else {
        developer.log('✅ Success Message: ${verificationResponse.successMessage}', name: 'AuthService');
      }
      
      return verificationResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'AuthService', error: e, stackTrace: stackTrace);
      return CodeVerificationResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Resend verification code
  /// 
  /// Returns [ResendCodeResponse] with new codeToken
  /// If successful, returns new codeToken to verify with
  Future<ResendCodeResponse> resendCode({
    required String userToken,
  }) async {
    try {
      final request = ResendCodeRequest(
        userToken: userToken,
      );

      developer.log('📧 Resend Code Request', name: 'AuthService');
      developer.log('URL: ${ApiConstants.resendCode}', name: 'AuthService');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'AuthService');

      final response = await ApiHelper.post(
        ApiConstants.resendCode,
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'AuthService');
      developer.log('📥 Response Body: ${response.body}', name: 'AuthService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final resendResponse = ResendCodeResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${resendResponse.success}', name: 'AuthService');
      if (!resendResponse.success) {
        developer.log('❌ Error Message: ${resendResponse.errorMessage}', name: 'AuthService');
      } else {
        developer.log('✅ Success Message: ${resendResponse.message}', name: 'AuthService');
        developer.log('✅ New CodeToken: ${resendResponse.data?.codeToken}', name: 'AuthService');
      }
      
      return resendResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'AuthService', error: e, stackTrace: stackTrace);
      return ResendCodeResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }
}
