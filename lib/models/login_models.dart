/// Request model for login
class LoginRequest {
  final String userName;
  final String password;

  LoginRequest({
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'password': password,
    };
  }
}

/// Response model for login
class LoginResponse {
  final bool error;
  final bool success;
  final LoginData? data;
  final String? errorMessage;
  final String statusCode;

  LoginResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Login data model
class LoginData {
  final String status;
  final String message;
  final int userId;
  final String token;

  LoginData({
    required this.status,
    required this.message,
    required this.userId,
    required this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      userId: json['userID'] ?? 0,
      token: json['token'] ?? '',
    );
  }
}
