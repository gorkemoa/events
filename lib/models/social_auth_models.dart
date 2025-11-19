/// Request model for social login (Google/Apple)
class SocialLoginRequest {
  final String platform;
  final String deviceID;
  final String devicePlatform;
  final String version;
  final String accessToken;
  final String fcmToken;
  final String idToken;

  SocialLoginRequest({
    required this.platform,
    required this.deviceID,
    required this.devicePlatform,
    required this.version,
    required this.accessToken,
    required this.fcmToken,
    required this.idToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'deviceID': deviceID,
      'devicePlatform': devicePlatform,
      'version': version,
      'accessToken': accessToken,
      'fcmToken': fcmToken,
      'idToken': idToken,
    };
  }
}

/// Response model for social login
class SocialLoginResponse {
  final bool error;
  final bool success;
  final SocialLoginData? data;
  final String? errorMessage;
  final String statusCode;

  SocialLoginResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory SocialLoginResponse.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? SocialLoginData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Social login data model
class SocialLoginData {
  final String status;
  final String message;
  final int userId;
  final String token;

  SocialLoginData({
    required this.status,
    required this.message,
    required this.userId,
    required this.token,
  });

  factory SocialLoginData.fromJson(Map<String, dynamic> json) {
    return SocialLoginData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      userId: json['userID'] ?? 0,
      token: json['token'] ?? '',
    );
  }
}
