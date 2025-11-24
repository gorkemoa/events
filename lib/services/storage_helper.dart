import 'package:shared_preferences/shared_preferences.dart';

/// Storage helper for managing user session data
class StorageHelper {
  static const String _userIdKey = 'user_id';
  static const String _userTokenKey = 'user_token';
  static const String _userNameKey = 'user_name';
  static const String _userFullnameKey = 'user_fullname';
  static const String _onboardingShownKey = 'onboarding_shown';
  static const String _codeTokenKey = 'code_token';
  static const String _pendingDeepLinkEventCodeKey = 'pending_deep_link_event_code';

  /// Save user session data
  static Future<bool> saveUserSession({
    required int userId,
    required String userToken,
    String? userName,
    String? userFullname,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('💾 Saving session to SharedPreferences...');
      print('  - userId: $userId');
      print('  - userToken: $userToken');
      
      final userIdSaved = await prefs.setInt(_userIdKey, userId);
      final tokenSaved = await prefs.setString(_userTokenKey, userToken);
      
      print('  - userId saved: $userIdSaved');
      print('  - token saved: $tokenSaved');
      
      if (userName != null) {
        await prefs.setString(_userNameKey, userName);
      }
      if (userFullname != null) {
        await prefs.setString(_userFullnameKey, userFullname);
      }
      
      // Verify save
      final savedUserId = prefs.getInt(_userIdKey);
      final savedToken = prefs.getString(_userTokenKey);
      print('  - Verification - userId: $savedUserId, token: ${savedToken?.substring(0, 10)}...');
      
      return userIdSaved && tokenSaved;
    } catch (e) {
      print('❌ Error saving session: $e');
      return false;
    }
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_userIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Get user token
  static Future<String?> getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Get user fullname
  static Future<String?> getUserFullname() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userFullnameKey);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    final userToken = await getUserToken();
    return userId != null && userToken != null;
  }

  /// Check if user has seen onboarding
  static Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingShownKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark onboarding as shown
  static Future<bool> setOnboardingShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_onboardingShownKey, true);
    } catch (e) {
      return false;
    }
  }

  /// Save code token from registration
  static Future<bool> setCodeToken(String codeToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_codeTokenKey, codeToken);
    } catch (e) {
      print('❌ Error saving code token: $e');
      return false;
    }
  }

  /// Get code token
  static Future<String?> getCodeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_codeTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// Save pending deep link event code (to use after login)
  static Future<bool> setPendingDeepLinkEventCode(String eventCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('💾 Saving pending deep link event code: $eventCode');
      return await prefs.setString(_pendingDeepLinkEventCodeKey, eventCode);
    } catch (e) {
      print('❌ Error saving pending deep link event code: $e');
      return false;
    }
  }

  /// Get pending deep link event code
  static Future<String?> getPendingDeepLinkEventCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pendingDeepLinkEventCodeKey);
    } catch (e) {
      return null;
    }
  }

  /// Clear pending deep link event code
  static Future<bool> clearPendingDeepLinkEventCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingDeepLinkEventCodeKey);
      print('🗑️ Cleared pending deep link event code');
      return true;
    } catch (e) {
      print('❌ Error clearing pending deep link event code: $e');
      return false;
    }
  }

  /// Clear user session (logout)
  static Future<bool> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get userId before clearing to unsubscribe from Firebase topic
      final userId = prefs.getInt(_userIdKey);
      
      await prefs.remove(_userIdKey);
      await prefs.remove(_userTokenKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userFullnameKey);
      
      // Note: Firebase Messaging unsubscribe should be called from the UI layer
      // to handle the async operation properly. Return userId for that purpose.
      print('📤 User session cleared. UserID was: $userId');
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
