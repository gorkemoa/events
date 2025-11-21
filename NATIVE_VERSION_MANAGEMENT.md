# Native Version Management (Sürüm Yönetimi)

## 📱 Genel Bakış

Bu proje artık **native platform-based version management** kullanmaktadır. Flutter'ın `pubspec.yaml` dosyasındaki `version` değeri artık kullanılmamaktadır. Sürüm bilgileri tamamen **iOS** ve **Android** native konfigürasyonlarından yönetilmektedir.

## 🎯 Neden Native Version Management?

- ✅ Store (App Store & Google Play) sürümleri ile native build ayarları birebir uyumlu
- ✅ Her platform için ayrı ve doğrudan sürüm kontrolü
- ✅ CI/CD pipeline'larında daha kolay versiyon yönetimi
- ✅ Flutter'dan bağımsız, platform-native sürüm bilgisi

## 📍 iOS Sürüm Yönetimi

### Xcode ile Sürüm Ayarlama

1. Xcode'da projeyi açın
2. **Runner** → **General** → **Identity** bölümüne gidin
3. Sürüm bilgilerini güncelleyin:
   - **Version**: `CFBundleShortVersionString` (örn: `1.0.0`)
   - **Build**: `CFBundleVersion` (örn: `1`)

### Info.plist'te Sürüm Bilgileri

Dosya: `ios/Runner/Info.plist`

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### Sürüm Kuralları

- **CFBundleShortVersionString**: Kullanıcıya görünen sürüm (örn: `1.0.0`, `1.2.3`)
- **CFBundleVersion**: Build numarası (her build için artırılmalı: `1`, `2`, `3`, ...)

### App Store Yükleme

App Store'a yeni bir build yüklerken:
1. `CFBundleVersion` her zaman artırılmalı
2. `CFBundleShortVersionString` yeni özellik/düzeltmelere göre güncellenmeli

## 🤖 Android Sürüm Yönetimi

### build.gradle ile Sürüm Ayarlama

Dosya: `android/app/build.gradle.kts`

```kotlin
defaultConfig {
    applicationId = "com.office701.pixlomi"
    minSdk = 21
    targetSdk = 34
    // Native version management
    versionCode = 1
    versionName = "1.0.0"
}
```

### Sürüm Kuralları

- **versionCode**: Integer değer, her build için artırılmalı (`1`, `2`, `3`, ...)
- **versionName**: String değer, kullanıcıya görünen sürüm (`"1.0.0"`, `"1.2.3"`)

### Google Play Yükleme

Google Play Console'a yeni bir build yüklerken:
1. `versionCode` her zaman önceki değerden büyük olmalı
2. `versionName` semantic versioning kurallarına göre güncellenmeli

## 🔧 AppVersionService Kullanımı

Uygulama içinde sürüm bilgisine erişmek için `AppVersionService` kullanılır:

```dart
import 'package:pixlomi/services/app_version_service.dart';

// Servis singleton pattern kullanır
final versionService = AppVersionService();

// Sürüm bilgilerine erişim
String version = versionService.version;         // "1.0.0"
String buildNumber = versionService.buildNumber; // "1"
String fullVersion = versionService.fullVersion; // "1.0.0+1"
String platform = versionService.platform;       // "android" veya "ios"
String appName = versionService.appName;         // "Pixlomi"

// Debug bilgilerini logla
versionService.logVersionInfo();
```

## 🚀 Initialization

`AppVersionService` uygulama başlangıcında `main.dart` içinde initialize edilir:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... diğer initializationlar
  
  // Initialize App Version Service
  await AppVersionService().initialize();
  
  runApp(const MyApp());
}
```

## 📦 Backend Entegrasyonu

Social auth servislerinde (`SocialAuthService`) sürüm bilgisi otomatik olarak backend'e gönderilir:

```dart
final request = SocialLoginRequest(
  platform: 'google',
  deviceID: deviceInfo['deviceID']!,
  devicePlatform: deviceInfo['platform']!,
  version: _versionService.fullVersion,  // "1.0.0+1" formatında
  // ... diğer fieldlar
);
```

## 📝 Semantic Versioning

Projenin semantic versioning kurallarını takip etmesi önerilir:

**Format**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (uyumsuz API değişiklikleri)
- **MINOR**: Yeni özellikler (geriye dönük uyumlu)
- **PATCH**: Bug fixes (geriye dönük uyumlu)

### Örnekler

- `1.0.0` → İlk stable release
- `1.0.1` → Bug fix
- `1.1.0` → Yeni özellik eklendi
- `2.0.0` → Breaking change

## ⚠️ Önemli Notlar

1. **pubspec.yaml'daki version artık kullanılmıyor**: 
   - `pubspec.yaml` içindeki `version: 1.0.0+1` satırı artık aktif değil
   - Tüm sürüm yönetimi native platformlardan yapılıyor

2. **Her platform için ayrı versiyon**:
   - iOS ve Android farklı build numaralarına sahip olabilir
   - Store upload gereksinimlerine göre her platform bağımsız yönetilebilir

3. **CI/CD Pipeline**:
   - Automated build sistemlerinde native dosyaları güncelleyin
   - iOS için `agvtool` kullanılabilir
   - Android için `build.gradle.kts` dosyası script ile güncellenebilir

## 🔄 Store Sürüm Güncellemeleri

### iOS (App Store)

```bash
# Xcode command line ile version update
cd ios
agvtool new-marketing-version 1.1.0
agvtool new-version -all 2
```

### Android (Google Play)

`android/app/build.gradle.kts` dosyasını manuel veya script ile güncelleyin:

```kotlin
versionCode = 2
versionName = "1.1.0"
```

## 🛠 Troubleshooting

### iOS build hatası alıyorum
- Xcode'da **Product → Clean Build Folder** yapın
- `ios/Pods` klasörünü silin ve `pod install` çalıştırın
- Info.plist'teki version değerlerinin doğru formatta olduğunu kontrol edin

### Android build hatası alıyorum
- `android/app/build` klasörünü silin
- `flutter clean && flutter pub get` çalıştırın
- `versionCode` değerinin integer olduğunu kontrol edin

### Version bilgisi null geliyor
- `AppVersionService().initialize()` metodunun `main.dart` içinde çağrıldığından emin olun
- `package_info_plus` paketinin `pubspec.yaml` içinde ekli olduğunu kontrol edin

## 📚 İlgili Dökümanlar

- [iOS Version Management](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundleshortversionstring)
- [Android Versioning](https://developer.android.com/studio/publish/versioning)
- [Flutter Package Info Plus](https://pub.dev/packages/package_info_plus)
- [Semantic Versioning](https://semver.org/)
