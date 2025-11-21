import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:developer' as developer;

/// Native platformlardan uygulama sürüm bilgilerini alan servis
/// iOS: Info.plist -> CFBundleShortVersionString (version)
/// Android: build.gradle.kts -> versionName (version)
class AppVersionService {
  static const String _logTag = 'AppVersionService';
  
  PackageInfo? _packageInfo;
  late String _displayVersion;
  
  /// Singleton pattern
  static final AppVersionService _instance = AppVersionService._internal();
  factory AppVersionService() => _instance;
  AppVersionService._internal();
  
  /// Package info'yu başlat (uygulama başlangıcında çağrılmalı)
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      
      // Platform'a göre sürüm bilgisini ayarla
      if (Platform.isIOS) {
        // iOS: Info.plist'ten CFBundleShortVersionString'i al
        _displayVersion = _packageInfo!.version;
        developer.log(
          '✅ iOS Version initialized - Version: $_displayVersion (from Info.plist)',
          name: _logTag,
        );
      } else if (Platform.isAndroid) {
        // Android: build.gradle.kts'ten versionName'i al
        _displayVersion = _packageInfo!.version;
        developer.log(
          '✅ Android Version initialized - Version: $_displayVersion (from build.gradle.kts)',
          name: _logTag,
        );
      } else {
        _displayVersion = _packageInfo!.version;
        developer.log(
          '✅ App Version initialized - Version: $_displayVersion',
          name: _logTag,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ App Version initialization failed',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      _displayVersion = '1.0.0';
    }
  }
  
  /// Görüntülenecek sürüm numarası (iOS: CFBundleShortVersionString, Android: versionName)
  String get version {
    if (_packageInfo == null) {
      developer.log(
        '⚠️ PackageInfo not initialized, returning fallback version',
        name: _logTag,
      );
      return '1.0.0';
    }
    return _displayVersion;
  }
  
  /// Build numarası (iOS: CFBundleVersion, Android: versionCode)
  String get buildNumber {
    if (_packageInfo == null) {
      developer.log(
        '⚠️ PackageInfo not initialized, returning fallback build number',
        name: _logTag,
      );
      return '1';
    }
    return _packageInfo!.buildNumber;
  }
  
  /// Tam sürüm string'i (version+build formatında)
  String get fullVersion => '$version+$buildNumber';
  
  /// Platform bilgisi
  String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
  
  /// Uygulama adı
  String get appName {
    return _packageInfo?.appName ?? 'Pixlomi';
  }
  
  /// Package name / Bundle ID
  String get packageName {
    return _packageInfo?.packageName ?? '';
  }
  
  /// Debug bilgilerini yazdır
  void logVersionInfo() {
    developer.log('📱 App Version Info:', name: _logTag);
    developer.log('  - App Name: $appName', name: _logTag);
    developer.log('  - Package Name: $packageName', name: _logTag);
    developer.log('  - Platform: $platform', name: _logTag);
    
    if (Platform.isIOS) {
      developer.log('  - Version (from Info.plist): $version', name: _logTag);
    } else if (Platform.isAndroid) {
      developer.log('  - Version (from build.gradle.kts): $version', name: _logTag);
    }
    
    developer.log('  - Build Number: $buildNumber', name: _logTag);
    developer.log('  - Full Version: $fullVersion', name: _logTag);
  }
}
