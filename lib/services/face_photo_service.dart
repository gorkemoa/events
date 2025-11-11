import 'dart:convert';
import 'dart:developer' as developer;
import '../models/user_models.dart';
import 'api_helper.dart';
import 'constants.dart';

/// Face photo service for handling face verification photo operations
class FacePhotoService {
  /// Upload face verification photos (first time)
  /// 
  /// Returns [FacePhotoResponse] with success status
  /// If status code is 200/201, upload is successful
  /// If status code is 417, upload failed with error message
  Future<FacePhotoResponse> addFacePhotos({
    required FacePhotoRequest request,
  }) async {
    try {
      developer.log('📸 Add Face Photos Request', name: 'FacePhotoService');
      developer.log('URL: ${ApiConstants.baseUrl}service/user/account/photo/add', name: 'FacePhotoService');

      final response = await ApiHelper.post(
        '${ApiConstants.baseUrl}service/user/account/photo/add',
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'FacePhotoService');
      developer.log('📥 Response Body: ${response.body}', name: 'FacePhotoService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final photoResponse = FacePhotoResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${photoResponse.success}', name: 'FacePhotoService');
      if (!photoResponse.success) {
        developer.log('❌ Error Message: ${photoResponse.errorMessage}', name: 'FacePhotoService');
      }
      
      return photoResponse;
    } catch (e, stackTrace) {
      developer.log('❌ Exception occurred', name: 'FacePhotoService', error: e, stackTrace: stackTrace);
      return FacePhotoResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Update face verification photos
  /// 
  /// Returns [FacePhotoResponse] with success status
  /// If status code is 200/201, update is successful
  /// If status code is 417, update failed with error message
  Future<FacePhotoResponse> updateFacePhotos({
    required FacePhotoRequest request,
  }) async {
    try {
      developer.log('🔄 Update Face Photos Request', name: 'FacePhotoService');
      developer.log('URL: ${ApiConstants.baseUrl}service/user/account/photo/update', name: 'FacePhotoService');

      final response = await ApiHelper.put(
        '${ApiConstants.baseUrl}service/user/account/photo/update',
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'FacePhotoService');
      developer.log('📥 Response Body: ${response.body}', name: 'FacePhotoService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final photoResponse = FacePhotoResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${photoResponse.success}', name: 'FacePhotoService');
      if (!photoResponse.success) {
        developer.log('❌ Error Message: ${photoResponse.errorMessage}', name: 'FacePhotoService');
      }
      
      return photoResponse;
    } catch (e, stackTrace) {
      developer.log('❌ Exception occurred', name: 'FacePhotoService', error: e, stackTrace: stackTrace);
      return FacePhotoResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Get user's face verification photos
  /// 
  /// Returns [GetFacePhotosResponse] with photo URLs
  /// If status code is 200, request is successful
  /// If status code is 417, request failed with error message
  Future<GetFacePhotosResponse> getFacePhotos({
    required String userToken,
  }) async {
    try {
      developer.log('📷 Get Face Photos Request', name: 'FacePhotoService');
      developer.log('URL: ${ApiConstants.baseUrl}service/user/account/photo/all?userToken=$userToken', name: 'FacePhotoService');

      final response = await ApiHelper.get(
        '${ApiConstants.baseUrl}service/user/account/photo/all?userToken=$userToken',
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'FacePhotoService');
      developer.log('📥 Response Body: ${response.body}', name: 'FacePhotoService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final photosResponse = GetFacePhotosResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${photosResponse.success}', name: 'FacePhotoService');
      if (!photosResponse.success) {
        developer.log('❌ Error Message: ${photosResponse.errorMessage}', name: 'FacePhotoService');
      }
      
      return photosResponse;
    } catch (e, stackTrace) {
      developer.log('❌ Exception occurred', name: 'FacePhotoService', error: e, stackTrace: stackTrace);
      return GetFacePhotosResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }
}
