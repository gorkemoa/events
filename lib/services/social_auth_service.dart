import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'constants.dart';
import 'api_helper.dart';
import '../models/social_auth_models.dart';

class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
  );

  /// Google ile giriş yap ve backend'e gönder
  Future<SocialLoginResponse> signInWithGoogle() async {
    try {
      developer.log('🔵 Google Sign In başlatılıyor...', name: 'SocialAuth');
      
      // Google hesabı seç
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        developer.log('❌ Google sign in iptal edildi', name: 'SocialAuth');
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
        developer.log('❌ Google idToken null geldi!', name: 'SocialAuth');
        return SocialLoginResponse(
          error: true,
          success: false,
          errorMessage: 'Google idToken alınamadı',
          statusCode: 'ERROR',
        );
      }

      developer.log('✅ Google idToken başarıyla alındı', name: 'SocialAuth');
      
      // Device bilgilerini topla
      final deviceInfo = await _getDeviceInfo();
      final fcmToken = await _getFCMToken();

      // Request modeli oluştur
      final request = SocialLoginRequest(
        platform: 'google',
        deviceID: deviceInfo['deviceID']!,
        devicePlatform: deviceInfo['platform']!,
        version: '1.0.0',
        accessToken: googleAuth.accessToken ?? '',
        fcmToken: fcmToken,
        idToken: googleAuth.idToken!,
      );

      developer.log('📤 Google login data hazırlandı', name: 'SocialAuth');
      developer.log('  - platform: google', name: 'SocialAuth');
      developer.log('  - devicePlatform: ${deviceInfo['platform']}', name: 'SocialAuth');
      developer.log('  - idToken length: ${googleAuth.idToken!.length}', name: 'SocialAuth');

      // Backend'e gönder
      return await _loginSocial(request);
      
    } catch (e, stackTrace) {
      developer.log('❌ Google sign in hatası', name: 'SocialAuth', error: e, stackTrace: stackTrace);
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
      developer.log('🍎 Apple Sign In başlatılıyor...', name: 'SocialAuth');
      
      // Apple Sign In credential talep et
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // ID Token kontrolü
      if (credential.identityToken == null) {
        developer.log('❌ Apple idToken null geldi!', name: 'SocialAuth');
        return SocialLoginResponse(
          error: true,
          success: false,
          errorMessage: 'Apple idToken alınamadı',
          statusCode: 'ERROR',
        );
      }

      developer.log('✅ Apple idToken başarıyla alındı', name: 'SocialAuth');

      // Device bilgilerini topla
      final deviceInfo = await _getDeviceInfo();
      final fcmToken = await _getFCMToken();

      // Request modeli oluştur
      final request = SocialLoginRequest(
        platform: 'apple',
        deviceID: deviceInfo['deviceID']!,
        devicePlatform: deviceInfo['platform']!,
        version: '1.0.0',
        accessToken: credential.authorizationCode,
        fcmToken: fcmToken,
        idToken: credential.identityToken!,
      );

      developer.log('📤 Apple login data hazırlandı', name: 'SocialAuth');
      developer.log('  - platform: apple', name: 'SocialAuth');
      developer.log('  - devicePlatform: ${deviceInfo['platform']}', name: 'SocialAuth');
      developer.log('  - idToken length: ${credential.identityToken!.length}', name: 'SocialAuth');

      // Backend'e gönder
      return await _loginSocial(request);
      
    } catch (e, stackTrace) {
      developer.log('❌ Apple sign in hatası', name: 'SocialAuth', error: e, stackTrace: stackTrace);
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
      developer.log('🔐 Social Login Request', name: 'SocialAuth');
      developer.log('URL: ${ApiConstants.loginSocial}', name: 'SocialAuth');
      developer.log('Body: ${jsonEncode(request.toJson())}', name: 'SocialAuth');

      // ApiHelper ile Basic Auth'lu POST request
      final response = await ApiHelper.post(
        ApiConstants.loginSocial,
        request.toJson(),
      );

      developer.log('📥 Response Status: ${response.statusCode}', name: 'SocialAuth');
      developer.log('📥 Response Body: ${response.body}', name: 'SocialAuth');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final socialLoginResponse = SocialLoginResponse.fromJson(jsonResponse);
      
      developer.log('✅ Parsed Response - Success: ${socialLoginResponse.success}', name: 'SocialAuth');
      if (!socialLoginResponse.success) {
        developer.log('❌ Error Message: ${socialLoginResponse.errorMessage}', name: 'SocialAuth');
      }
      
      return socialLoginResponse;
    } catch (e, stackTrace) {
      // Return error response if network or parsing fails
      developer.log('❌ Exception occurred', name: 'SocialAuth', error: e, stackTrace: stackTrace);
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
        platform = 'android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceID = iosInfo.identifierForVendor ?? '';
        platform = 'ios';
      }
    } catch (e) {
      print('⚠️ Device info alınamadı: $e');
      deviceID = 'unknown';
      platform = Platform.isAndroid ? 'android' : 'ios';
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
