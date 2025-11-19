# Google ve Apple ile Sosyal Giriş Kurulum Dökümanı

Bu döküman, Pixlomi uygulamasında Google ve Apple ile sosyal giriş sisteminin nasıl kurulduğunu detaylı şekilde açıklar.

## 📦 Kurulum Adımları

### 1. Paketler (pubspec.yaml)

Aşağıdaki paketler projeye eklendi:

```yaml
dependencies:
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.3
  device_info_plus: ^11.1.0
  firebase_messaging: ^15.1.7
```

**Kurulum:**
```bash
flutter pub get
```

---

## 🍎 iOS Konfigürasyonu

### Info.plist Güncellemeleri

**Dosya:** `ios/Runner/Info.plist`

#### Google Sign In için URL Scheme

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Mevcut deep link -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pixlomi</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.pixlomi.app</string>
    </dict>
    
    <!-- Google Sign In URL Scheme -->
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.1006195128429-u5rnha6kbruud0s2crrldqglr8rdeik9</string>
        </array>
    </dict>
</array>

<!-- Google Client ID -->
<key>GIDClientID</key>
<string>1006195128429-u5rnha6kbruud0s2crrldqglr8rdeik9.apps.googleusercontent.com</string>
```

### Runner.entitlements Güncellemeleri

**Dosya:** `ios/Runner/Runner.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
    
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:pixlomi.com</string>
    </array>
    
    <!-- Apple Sign In Capability -->
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

### Xcode Ayarları

1. Xcode'da projeyi açın: `ios/Runner.xcworkspace`
2. **Signing & Capabilities** sekmesine gidin
3. **"+ Capability"** butonuna tıklayın
4. **"Sign in with Apple"** ekleyin

---

## 🤖 Android Konfigürasyonu

### google-services.json Güncellemesi

**Dosya:** `android/app/google-services.json`

OAuth client bilgisi eklendi:

```json
{
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:1006195128429:android:675efb288b2766af816764",
        "android_client_info": {
          "package_name": "com.office701.pixlomi"
        }
      },
      "oauth_client": [
        {
          "client_id": "1006195128429-u5rnha6kbruud0s2crrldqglr8rdeik9.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

### SHA-1 Fingerprint Ekleme

Firebase Console'da Android uygulamanıza aşağıdaki SHA-1 fingerprint'i ekleyin:

```
88:D8:A1:E1:1D:20:C4:81:2A:F8:88:F7:A9:E8:CF:5D:CC:38:F4:AB
```

**Firebase Console'da:**
1. Firebase Console > Project Settings
2. "Your apps" altında Android uygulamasını seçin
3. SHA certificate fingerprints'e yukarıdaki değeri ekleyin

---

## 🔧 Backend Entegrasyonu

### API Endpoint

```
POST https://api.pixlomi.com/service/auth/loginSocial
```

**⚠️ ÖNEMLI: Basic Authentication Gereklidir**

Tüm API istekleri Basic Auth ile gönderilir:
- Username: `Xr1VAhH5ICWHJN2nlvp9K5ycPoyMJM`
- Password: `pRParvCAqTxtmkI17I1EVpPH57Edl0`

### Request Body Format

```json
{
    "platform": "google",  // veya "apple"
    "deviceID": "4172c00a-061b-4ff8-8da8-c185fbb4f0ce",
    "devicePlatform": "ios",  // veya "android"
    "version": "1.0.0",
    "accessToken": "...",
    "fcmToken": "fwHfAxWBlE_qtoyu1Ahfp-:APA91b...",
    "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6..."
}
```

### Response Format

**Başarılı Response (200):**
```json
{
    "error": false,
    "success": true,
    "data": {
        "status": "OK",
        "message": "Giriş başarılı",
        "userID": 123,
        "token": "user_token_here"
    },
    "200": "OK"
}
```

**Hatalı Response (417):**
```json
{
    "error": true,
    "success": false,
    "error_message": "Kullanıcı bulunamadı",
    "417": "ERROR"
}
```

### Mimari Yapı

Proje, **Model-Service-View** mimarisini takip eder:

#### 1. Model Katmanı
**Dosya:** `lib/models/social_auth_models.dart`

```dart
// Request Model
SocialLoginRequest(
  platform: 'google',
  deviceID: '...',
  devicePlatform: 'ios',
  version: '1.0.0',
  accessToken: '...',
  fcmToken: '...',
  idToken: '...',
)

// Response Model
SocialLoginResponse.fromJson(json)
// -> response.isSuccess
// -> response.data.userId
// -> response.data.token
```

#### 2. Service Katmanı
**Dosya:** `lib/services/social_auth_service.dart`

```dart
final socialAuth = SocialAuthService();

// Google ile giriş (tek method - her şeyi yapar)
final response = await socialAuth.signInWithGoogle();

// Apple ile giriş (tek method - her şeyi yapar)
final response = await socialAuth.signInWithApple();

// Response kontrolü
if (response.isSuccess && response.data != null) {
  final userId = response.data!.userId;
  final token = response.data!.token;
}
```

**ApiHelper ile Basic Auth:**
- Tüm istekler `ApiHelper.post()` ile gönderilir
- Basic Auth otomatik eklenir
- 403 hataları otomatik handle edilir

#### 3. View Katmanı
**Dosya:** `lib/views/auth/login_page.dart`

```dart
// Google butonu
onPressed: _handleGoogleSignIn,

// Apple butonu
onPressed: _handleAppleSignIn,
```

View katmanı sadece:
- Servis metodunu çağırır
- Response'u kontrol eder
- UI feedback gösterir
- Navigation yapar

### Servis Kullanımı

**Google Login - Tam Flow:**
```dart
final socialAuth = SocialAuthService();

// 1. Tek method çağrısı - her şeyi yapar
final response = await socialAuth.signInWithGoogle();

// 2. Response kontrolü
if (response.isSuccess && response.data != null) {
  // 3. Session kaydet
  await StorageHelper.saveUserSession(
    userId: response.data!.userId,
    userToken: response.data!.token,
  );
  
  // 4. FCM subscribe
  await FirebaseMessagingService.subscribeToUserTopic(
    response.data!.userId.toString(),
  );
  
  // 5. Home'a yönlendir
  Navigator.pushNamedAndRemoveUntil('/home', (route) => false);
} else {
  // Hata mesajı göster
  print(response.errorMessage);
}
```

**Apple Login - Aynı Yapı:**
```dart
final response = await socialAuth.signInWithApple();
// Sonrası Google ile aynı
```

---

## 📱 Login Sayfası Kullanımı

**Dosya:** `lib/views/auth/login_page.dart`

Login sayfasında Google ve Apple butonları otomatik olarak:

1. ✅ idToken üretir (null kontrolü ile)
2. ✅ accessToken alır
3. ✅ Device ID toplar
4. ✅ Device Platform (ios/android) belirler
5. ✅ FCM Token alır
6. ✅ Version bilgisi ekler
7. ✅ Backend'e JSON olarak POST gönderir
8. ✅ Session kaydeder
9. ✅ FCM topic subscribe yapar
10. ✅ Home sayfasına yönlendirir

---

## 🔍 Debug ve Test

### Console Log'ları

Servis içinde detaylı loglar mevcut:

```dart
print('✅ Google idToken başarıyla alındı');
print('📤 Google login data hazırlandı:');
print('📡 Backend\'e istek gönderiliyor: $url');
print('📥 Response status: ${response.statusCode}');
```

### Test Adımları

1. **iOS Simulator'da Google Login Test:**
   ```bash
   flutter run -d "iPhone 15 Pro"
   ```

2. **Android Emulator'da Google Login Test:**
   ```bash
   flutter run -d emulator-5554
   ```

3. **iOS Cihazda Apple Login Test:**
   - Apple Sign In yalnızca gerçek cihazlarda çalışır
   - Simulator'da test etmek için mock data kullanılmalı

---

## ⚠️ Önemli Notlar

### Google Sign In

- ✅ **idToken her zaman üretilir** - scopes'a 'openid' eklendi
- ✅ iOS'ta `GIDClientID` Info.plist'e eklenmeli
- ✅ Android'de `google-services.json`'a OAuth client eklenmeli
- ✅ SHA-1 fingerprint Firebase Console'a eklenmeli

### Apple Sign In

- ✅ **idToken (identityToken) her zaman üretilir**
- ✅ Runner.entitlements'a capability eklenmeli
- ✅ Xcode'da "Sign in with Apple" capability aktif olmalı
- ⚠️ Yalnızca iOS 13+ ve macOS 10.15+ desteklenir
- ⚠️ Simulator'da test edilemez, gerçek cihaz gereklidir

### Backend Gereksinimleri

Backend'in beklentileri:
- `platform`: "google" veya "apple"
- `idToken`: Google/Apple'dan alınan JWT token (NULL OLMAMALI)
- `accessToken`: Google accessToken veya Apple authorizationCode
- `deviceID`: Cihaz unique ID'si
- `devicePlatform`: "ios" veya "android"
- `version`: Uygulama versiyonu
- `fcmToken`: Firebase Cloud Messaging token

---

## 🚀 Başarıyla Tamamlandı!

Google ve Apple sosyal giriş sistemi:
- ✅ **Basic Auth entegrasyonu yapıldı (401 hatası çözüldü)**
- ✅ **Mimari yapıya uygun Model-Service-View**
- ✅ **ApiHelper ile tüm istekler**
- ✅ **Response modelleri ile type-safe**
- ✅ Tüm konfigürasyonlar yapıldı
- ✅ idToken null hatası çözüldü
- ✅ Backend entegrasyonu hazır
- ✅ Session yönetimi eklendi
- ✅ FCM integration yapıldı
- ✅ Tam çalışır durumda!

### Kod Kalitesi

- 🏗️ **Mimari:** Model-Service-View pattern
- 🔒 **Type Safety:** Tüm response'lar model ile
- 🔐 **Security:** Basic Auth otomatik
- 📝 **Logging:** Developer console ile detaylı log
- ⚠️ **Error Handling:** Try-catch ve null safety
- 🎨 **Clean Code:** Single Responsibility Principle

### Kullanılan Dosyalar

**Models:**
- `lib/models/social_auth_models.dart` - Request/Response modelleri

**Services:**
- `lib/services/social_auth_service.dart` - Google/Apple login
- `lib/services/api_helper.dart` - Basic Auth wrapper
- `lib/services/constants.dart` - API endpoints

**Views:**
- `lib/views/auth/login_page.dart` - Login UI

---

## 📞 Destek

Herhangi bir sorun yaşarsanız:
1. Console log'larını kontrol edin
2. Firebase Console ayarlarını doğrulayın
3. Info.plist ve entitlements dosyalarını gözden geçirin
4. SHA-1 fingerprint'in doğru eklendiğinden emin olun
