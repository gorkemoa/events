# Flutter Localization Uygulaması

## 📋 Genel Bakış

Bu uygulama, **Türkçe** ve **İngilizce** olmak üzere 2 dili destekleyen tam kapsamlı bir Flutter lokalizasyon sistemi içermektedir.

## 🚀 Kurulum ve Yapı

### 1. Dosya Yapısı

```
lib/
├── localizations/
│   └── app_localizations.dart    # Lokalizasyon sınıfı
├── main.dart                      # MaterialApp yapılandırması
└── views/
    └── ...                        # Tüm görünümler

assets/
└── translations/
    ├── tr.json                    # Türkçe çeviriler
    └── en.json                    # İngilizce çeviriler
```

### 2. Paketler

Aşağıdaki paketler `pubspec.yaml` dosyasına eklenmiştir:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any
```

Assets:
```yaml
flutter:
  assets:
    - assets/translations/
```

### 3. flutter pub get

Paketleri yükleyin:
```bash
flutter pub get
```

## 💡 Kullanım

### Basit Metin Çevirisi

```dart
import 'package:pixlomi/localizations/app_localizations.dart';

// Widget build metodunda:
Text(context.tr('onboarding.page1_title'))
```

### Parametreli Çeviri

JSON'da:
```json
{
  "welcome": "Hoş geldin, {{name}}"
}
```

Dart'ta:
```dart
Text(context.tr('home.welcome', args: {'name': 'Ahmet'}))
```

### Nested (İç İçe) Anahtarlar

JSON:
```json
{
  "onboarding": {
    "page1_title": "Şehrin en unutulmaz anlarındasın 🎉",
    "page1_description": "O gecede yüzlerce kare çekildi…"
  }
}
```

Dart:
```dart
Text(context.tr('onboarding.page1_title'))
Text(context.tr('onboarding.page1_description'))
```

## 📝 Yeni Çeviri Ekleme

### 1. JSON Dosyalarını Güncelle

**tr.json:**
```json
{
  "my_section": {
    "my_key": "Türkçe metin"
  }
}
```

**en.json:**
```json
{
  "my_section": {
    "my_key": "English text"
  }
}
```

### 2. Kodda Kullan

```dart
Text(context.tr('my_section.my_key'))
```

## 🌍 Dil Değiştirme

Varsayılan dil Türkçe'dir. Dili değiştirmek için `main.dart` dosyasında:

```dart
MaterialApp(
  locale: const Locale('en', ''), // İngilizce için
  // veya
  locale: const Locale('tr', ''), // Türkçe için
  // ...
)
```

Dinamik dil değiştirme için state management kullanabilirsiniz:

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr', '');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      // ...
    );
  }
}
```

## 📚 Çeviri Kategorileri

Mevcut JSON yapısı:

```
onboarding/          # Onboarding ekranları
login/               # Giriş ekranı
signup/              # Kayıt ekranı
code_verification/   # Kod doğrulama
face_verification/   # Yüz doğrulama
home/                # Ana sayfa
events/              # Etkinlikler
event_detail/        # Etkinlik detayı
profile/             # Profil
edit_profile/        # Profil düzenleme
change_password/     # Şifre değiştirme
settings/            # Ayarlar
notifications/       # Bildirimler
drawer/              # Yan menü
common/              # Ortak metinler
```

## 🔧 Örnekler

### Örnek 1: Basit Buton

```dart
ElevatedButton(
  onPressed: () {},
  child: Text(context.tr('common.save')),
)
```

### Örnek 2: Parametreli Alert

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(context.tr('events.add_to_calendar')),
    content: Text(
      context.tr('events.add_to_calendar_confirm', 
        args: {'title': 'Yeni Yıl Partisi'}
      )
    ),
  ),
)
```

### Örnek 3: Liste Öğesi

```dart
ListTile(
  title: Text(context.tr('settings.edit_profile')),
  subtitle: Text(context.tr('settings.account_settings')),
)
```

### Örnek 4: Form Alanı

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: context.tr('login.label_username'),
    hintText: context.tr('login.placeholder_username'),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return context.tr('login.placeholder_username');
    }
    return null;
  },
)
```

### Örnek 5: SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(context.tr('event_detail.download_success', 
      args: {'count': '5'}
    )),
  ),
)
```

## 🎨 En İyi Uygulamalar

1. **Tutarlı Anahtarlama:** 
   - Kategori.alt_kategori.anahtar formatını kullanın
   - Örnek: `onboarding.page1_title`

2. **Anlamlı İsimler:**
   - Açıklayıcı anahtar isimleri kullanın
   - ❌ `text1`, `msg2`
   - ✅ `button_login`, `error_invalid_email`

3. **Parametreleri Ayraçla:**
   - `{{variable}}` formatını kullanın
   - Örnek: `"welcome": "Hoş geldin, {{name}}"`

4. **Hata Kontrolü:**
   - Eksik çeviriler için fallback mekanizması mevcut
   - Bulunamayan anahtarlar kendilerini döndürür

5. **Modülerlik:**
   - Her sayfa/özellik için ayrı kategoriler
   - Ortak metinler için `common` kategorisi

## 🐛 Hata Ayıklama

### Çeviri Gösterilmiyor

1. JSON dosyalarını kontrol edin (syntax hatası var mı?)
2. Anahtarın doğru yazıldığından emin olun
3. `flutter pub get` komutunu çalıştırın
4. Uygulamayı yeniden başlatın (hot reload yetmeyebilir)

### Parametre Çalışmıyor

```dart
// ❌ Yanlış
context.tr('welcome', args: {'username': 'Ahmet'})

// ✅ Doğru (JSON'daki {{name}} ile eşleşmeli)
context.tr('welcome', args: {'name': 'Ahmet'})
```

### Dil Değişmiyor

MaterialApp'in `locale` parametresini kontrol edin ve state'i güncelleyin.

## 📊 İstatistikler

- **Toplam Çeviri Anahtarı:** ~150+
- **Desteklenen Diller:** 2 (TR, EN)
- **Kapsama Oranı:** %100 (Tüm ekranlar)

## 🎯 Gelecek Geliştirmeler

- [ ] Dil seçici widget ekle
- [ ] SharedPreferences ile dil tercihini kaydet
- [ ] Daha fazla dil desteği (AR, DE, FR vb.)
- [ ] Tarih/saat formatları için localization
- [ ] Sayı formatları için localization

## 📞 Destek

Sorularınız için:
- **Email:** destek@office701.com
- **Telefon:** +90 (850) 444 0701

---

**© 2025 Office701 Bilgi Teknolojileri | Tüm Hakları Saklıdır.**
