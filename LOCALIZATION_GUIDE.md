# 🌍 Flutter Localization - Tamamlanmış Kurulum

## ✅ YAPILAN İŞLEMLER

### 1. Temel Altyapı Kurulumu ✓
- ✅ `lib/localizations/app_localizations.dart` oluşturuldu
- ✅ `assets/translations/tr.json` oluşturuldu (150+ çeviri)
- ✅ `assets/translations/en.json` oluşturuldu (150+ çeviri)
- ✅ `pubspec.yaml` güncellendi (flutter_localizations, intl eklendi)
- ✅ `main.dart` localization desteği ile yapılandırıldı
- ✅ Paketler yüklendi (`flutter pub get`)

### 2. Örnek Sayfa Güncellemeleri ✓
- ✅ `onboarding_page.dart` tamamen güncellendi
- ✅ Diğer sayfalar için şablonlar hazırlandı

### 3. Dokümantasyon ✓
- ✅ `LOCALIZATION_README.md` - Detaylı kullanım kılavuzu
- ✅ `LOCALIZATION_EXAMPLES.dart` - Kod örnekleri

## 🎯 KALAN İŞLEMLER

Aşağıdaki dosyalarda hardcoded metinleri `context.tr()` ile değiştirmeniz gerekiyor:

### Auth Sayfaları (Öncelikli)
```
lib/views/auth/
├── login_page.dart
├── signup_page.dart
├── code_verification_page.dart
└── face_verification_page.dart
```

### Ana Sayfalar
```
lib/views/
├── home_page.dart
├── events/events_page.dart
├── events/event_detail_page.dart
├── profile/profile_page.dart
├── profile/settings_page.dart
├── profile/edit_profile_page.dart
├── profile/change_password_page.dart
└── notifications/notifications_page.dart
```

### Widget'lar
```
lib/widgets/
├── app_drawer.dart
├── home_header.dart
└── custom_bottom_nav.dart
```

## 📝 NASIL GÜNCELLERSINIZ?

### Adım 1: Import Ekleyin
Her dosyanın başına ekleyin:
```dart
import 'package:pixlomi/localizations/app_localizations.dart';
```

### Adım 2: Metinleri Değiştirin

**ÖNCE:**
```dart
Text('Etkinliğe Giriş Yap')
```

**SONRA:**
```dart
Text(context.tr('login.title'))
```

### Adım 3: Parametreli Metinler

**ÖNCE:**
```dart
Text('Hoş geldin, ${user.name}')
```

**SONRA:**
```dart
Text(context.tr('home.welcome', args: {'name': user.name}))
```

## 🔍 ÖRNEK: login_page.dart Güncellemesi

### Eski Kod:
```dart
Text(
  'Etkinliğe Giriş Yap',
  style: AppTheme.headingMedium,
),
Text(
  'Kullanıcı adı ve şifrenizi girin.',
  style: AppTheme.bodyMedium,
),
```

### Yeni Kod:
```dart
import 'package:pixlomi/localizations/app_localizations.dart';  // EKLE

Text(
  context.tr('login.title'),  // DEĞİŞTİR
  style: AppTheme.headingMedium,
),
Text(
  context.tr('login.subtitle'),  // DEĞİŞTİR
  style: AppTheme.bodyMedium,
),
```

## 📋 JSON ANAHTAR KARŞILIKLARI

### Login Page
```dart
'Etkinliğe Giriş Yap'          -> context.tr('login.title')
'Kullanıcı Adı'                -> context.tr('login.label_username')
'Şifre'                        -> context.tr('login.label_password')
'Giriş Yap'                    -> context.tr('login.button_login')
'Şifremi Unuttum'              -> context.tr('login.forgot_password')
'Kayıt Ol'                     -> context.tr('login.signup')
```

### Home Page
```dart
'Hoş geldin, {{name}}'         -> context.tr('home.welcome', args: {'name': name})
'Ne arıyorsunuz?'              -> context.tr('home.search_placeholder')
'Katıldığım Etkinlikler'       -> context.tr('home.attended_events_title')
'Tümünü Gör >'                 -> context.tr('home.view_all')
```

### Events Page
```dart
'Etkinlik ara...'              -> context.tr('events.search_placeholder')
'Tüm Etkinlikler'              -> context.tr('events.tab_all')
'Takvime Ekle'                 -> context.tr('events.add_to_calendar')
```

### Profile Page
```dart
'Profil'                       -> context.tr('profile.title')
'Kullanıcı Adı'                -> context.tr('profile.username')
'Telefon'                      -> context.tr('profile.phone')
'Cinsiyet'                     -> context.tr('profile.gender')
```

### Settings Page
```dart
'Ayarlar'                      -> context.tr('settings.title')
'Profili Düzenle'              -> context.tr('settings.edit_profile')
'Şifre Değiştir'               -> context.tr('settings.change_password')
'Çıkış Yap'                    -> context.tr('settings.logout')
```

## 🚀 HIZLI BAŞLANGIÇ

### 1. Login Page için:
```bash
# Dosyayı açın
lib/views/auth/login_page.dart
```

Şu satırları bulun ve değiştirin:
```dart
// Satır ~145 civarı
Text(
  'Etkinliğe Giriş Yap',  // BUNU BUL
  style: AppTheme.headingMedium,
),

// ŞUNUNLA DEĞİŞTİR:
Text(
  context.tr('login.title'),
  style: AppTheme.headingMedium,
),
```

### 2. Signup Page için:
```dart
// Satır ~130 civarı
Text(
  'Etkinliğe Kaydol',  // BUNU BUL
  style: AppTheme.headingMedium,
),

// ŞUNUNLA DEĞİŞTİR:
Text(
  context.tr('signup.title'),
  style: AppTheme.headingMedium,
),
```

### 3. Home Page için:
```dart
// Satır ~50 civarı
_currentUser != null
  ? 'Hoş geldin, ${_currentUser!.userFirstname}'  // BUNU BUL
  : null,

// ŞUNUNLA DEĞİŞTİR:
_currentUser != null
  ? context.tr('home.welcome', args: {'name': _currentUser!.userFirstname})
  : null,
```

## 🎨 KALIP (PATTERN)

Her dosya için bu kalıbı takip edin:

1. **Import ekle** (dosya başında, diğer import'lardan sonra):
   ```dart
   import 'package:pixlomi/localizations/app_localizations.dart';
   ```

2. **Metinleri bul** (CTRL+F ile arayın):
   - Türkçe karakterli her string'i bulun
   - Özellikle Text(), SnackBar(), AlertDialog() içindeki

3. **Değiştir**:
   ```dart
   // Önce
   Text('Metnin kendisi')
   
   // Sonra
   Text(context.tr('kategori.anahtar'))
   ```

4. **Test et**:
   - Hot reload yapın
   - Metinlerin göründüğünü kontrol edin
   - Eğer anahtar bulunamazsa, JSON'u kontrol edin

## 🔧 SORUN GİDERME

### "context.tr() tanımlı değil" hatası
```dart
// import unutulmuş, ekleyin:
import 'package:pixlomi/localizations/app_localizations.dart';
```

### Metin gösterilmiyor
```dart
// JSON anahtarını kontrol edin:
context.tr('login.title')  // ✅ Doğru
context.tr('login_title')  // ❌ Yanlış (nokta olmalı)
```

### Hot reload çalışmıyor
```bash
# Uygulamayı yeniden başlatın:
r  # veya
R  # tam restart için
```

## 📊 İLERLEME TAKİBİ

Güncellenecek dosyalar (öncelik sırasıyla):

- [ ] login_page.dart (30+ metin)
- [ ] signup_page.dart (25+ metin)
- [ ] code_verification_page.dart (10+ metin)
- [ ] face_verification_page.dart (15+ metin)
- [ ] home_page.dart (20+ metin)
- [ ] events_page.dart (30+ metin)
- [ ] event_detail_page.dart (40+ metin)
- [ ] profile_page.dart (15+ metin)
- [ ] settings_page.dart (20+ metin)
- [ ] edit_profile_page.dart (15+ metin)
- [ ] change_password_page.dart (15+ metin)
- [ ] notifications_page.dart (10+ metin)
- [ ] app_drawer.dart (20+ metin)
- [ ] home_header.dart (5+ metin)

## 💪 TOPLU İŞLEM ÖNERİSİ

VS Code kullanıyorsanız:

1. **Find & Replace (CTRL+H)** kullanın:
   ```
   Bul:    Text\('([^']+)'\)
   Değiştir: Text(context.tr('$1'))
   ```
   ⚠️ Dikkat: Manuel kontrol gerekli!

2. **Multi-cursor** kullanın:
   - ALT tuşuna basılı tutun
   - Değiştirmek istediğiniz yerlere tıklayın
   - Hepsini bir anda düzenleyin

## 🎓 NOTLAR

- ✅ **Tüm JSON çevirileri hazır** - sadece kullanın
- ✅ **LocalizationExtension mevcut** - `context.tr()` çalışıyor
- ✅ **Parametreli metinler destekleniyor** - `{{name}}` formatı
- ✅ **Dil değişikliği hazır** - main.dart'ta locale değiştirilebilir

## 📞 YARDIM

Bir sorunla karşılaşırsanız:
1. JSON dosyasını kontrol edin (syntax hatası var mı?)
2. Import'u kontrol edin
3. Hot reload yerine hot restart deneyin
4. `flutter clean && flutter pub get` çalıştırın

---

**Başarılar! 🚀**
Her dosyayı güncelledikçe uygulamanız tamamen çokdilli olacak.
