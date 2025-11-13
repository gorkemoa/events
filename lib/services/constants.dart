/// API constants for the application
class ApiConstants {
  /// Base URL for all API endpoints
  static const String baseUrl = 'https://api.pixlomi.com/';

  /// Basic Auth credentials for API security
  static const String basicAuthUsername = 'Xr1VAhH5ICWHJN2nlvp9K5ycPoyMJM';
  static const String basicAuthPassword = 'pRParvCAqTxtmkI17I1EVpPH57Edl0';

  /// Authentication endpoints
  static const String login = '${baseUrl}service/auth/login';
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
  
  /// General endpoints
  static const String getAllCities = '${baseUrl}service/general/general/cities/all';
}
