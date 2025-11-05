import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum FaceDirection {
  front,
  left,
  right,
  unknown,
}

class FaceDetectionService {
  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  FaceDetectionService() {
    _initialize();
  }

  void _initialize() {
    debugPrint('🎯 Initializing FaceDetector...');
    final options = FaceDetectorOptions(
      enableContours: false, // Daha hızlı olması için kapat
      enableClassification: true, // Göz açıklığı için gerekli
      enableTracking: false, // Tek fotoğraf için gereksiz
      enableLandmarks: true, // Yüz noktaları için gerekli
      performanceMode: FaceDetectorMode.fast, // Hızlı mod dene
      minFaceSize: 0.1, // Daha küçük yüzleri de algıla
    );
    _faceDetector = FaceDetector(options: options);
    _isInitialized = true;
    debugPrint('✅ FaceDetector initialized');
  }

  bool get isInitialized => _isInitialized;

  /// Yüz yönünü tespit et
  /// headEulerAngleY değerlerine göre:
  /// -45 ile -15 arası: Sol
  /// -15 ile +15 arası: Ön
  /// +15 ile +45 arası: Sağ
  Future<FaceDirection> detectFaceDirection(XFile imageFile) async {
    if (!_isInitialized) {
      debugPrint('❌ Face detector is not initialized');
      return FaceDirection.unknown;
    }

    try {
      debugPrint('📸 Processing image: ${imageFile.path}');
      
      // iOS için File kullan, Android için path kullan
      final inputImage = InputImage.fromFile(File(imageFile.path));
      debugPrint('✅ InputImage created from File');
      
      // Yüz algılama yap
      debugPrint('🔍 Starting face detection...');
      final faces = await _faceDetector.processImage(inputImage);
      debugPrint('✅ Face detection completed. Found ${faces.length} face(s)');

      if (faces.isEmpty) {
        debugPrint('⚠️ No face detected in image');
        return FaceDirection.unknown;
      }

      // İlk tespit edilen yüzü al
      final face = faces.first;
      final headEulerAngleY = face.headEulerAngleY;
      final boundingBox = face.boundingBox;

      debugPrint('👤 Face found! Bounding box: ${boundingBox.width}x${boundingBox.height}');
      debugPrint('📐 Head Euler Angle Y: $headEulerAngleY');

      if (headEulerAngleY == null) {
        debugPrint('⚠️ Head angle is null');
        return FaceDirection.unknown;
      }

      // Yön belirleme
      FaceDirection direction;
      if (headEulerAngleY >= -15 && headEulerAngleY <= 15) {
        direction = FaceDirection.front;
        debugPrint('➡️ Direction: FRONT');
      } else if (headEulerAngleY < -15 && headEulerAngleY >= -45) {
        direction = FaceDirection.left;
        debugPrint('⬅️ Direction: LEFT');
      } else if (headEulerAngleY > 15 && headEulerAngleY <= 45) {
        direction = FaceDirection.right;
        debugPrint('➡️ Direction: RIGHT');
      } else {
        direction = FaceDirection.unknown;
        debugPrint('❓ Direction: UNKNOWN (angle too extreme)');
      }
      
      return direction;
    } catch (e, stackTrace) {
      debugPrint('❌ Error detecting face direction: $e');
      debugPrint('Stack trace: $stackTrace');
      return FaceDirection.unknown;
    }
  }

  /// Yüzün kalitesini kontrol et (parlama, bulanıklık vb.)
  Future<bool> isFaceQualityGood(XFile imageFile) async {
    if (!_isInitialized) {
      return false;
    }

    try {
      final inputImage = InputImage.fromFile(File(imageFile.path));
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return false;
      }

      final face = faces.first;

      // Yüzün yeterince büyük olup olmadığını kontrol et
      final boundingBox = face.boundingBox;
      final faceArea = boundingBox.width * boundingBox.height;
      
      // Minimum yüz alanı kontrolü (piksel cinsinden) - daha düşük eşik
      if (faceArea < 5000) {
        debugPrint('Face is too small: $faceArea');
        return false;
      }

      debugPrint('✅ Face quality OK. Area: $faceArea');
      return true;
    } catch (e) {
      debugPrint('Error checking face quality: $e');
      return false;
    }
  }

  /// Yüz ve yön kontrolünü birlikte yap
  Future<Map<String, dynamic>> analyzeFace(
    XFile imageFile,
    FaceDirection expectedDirection,
  ) async {
    final detectedDirection = await detectFaceDirection(imageFile);
    final isQualityGood = await isFaceQualityGood(imageFile);

    final isCorrectDirection = detectedDirection == expectedDirection;

    return {
      'detectedDirection': detectedDirection,
      'expectedDirection': expectedDirection,
      'isCorrectDirection': isCorrectDirection,
      'isQualityGood': isQualityGood,
      'isValid': isCorrectDirection && isQualityGood,
    };
  }

  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
      _isInitialized = false;
    }
  }
}
