import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import '../models/user_models.dart';
import 'api_helper.dart';
import 'constants.dart';

/// User service for handling user operations
class UserService {
  /// Get user by ID
  /// 
  /// Returns [UserResponse] with user data
  /// If status code is 200, request is successful
  /// If status code is 417, request failed with error message
  Future<UserResponse> getUserById({
    required int userId,
    required String userToken,
  }) async {
    try {
      // Get platform info
      final platform = Platform.isIOS ? 'ios' : 'android';
      
      final request = GetUserRequest(
        userToken: userToken,
        version: '1.0.0',
        platform: platform,
      );

      developer.log('👤 Get User Request', name: 'UserService');
      developer.log('URL: ${ApiConstants.getUserById(userId)}', name: 'UserService');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'UserService');

      final response = await ApiHelper.put(
        ApiConstants.getUserById(userId),
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'UserService');
      developer.log('📥 Response Body: ${response.body}', name: 'UserService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final userResponse = UserResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${userResponse.success}', name: 'UserService');
      if (!userResponse.success) {
        developer.log('❌ Error Message: ${userResponse.errorMessage}', name: 'UserService');
      }
      
      return userResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'UserService', error: e, stackTrace: stackTrace);
      return UserResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }
}
