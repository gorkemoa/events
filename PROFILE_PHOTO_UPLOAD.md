# Profil Fotoğrafı Yükleme Özelliği

## Genel Bakış
Kullanıcılar profil sayfasında fotoğraflarını güncelleyebilir. Fotoğraflar base64 formatında API'ye gönderilir.

## Özellikler

### 1. Fotoğraf Seçimi
- **Galeriden Seç**: Kullanıcı galerisinden bir fotoğraf seçebilir
- **Kamera ile Çek**: Doğrudan kamera ile fotoğraf çekebilir

### 2. Görsel Önizleme
- Seçilen fotoğraf profil resmi alanında anında görüntülenir
- Kaydetmeden önce önizleme yapılabilir

### 3. Fotoğraf Optimizasyonu
- **Maksimum boyut**: 800x800 piksel
- **Sıkıştırma**: %85 kalite ile optimize edilir
- **Format**: JPEG veya PNG desteklenir

### 4. Base64 Dönüştürme
Fotoğraf, API'ye gönderilmeden önce base64 formatına dönüştürülür:

```dart
// Örnek base64 format:
"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2P4z/D/PwAH/wND9avxlQAAAABJRU5ErkJggg=="
```

## Kullanım

### Düzenleme Modu
1. "Profili Düzenle" butonuna tıklayın
2. Profil fotoğrafı üzerindeki kamera ikonuna tıklayın
3. Galeriden seç veya kamera ile çek seçeneğini seçin
4. Fotoğrafı seçin
5. "Değişiklikleri Kaydet" butonuna tıklayın

### İptal Etme
- "İptal" butonuna basıldığında seçilen fotoğraf sıfırlanır
- Önceki profil fotoğrafı korunur

## Teknik Detaylar

### Kullanılan Paketler
- `image_picker: ^1.0.7` - Fotoğraf seçimi için
- `dart:convert` - Base64 dönüştürme için
- `dart:io` - Dosya okuma için

### İzinler

#### iOS (Info.plist)
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Profil fotoğrafı seçmek için fotoğraf kütüphanenize erişmemiz gerekiyor</string>
<key>NSCameraUsageDescription</key>
<string>Profil fotoğrafı çekmek için kameranıza erişmemiz gerekiyor</string>
```

#### Android
Kamera ve depolama izinleri `image_picker` paketi tarafından otomatik olarak yönetilir.

### API İsteği
```dart
UpdateUserRequest(
  userToken: userToken,
  userFirstname: _firstNameController.text,
  userLastname: _lastNameController.text,
  // ... diğer alanlar
  profilePhoto: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...', // Base64 string
)
```

## Güvenlik ve Performans

### Optimizasyon
- Fotoğraflar yüklenmeden önce 800x800'e yeniden boyutlandırılır
- %85 kalite ile sıkıştırılır
- Bu sayede API'ye gönderilen veri boyutu azaltılır

### Hata Yönetimi
- Fotoğraf seçilemezse kullanıcıya bilgi verilir
- Ağ hataları yakalanır ve kullanıcıya gösterilir
- Geçersiz fotoğraf formatlarında varsayılan ikon gösterilir

## Gelecek Geliştirmeler
- [ ] Fotoğraf kırpma özelliği
- [ ] Çoklu fotoğraf desteği
- [ ] Fotoğraf filtreleri
- [ ] Profil fotoğrafı silme seçeneği
