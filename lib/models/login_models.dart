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

/// Request model for code verification
class CodeVerificationRequest {
  final String code;
  final String codeToken;

  CodeVerificationRequest({
    required this.code,
    required this.codeToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'codeToken': codeToken,
    };
  }
}

/// Response model for code verification
class CodeVerificationResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final String? errorMessage;
  final CodeVerificationData? data;
  final String statusCode;

  CodeVerificationResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.errorMessage,
    this.data,
    required this.statusCode,
  });

  factory CodeVerificationResponse.fromJson(Map<String, dynamic> json) {
    return CodeVerificationResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? CodeVerificationData.fromJson(json['data']) : null,
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Code verification data model
class CodeVerificationData {
  final int userID;
  final String userToken;

  CodeVerificationData({
    required this.userID,
    required this.userToken,
  });

  factory CodeVerificationData.fromJson(Map<String, dynamic> json) {
    return CodeVerificationData(
      userID: json['userID'] ?? 0,
      userToken: json['userToken'] ?? '',
    );
  }
}

/// Request model for resending code
class ResendCodeRequest {
  final String userToken;

  ResendCodeRequest({
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
    };
  }
}

/// Response model for resending code
class ResendCodeResponse {
  final bool error;
  final bool success;
  final String? message;
  final String? errorMessage;
  final ResendCodeData? data;
  final String statusCode;

  ResendCodeResponse({
    required this.error,
    required this.success,
    this.message,
    this.errorMessage,
    this.data,
    required this.statusCode,
  });

  factory ResendCodeResponse.fromJson(Map<String, dynamic> json) {
    return ResendCodeResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? ResendCodeData.fromJson(json['data']) : null,
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Resend code data model
class ResendCodeData {
  final String codeToken;

  ResendCodeData({
    required this.codeToken,
  });

  factory ResendCodeData.fromJson(Map<String, dynamic> json) {
    return ResendCodeData(
      codeToken: json['codeToken'] ?? '',
    );
  }
}

/// Request model for forgot password
class ForgotPasswordRequest {
  final String userEmail;

  ForgotPasswordRequest({
    required this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'userEmail': userEmail,
    };
  }
}

/// Response model for forgot password
class ForgotPasswordResponse {
  final bool error;
  final bool success;
  final String? message;
  final String? errorMessage;
  final ForgotPasswordData? data;
  final String statusCode;

  ForgotPasswordResponse({
    required this.error,
    required this.success,
    this.message,
    this.errorMessage,
    this.data,
    required this.statusCode,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? ForgotPasswordData.fromJson(json['data']) : null,
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Forgot password data model
class ForgotPasswordData {
  final int userID;
  final String userEmail;
  final String codeToken;

  ForgotPasswordData({
    required this.userID,
    required this.userEmail,
    required this.codeToken,
  });

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      userID: json['userID'] ?? 0,
      userEmail: json['userEmail'] ?? '',
      codeToken: json['codeToken'] ?? '',
    );
  }
}

/// Request model for forgot password code verification (uses same checkCode endpoint)
class ForgotPasswordCodeRequest {
  final String code;
  final String codeToken;

  ForgotPasswordCodeRequest({
    required this.code,
    required this.codeToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'codeToken': codeToken,
    };
  }
}

/// Response model for forgot password code verification
class ForgotPasswordCodeResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final String? errorMessage;
  final ForgotPasswordCodeData? data;
  final String statusCode;

  ForgotPasswordCodeResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.errorMessage,
    this.data,
    required this.statusCode,
  });

  factory ForgotPasswordCodeResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordCodeResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? ForgotPasswordCodeData.fromJson(json['data']) : null,
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Forgot password code data model
class ForgotPasswordCodeData {
  final String passToken;

  ForgotPasswordCodeData({
    required this.passToken,
  });

  factory ForgotPasswordCodeData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordCodeData(
      passToken: json['passToken'] ?? '',
    );
  }
}

/// Request model for updating password
class UpdatePasswordRequest {
  final String passToken;
  final String password;
  final String passwordAgain;

  UpdatePasswordRequest({
    required this.passToken,
    required this.password,
    required this.passwordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'passToken': passToken,
      'password': password,
      'passwordAgain': passwordAgain,
    };
  }
}

/// Response model for updating password
class UpdatePasswordResponse {
  final bool error;
  final bool success;
  final String? message;
  final String? errorMessage;
  final String statusCode;

  UpdatePasswordResponse({
    required this.error,
    required this.success,
    this.message,
    this.errorMessage,
    required this.statusCode,
  });

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'],
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}
