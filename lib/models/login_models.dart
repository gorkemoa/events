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

/// Request model for register
class RegisterRequest {
  final String userFirstname;
  final String userLastname;
  final String userName;
  final String userEmail;
  final String userPassword;
  final String version;
  final String platform;

  RegisterRequest({
    required this.userFirstname,
    required this.userLastname,
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.version,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userName': userName,
      'userEmail': userEmail,
      'userPassword': userPassword,
      'version': version,
      'platform': platform,
    };
  }
}

/// Response model for register
class RegisterResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final String? errorMessage;
  final RegisterData? data;
  final String statusCode;

  RegisterResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.errorMessage,
    this.data,
    required this.statusCode,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Register data model
class RegisterData {
  final int userID;
  final String userToken;
  final String codeToken;

  RegisterData({
    required this.userID,
    required this.userToken,
    required this.codeToken,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userID: json['userID'] ?? 0,
      userToken: json['userToken'] ?? '',
      codeToken: json['codeToken'] ?? '',
    );
  }
}
