import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'constants.dart';
import 'api_helper.dart';
import 'app_version_service.dart';
import '../models/social_auth_models.dart';

/// Social Auth Constants
class _SocialAuthConstants {
  // Platform names
  static const String platformGoogle = 'google';
  static const String platformApple = 'apple';
  static const String platformAndroid = 'android';
  static const String platformIOS = 'ios';
  
  // Google scopes
  static const List<String> googleScopes = [
    'email',
    'profile',
    'openid',
  ];
  
  // Apple scopes
  static const List<AppleIDAuthorizationScopes> appleScopes = [
    AppleIDAuthorizationScopes.email,
    AppleIDAuthorizationScopes.fullName,
  ];
  
  // Log constants
  static const String logTagSocialAuth = 'SocialAuth';
}

class SocialAuthService {
  late final GoogleSignIn _googleSignIn;
  final AppVersionService _versionService = AppVersionService();

  SocialAuthService() {
    _googleSignIn = GoogleSignIn(
      scopes: _SocialAuthConstants.googleScopes,
    );
  }

  /// Google ile giriş yap ve backend'e gönder
  Future<SocialLoginResponse> signInWithGoogle() async {
    try {
      developer.log('🔵 Google Sign In başlatılıyor...', name: _SocialAuthConstants.logTagSocialAuth);
      
      // Google hesabı seç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        developer.log('❌ Google sign in iptal edildi', name: _SocialAuthConstants.logTagSocialAuth);
        return SocialLoginResponse(
          error: true,
          success: false,
          errorMessage: 'Giriş iptal edildi',
          statusCode: 'CANCELLED',
        );
      }

      // Google authentication bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // ID Token kontrolü
      if (googleAuth.idToken == null) {
        developer.log('❌ Google idToken null geldi!', name: _SocialAuthConstants.logTagSocialAuth);
        return SocialLoginResponse(
          error: true,
          success: false,
          errorMessage: 'Google idToken alınamadı',
          statusCode: 'ERROR',
        );
      }

      developer.log('✅ Google idToken başarıyla alındı', name: _SocialAuthConstants.logTagSocialAuth);
      
      // Device bilgilerini topla
      final deviceInfo = await _getDeviceInfo();
      final fcmToken = await _getFCMToken();

      // Request modeli oluştur
      final request = SocialLoginRequest(
        platform: _SocialAuthConstants.platformGoogle,
        deviceID: deviceInfo['deviceID']!,
        devicePlatform: deviceInfo['platform']!,
        version: _versionService.version,
        accessToken: googleAuth.accessToken ?? '',
        fcmToken: fcmToken,
        idToken: googleAuth.idToken!,
      );

      developer.log('📤 Google login data hazırlandı', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - platform: ${_SocialAuthConstants.platformGoogle}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - devicePlatform: ${deviceInfo['platform']}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - idToken length: ${googleAuth.idToken!.length}', name: _SocialAuthConstants.logTagSocialAuth);

      // Backend'e gönder
      return await _loginSocial(request);
      
    } catch (e, stackTrace) {
      developer.log('❌ Google sign in hatası', name: _SocialAuthConstants.logTagSocialAuth, error: e, stackTrace: stackTrace);
      return SocialLoginResponse(
        error: true,
        success: false,
        errorMessage: 'Google ile giriş hatası: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Apple ile giriş yap ve backend'e gönder
  Future<SocialLoginResponse> signInWithApple() async {
    try {
      developer.log('🍎 Apple Sign In başlatılıyor...', name: _SocialAuthConstants.logTagSocialAuth);
      
      // Apple Sign In credential talep et
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: _SocialAuthConstants.appleScopes,
      );

      // ID Token kontrolü
      if (credential.identityToken == null) {
        developer.log('❌ Apple idToken null geldi!', name: _SocialAuthConstants.logTagSocialAuth);
        return SocialLoginResponse(
          error: true,
          success: false,
          errorMessage: 'Apple idToken alınamadı',
          statusCode: 'ERROR',
        );
      }

      developer.log('✅ Apple idToken başarıyla alındı', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('🔍 Apple Credential Details:', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - userIdentifier: ${credential.userIdentifier}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - email: ${credential.email}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - givenName: ${credential.givenName}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - familyName: ${credential.familyName}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - authorizationCode: ${credential.authorizationCode}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - identityToken: ${credential.identityToken}', name: _SocialAuthConstants.logTagSocialAuth);

      // Device bilgilerini topla
      final deviceInfo = await _getDeviceInfo();
      final fcmToken = await _getFCMToken();

      // Request modeli oluştur
      final request = SocialLoginRequest(
        platform: _SocialAuthConstants.platformApple,
        deviceID: deviceInfo['deviceID']!,
        devicePlatform: deviceInfo['platform']!,
        version: _versionService.version,
        accessToken: credential.authorizationCode,
        fcmToken: fcmToken,
        idToken: credential.identityToken!,
      );

      developer.log('📤 Apple login data hazırlandı', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - platform: ${_SocialAuthConstants.platformApple}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - devicePlatform: ${deviceInfo['platform']}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('  - idToken length: ${credential.identityToken!.length}', name: _SocialAuthConstants.logTagSocialAuth);

      // Backend'e gönder
      return await _loginSocial(request);
      
    } catch (e, stackTrace) {
      developer.log('❌ Apple sign in hatası', name: _SocialAuthConstants.logTagSocialAuth, error: e, stackTrace: stackTrace);
      return SocialLoginResponse(
        error: true,
        success: false,
        errorMessage: 'Apple ile giriş hatası: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Social login ile backend'e istek gönder (Private method)
  Future<SocialLoginResponse> _loginSocial(SocialLoginRequest request) async {
    try {
      developer.log('🔐 Social Login Request', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('URL: ${ApiConstants.loginSocial}', name: _SocialAuthConstants.logTagSocialAuth);
      
      final requestBody = request.toJson();
      final bodyJson = jsonEncode(requestBody);
      developer.log('Body: $bodyJson', name: _SocialAuthConstants.logTagSocialAuth);
      
      // Generate CURL command for debugging
      final basicAuth = base64Encode(
        utf8.encode('${ApiConstants.basicAuthUsername}:${ApiConstants.basicAuthPassword}')
      );
      final curlCommand = '''
curl -X POST '${ApiConstants.loginSocial}' \\
-H 'Content-Type: application/json; charset=utf-8' \\
-H 'Authorization: Basic $basicAuth' \\
-H 'Accept: application/json' \\
-H 'Accept-Charset: utf-8' \\
-d '$bodyJson'
''';
      developer.log('📋 CURL Command:\n$curlCommand', name: _SocialAuthConstants.logTagSocialAuth);

      // ApiHelper ile Basic Auth'lu POST request
      final response = await ApiHelper.post(
        ApiConstants.loginSocial,
        requestBody,
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('📥 Response Headers: ${response.headers}', name: _SocialAuthConstants.logTagSocialAuth);
      developer.log('📥 Response Body: ${response.body}', name: _SocialAuthConstants.logTagSocialAuth);

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final socialLoginResponse = SocialLoginResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${socialLoginResponse.success}', name: _SocialAuthConstants.logTagSocialAuth);
      if (!socialLoginResponse.success) {
        developer.log('❌ Error Message: ${socialLoginResponse.errorMessage}', name: _SocialAuthConstants.logTagSocialAuth);
      }
      
      return socialLoginResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: _SocialAuthConstants.logTagSocialAuth, error: e, stackTrace: stackTrace);
      return SocialLoginResponse(
        error: true,
        success: false,
        errorMessage: 'Bir hata oluştu: $e',
        statusCode: 'ERROR',
      );
    }
  }

  /// Device bilgilerini al
  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceID = '';
    String platform = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceID = androidInfo.id;
        platform = _SocialAuthConstants.platformAndroid;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceID = iosInfo.identifierForVendor ?? '';
        platform = _SocialAuthConstants.platformIOS;
      }
    } catch (e) {
      print('⚠️ Device info alınamadı: $e');
      deviceID = 'unknown';
      platform = Platform.isAndroid 
        ? _SocialAuthConstants.platformAndroid 
        : _SocialAuthConstants.platformIOS;
    }

    return {
      'deviceID': deviceID,
      'platform': platform,
    };
  }

  /// FCM Token al
  Future<String> _getFCMToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      return fcmToken ?? '';
    } catch (e) {
      print('⚠️ FCM token alınamadı: $e');
      return '';
    }
  }

  /// Google'dan çıkış yap
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Google çıkış yapıldı');
    } catch (e) {
      print('❌ Google çıkış hatası: $e');
    }
  }

  /// Kullanıcının Google ile giriş yapıp yapmadığını kontrol et
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }
}
