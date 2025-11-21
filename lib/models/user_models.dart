/// Request model for getting user data
class GetUserRequest {
  final String userToken;
  final String version;
  final String platform;

  GetUserRequest({
    required this.userToken,
    required this.version,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'version': version,
      'platform': platform,
    };
  }
}

/// Response model for user data
class UserResponse {
  final bool error;
  final bool success;
  final UserData? data;
  final String? errorMessage;
  final String statusCode;

  UserResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// User data wrapper
class UserData {
  final User user;

  UserData({required this.user});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: User.fromJson(json['user']),
    );
  }
}

/// Request model for updating user data
class UpdateUserRequest {
  final String userToken;
  final String userName;
  final String userFirstname;
  final String userLastname;
  final String userEmail;
  final String userBirthday;
  final String userPhone;
  final String userAddress;
  final int userGender; // 1 - Erkek, 2 - Kadın, 3 - Belirtilmemiş
  final String profilePhoto; // Base64 formatında

  UpdateUserRequest({
    required this.userToken,
    required this.userName,
    required this.userFirstname,
    required this.userLastname,
    required this.userEmail,
    required this.userBirthday,
    required this.userPhone,
    required this.userAddress,
    required this.userGender,
    this.profilePhoto = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'userName': userName,
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userEmail': userEmail,
      'userBirthday': userBirthday,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'userGender': userGender,
      'profilePhoto': profilePhoto,
    };
  }
}

/// Response model for update user
class UpdateUserResponse {
  final bool error;
  final bool success;
  final String message;
  final String? errorMessage;
  final String statusCode;

  UpdateUserResponse({
    required this.error,
    required this.success,
    required this.message,
    this.errorMessage,
    required this.statusCode,
  });

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// User model
class User {
  final int userId;
  final String userName;
  final String userFirstname;
  final String userLastname;
  final String userFullname;
  final String userEmail;
  final String userPhone;
  final String userIdentityNo;
  final String userBirthday;
  final String userRank;
  final String userGender;
  final String userToken;
  final String userAddress;
  final String? userPermissions;
  final String platform;
  final String userVersion;
  final String iOSVersion;
  final String androidVersion;
  final String profilePhoto;
  final String frontImage;
  final String leftImage;
  final String rightImage;

  User({
    required this.userId,
    required this.userName,
    required this.userFirstname,
    required this.userLastname,
    required this.userFullname,
    required this.userEmail,
    required this.userPhone,
    required this.userIdentityNo,
    required this.userBirthday,
    required this.userRank,
    required this.userGender,
    required this.userToken,
    required this.userAddress,
    this.userPermissions,
    required this.platform,
    required this.userVersion,
    required this.iOSVersion,
    required this.androidVersion,
    required this.profilePhoto,
    required this.frontImage,
    required this.leftImage,
    required this.rightImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userFirstname: json['userFirstname'] ?? '',
      userLastname: json['userLastname'] ?? '',
      userFullname: json['userFullname'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userIdentityNo: json['userIdentityNo'] ?? '',
      userBirthday: json['userBirthday'] ?? '',
      userRank: json['userRank'] ?? '0',
      userGender: json['userGender'] ?? '',
      userToken: json['userToken'] ?? '',
      userAddress: json['userAddress'] ?? '',
      userPermissions: json['userPermissions'],
      platform: json['platform'] ?? '',
      userVersion: json['userVersion'] ?? '',
      iOSVersion: json['iOSVersion'] ?? '',
      androidVersion: json['androidVersion'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      frontImage: json['frontImage'] ?? '',
      leftImage: json['leftImage'] ?? '',
      rightImage: json['rightImage'] ?? '',
    );
  }
}

/// Request model for updating password
class UpdatePasswordRequest {
  final String userToken;
  final String currentPassword;
  final String password;
  final String passwordAgain;

  UpdatePasswordRequest({
    required this.userToken,
    required this.currentPassword,
    required this.password,
    required this.passwordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'currentPassword': currentPassword,
      'password': password,
      'passwordAgain': passwordAgain,
    };
  }
}

/// Response model for update password
class UpdatePasswordResponse {
  final bool error;
  final bool success;
  final String message;
  final String? errorMessage;
  final String statusCode;

  UpdatePasswordResponse({
    required this.error,
    required this.success,
    required this.message,
    this.errorMessage,
    required this.statusCode,
  });

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Request model for deleting user account
class DeleteAccountRequest {
  final String userToken;

  DeleteAccountRequest({
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
    };
  }
}

/// Response model for delete account
class DeleteAccountResponse {
  final bool error;
  final bool success;
  final String message;
  final String? errorMessage;
  final String statusCode;

  DeleteAccountResponse({
    required this.error,
    required this.success,
    required this.message,
    this.errorMessage,
    required this.statusCode,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

// ============================================
// FACE PHOTO MODELS
// ============================================

/// Request model for uploading/updating face photos
class FacePhotoRequest {
  final String userToken;
  final String frontPhoto; // Base64 with data URI prefix
  final String leftPhoto;  // Base64 with data URI prefix
  final String rightPhoto; // Base64 with data URI prefix

  FacePhotoRequest({
    required this.userToken,
    required this.frontPhoto,
    required this.leftPhoto,
    required this.rightPhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'frontPhoto': frontPhoto,
      'leftPhoto': leftPhoto,
      'rightPhoto': rightPhoto,
    };
  }
}

/// Response model for uploading/updating face photos
class FacePhotoResponse {
  final bool error;
  final bool success;
  final String? errorMessage;
  final String statusCode;

  FacePhotoResponse({
    required this.error,
    required this.success,
    this.errorMessage,
    required this.statusCode,
  });

  factory FacePhotoResponse.fromJson(Map<String, dynamic> json) {
    return FacePhotoResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['201'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && (statusCode == 'OK' || statusCode == 'Created');
}

/// Response model for getting face photos
class GetFacePhotosResponse {
  final bool error;
  final bool success;
  final FacePhotosData? data;
  final String? errorMessage;
  final String statusCode;

  GetFacePhotosResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory GetFacePhotosResponse.fromJson(Map<String, dynamic> json) {
    // data alanını güvenli şekilde kontrol et
    FacePhotosData? parsedData;
    try {
      final dataField = json['data'];
      // data bir Map ise parse et, değilse null bırak (boş liste veya null olabilir)
      if (dataField != null && dataField is Map<String, dynamic>) {
        parsedData = FacePhotosData.fromJson(dataField);
      }
    } catch (e) {
      // Parse hatası olursa null bırak
      parsedData = null;
    }
    
    return GetFacePhotosResponse(
      error: json['error'] ?? false,
      success: json['success'] ?? false,
      data: parsedData,
      errorMessage: json['error_message'],
      statusCode: json['200'] ?? json['417'] ?? '',
    );
  }

  bool get isSuccess => success && statusCode == 'OK';
}

/// Face photos data wrapper
class FacePhotosData {
  final UserPhotoData userPhoto;
  final String message;

  FacePhotosData({
    required this.userPhoto,
    required this.message,
  });

  factory FacePhotosData.fromJson(Map<String, dynamic> json) {
    return FacePhotosData(
      userPhoto: UserPhotoData.fromJson(json['userPhoto']),
      message: json['message'] ?? '',
    );
  }
}

/// User photo data with URLs
class UserPhotoData {
  final String frontImage;
  final String leftImage;
  final String rightImage;
  final String createDate;

  UserPhotoData({
    required this.frontImage,
    required this.leftImage,
    required this.rightImage,
    required this.createDate,
  });

  factory UserPhotoData.fromJson(Map<String, dynamic> json) {
    return UserPhotoData(
      frontImage: json['frontImage'] ?? '',
      leftImage: json['leftImage'] ?? '',
      rightImage: json['rightImage'] ?? '',
      createDate: json['createDate'] ?? '',
    );
  }
}
