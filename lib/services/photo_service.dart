import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pixlomi/services/constants.dart';
import 'package:pixlomi/services/api_helper.dart';
import 'package:pixlomi/services/storage_helper.dart';

class PhotoService {
  static final Dio _dio = Dio();

  /// Tek bir fotoğrafı galeriye indir
  static Future<bool> downloadPhoto(String imageUrl) async {
    try {
      print('🔄 Downloading photo: $imageUrl');

      // Geçici dizine indir
      final tempDir = await getTemporaryDirectory();
      final fileName = 'pixlomi_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      print('📥 Downloading to: $filePath');

      await _dio.download(imageUrl, filePath);

      print('✅ Downloaded, saving to gallery...');

      // Galeriye "Pixlomi" albümüne kaydet
      await Gal.putImage(filePath, album: 'Pixlomi');

      print('✅ Successfully saved to Pixlomi album');

      // Geçici dosyayı sil
      try {
        await File(filePath).delete();
      } catch (e) {
        print('⚠️ Could not delete temp file: $e');
      }

      return true;
    } catch (e) {
      print('❌ Download error: $e');
      if (e.toString().contains('denied') || e.toString().contains('permission')) {
        throw Exception('Fotoğraf kaydetmek için galeri izni gerekiyor.\nAyarlar > Pixlomi > Fotoğraflar\'dan izin verin.');
      }
      rethrow;
    }
  }

  /// Birden fazla fotoğrafı galeriye indir
  static Future<int> downloadPhotos(List<String> imageUrls) async {
    try {
      print('🔄 Downloading ${imageUrls.length} photos');

      int successCount = 0;
      final tempDir = await getTemporaryDirectory();

      for (int i = 0; i < imageUrls.length; i++) {
        try {
          final fileName = 'pixlomi_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final filePath = '${tempDir.path}/$fileName';

          print('📥 Downloading ${i + 1}/${imageUrls.length}: ${imageUrls[i]}');

          await _dio.download(imageUrls[i], filePath);

          print('✅ Downloaded, saving to gallery...');

          // Galeriye "Pixlomi" albümüne kaydet
          await Gal.putImage(filePath, album: 'Pixlomi');

          print('✅ Saved ${i + 1}/${imageUrls.length} to Pixlomi album');

          successCount++;

          // Geçici dosyayı sil
          try {
            await File(filePath).delete();
          } catch (e) {
            print('⚠️ Could not delete temp file: $e');
          }

          // Sunucuya aşırı yüklenmeyi önlemek için kısa bir bekleme
          if (i < imageUrls.length - 1) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
        } catch (e) {
          print('❌ Error downloading image ${i + 1}: $e');
          continue;
        }
      }

      print('✅ Successfully saved $successCount/${imageUrls.length} photos');
      return successCount;
    } catch (e) {
      print('❌ Download multiple error: $e');
      if (e.toString().contains('denied') || e.toString().contains('permission')) {
        throw Exception('Fotoğraf kaydetmek için galeri izni gerekiyor.\nAyarlar > Pixlomi > Fotoğraflar\'dan izin verin.');
      }
      rethrow;
    }
  }

  /// Tek bir fotoğrafı paylaş
  static Future<void> sharePhoto(String imageUrl, {String? text, Rect? sharePositionOrigin}) async {
    try {
      print('🔄 Sharing photo: $imageUrl');
      
      // Geçici dizine indir
      final tempDir = await getTemporaryDirectory();
      final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${tempDir.path}/$fileName';

      print('📥 Downloading for share: $filePath');

      final response = await _dio.download(imageUrl, filePath);

      if (response.statusCode == 200) {
        print('✅ Downloaded, sharing...');
        
        await Share.shareXFiles(
          [XFile(filePath)],
          text: text ?? 'Pixlomi ile paylaşıldı',
          sharePositionOrigin: sharePositionOrigin,
        );

        print('✅ Share completed');

        // Geçici dosyayı sil
        try {
          await File(filePath).delete();
        } catch (e) {
          print('⚠️ Could not delete temp file: $e');
        }
      }
    } catch (e) {
      print('❌ Share error: $e');
      rethrow;
    }
  }

  /// Birden fazla fotoğrafı paylaş
  static Future<void> sharePhotos(List<String> imageUrls, {String? text, Rect? sharePositionOrigin}) async {
    try {
      print('🔄 Sharing ${imageUrls.length} photos');
      
      final tempDir = await getTemporaryDirectory();
      final files = <XFile>[];

      for (int i = 0; i < imageUrls.length; i++) {
        final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final filePath = '${tempDir.path}/$fileName';

        print('📥 Downloading ${i + 1}/${imageUrls.length} for share');

        final response = await _dio.download(imageUrls[i], filePath);

        if (response.statusCode == 200) {
          files.add(XFile(filePath));
        }

        // Sunucuya aşırı yüklenmeyi önlemek için kısa bir bekleme
        if (i < imageUrls.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (files.isNotEmpty) {
        print('✅ Downloaded ${files.length} files, sharing...');
        
        await Share.shareXFiles(
          files,
          text: text ?? 'Pixlomi ile ${files.length} fotoğraf paylaşıldı',
          sharePositionOrigin: sharePositionOrigin,
        );

        print('✅ Share completed');

        // Geçici dosyaları sil
        for (final file in files) {
          try {
            await File(file.path).delete();
          } catch (e) {
            print('⚠️ Could not delete temp file: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Share multiple error: $e');
      rethrow;
    }
  }

  /// Fotoğrafı gizle/göster (optimistic update için response beklenmez)
  static Future<void> hidePhoto(int photoID) async {
    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      print('🔄 Hiding photo ID: $photoID');

      // Fire and forget - response beklenmez
      ApiHelper.put(
        ApiConstants.hidePhoto,
        {
          'userToken': userToken,
          'photoID': photoID,
        },
      ).then((response) {
        print('✅ Photo hidden successfully');
      }).catchError((error) {
        print('⚠️ Hide photo error (non-blocking): $error');
      });
    } catch (e) {
      print('❌ Hide photo error: $e');
      // Hata olsa bile throw etme, UI'da optimistic update çalışsın
    }
  }

  /// Fotoğrafı favorilere ekle/çıkar (optimistic update için response beklenmez)
  static Future<void> toggleFavorite(int photoID) async {
    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      print('🔄 Toggling favorite for photo ID: $photoID');

      // Fire and forget - response beklenmez
      ApiHelper.put(
        ApiConstants.toggleFavorite,
        {
          'userToken': userToken,
          'photoID': photoID,
        },
      ).then((response) {
        print('✅ Favorite toggled successfully');
      }).catchError((error) {
        print('⚠️ Toggle favorite error (non-blocking): $error');
      });
    } catch (e) {
      print('❌ Toggle favorite error: $e');
      // Hata olsa bile throw etme, UI'da optimistic update çalışsın
    }
  }
}
