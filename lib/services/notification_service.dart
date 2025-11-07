import 'dart:convert';
import 'dart:developer' as developer;
import '../models/notification_models.dart';
import 'api_helper.dart';
import 'constants.dart';

/// Notification service for handling notification operations
class NotificationService {
  /// Get notifications for user
  /// 
  /// Returns [NotificationsResponse] with notifications list
  /// If status code is 200, request is successful
  /// If status code is 417, request failed with error message
  Future<NotificationsResponse> getNotifications({
    required int userId,
  }) async {
    try {
      developer.log('🔔 Get Notifications Request', name: 'NotificationService');
      developer.log('URL: ${ApiConstants.getNotifications(userId)}', name: 'NotificationService');

      final response = await ApiHelper.get(
        ApiConstants.getNotifications(userId),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'NotificationService');
      developer.log('📥 Response Body: ${response.body}', name: 'NotificationService');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final notificationsResponse = NotificationsResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${notificationsResponse.success}', name: 'NotificationService');
      developer.log('📊 Notifications count: ${notificationsResponse.data?.notifications.length ?? 0}', name: 'NotificationService');
      
      if (!notificationsResponse.success) {
        developer.log('❌ Error Message: ${notificationsResponse.errorMessage}', name: 'NotificationService');
      }
      
      return notificationsResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'NotificationService', error: e, stackTrace: stackTrace);
      return NotificationsResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }
}
