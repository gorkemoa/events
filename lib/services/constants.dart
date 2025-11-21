/// API constants for the application
class ApiConstants {
  /// Base URL for all API endpoints
  static const String baseUrl = 'https://api.pixlomi.com/';

  /// Basic Auth credentials for API security
  static const String basicAuthUsername = 'Xr1VAhH5ICWHJN2nlvp9K5ycPoyMJM';
  static const String basicAuthPassword = 'pRParvCAqTxtmkI17I1EVpPH57Edl0';

  /// Authentication endpoints
  static const String login = '${baseUrl}service/auth/login';
  static const String loginSocial = '${baseUrl}service/auth/loginSocial';
  static const String register = '${baseUrl}service/auth/register';
  static const String checkCode = '${baseUrl}service/auth/code/checkCode';
  static const String resendCode = '${baseUrl}service/auth/code/authSendCode';
  
  /// User endpoints
  static String getUserById(int userId) => '${baseUrl}service/user/id/$userId';
  static String updateUser(int userId) => '${baseUrl}service/user/update/$userId/account';
  static String updatePassword() => '${baseUrl}service/user/update/password';
  static String deleteAccount() => '${baseUrl}service/user/account/delete';
  
  /// Notification endpoints
  static String getNotifications(int userId) => '${baseUrl}service/user/account/$userId/notifications';
  
  /// Event endpoints
  static String getAllEvents(String userToken, {String? city, String? searchText}) {
    final params = <String>[
      'userToken=$userToken',
      if (city != null && city.isNotEmpty) 'city=$city',
      if (searchText != null && searchText.isNotEmpty) 'searchText=$searchText',
    ];
    return '${baseUrl}service/events/event/all?${params.join('&')}';
  }
  
  static String getEventDetailById(int eventID, String userToken) {
    return '${baseUrl}service/events/event/detail/$eventID?userToken=$userToken';
  }
  
  static String getEventDetailByCode(String eventCode, String userToken) {
    return '${baseUrl}service/events/event/detail/$eventCode?userToken=$userToken';
  }
  
  /// Photo endpoints
  static String getUserPhotos(String userToken) {
    return '${baseUrl}service/user/account/photo/all?userToken=$userToken';
  }
  
  static const String hidePhoto = '${baseUrl}service/user/account/photo/showHide';
  
  static String getFavorites(String userToken) {
    return '${baseUrl}service/user/account/favorites/all?userToken=$userToken';
  }
  
  static const String toggleFavorite = '${baseUrl}service/user/account/favorites/addDelete';
  
  /// General endpoints
  static const String getAllCities = '${baseUrl}service/general/general/cities/all';
}
