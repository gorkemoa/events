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

  /// Update user information
  /// 
  /// Returns [UpdateUserResponse] with success status
  /// If status code is 200, update is successful
  /// If status code is 417, update failed with error message
  Future<UpdateUserResponse> updateUser({
    required int userId,
    required UpdateUserRequest request,
  }) async {
    try {
      developer.log('✏️ Update User Request', name: 'UserService');
      developer.log('URL: ${ApiConstants.updateUser(userId)}', name: 'UserService');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'UserService');

      final response = await ApiHelper.put(
        ApiConstants.updateUser(userId),
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'UserService');
      developer.log('📥 Response Body: ${response.body}', name: 'UserService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final updateResponse = UpdateUserResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${updateResponse.success}', name: 'UserService');
      if (!updateResponse.success) {
        developer.log('❌ Error Message: ${updateResponse.errorMessage}', name: 'UserService');
      }
      
      return updateResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'UserService', error: e, stackTrace: stackTrace);
      return UpdateUserResponse(
        error: true,
        success: false,
        message: '',
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Update user password
  /// 
  /// Returns [UpdatePasswordResponse] with success status
  /// If status code is 200, password update is successful
  /// If status code is 417, password update failed with error message
  Future<UpdatePasswordResponse> updatePassword({
    required UpdatePasswordRequest request,
  }) async {
    try {
      developer.log('🔐 Update Password Request', name: 'UserService');
      developer.log('URL: ${ApiConstants.updatePassword()}', name: 'UserService');
      developer.log('Body: (password fields hidden)', name: 'UserService');

      final response = await ApiHelper.put(
        ApiConstants.updatePassword(),
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'UserService');
      developer.log('📥 Response Body: ${response.body}', name: 'UserService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final passwordResponse = UpdatePasswordResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${passwordResponse.success}', name: 'UserService');
      if (!passwordResponse.success) {
        developer.log('❌ Error Message: ${passwordResponse.errorMessage}', name: 'UserService');
      }
      
      return passwordResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'UserService', error: e, stackTrace: stackTrace);
      return UpdatePasswordResponse(
        error: true,
        success: false,
        message: '',
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }
}
