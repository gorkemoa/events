/// API constants for the application
class ApiConstants {
  /// Base URL for all API endpoints
  static const String baseUrl = 'https://api.office701.com/pixlomi/';

  /// Basic Auth credentials for API security
  static const String basicAuthUsername = 'Xr1VAhH5ICWHJN2nlvp9K5ycPoyMJM';
  static const String basicAuthPassword = 'pRParvCAqTxtmkI17I1EVpPH57Edl0';

  /// Authentication endpoints
  static const String login = '${baseUrl}service/auth/login';
  
  /// User endpoints
  static String getUserById(int userId) => '${baseUrl}service/user/id/$userId';
  
  /// Notification endpoints
  static String getNotifications(int userId) => '${baseUrl}service/user/account/$userId/notifications';
}
