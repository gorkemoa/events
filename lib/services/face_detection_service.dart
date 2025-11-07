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

enum FaceQuality {
  good,
  bad,
  tooSmall,
  tooDark,
  tooFar,
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
      enableContours: false,
      enableClassification: false,
      enableTracking: false,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.10, // %10 minimum yüz boyutu
    );
    _faceDetector = FaceDetector(options: options);
    _isInitialized = true;
    debugPrint('✅ FaceDetector initialized with minFaceSize: 0.10');
  }

  bool get isInitialized => _isInitialized;

  /// Yüz yönünü tespit et ve güvenilirlik skorunu hesapla
  /// headEulerAngleY değerlerine göre:
  /// -10 ile +10 arası: Ön
  /// < -10: Sol
  /// > +10: Sağ
  Future<Map<String, dynamic>> detectFaceDirection(XFile imageFile) async {
    if (!_isInitialized) {
      debugPrint('❌ Face detector is not initialized');
      return {
        'direction': FaceDirection.unknown,
        'confidence': 0.0,
        'angle': null,
      };
    }

    try {
      debugPrint('📸 Processing image: ${imageFile.path}');
      
      final inputImage = InputImage.fromFile(File(imageFile.path));
      debugPrint('✅ InputImage created');
      
      debugPrint('🔍 Starting face detection...');
      final faces = await _faceDetector.processImage(inputImage);
      debugPrint('✅ Face detection completed. Found ${faces.length} face(s)');

      if (faces.isEmpty) {
        debugPrint('⚠️ No face detected in image');
        return {
          'direction': FaceDirection.unknown,
          'confidence': 0.0,
          'angle': null,
        };
      }

      // İlk tespit edilen yüzü al
      final face = faces.first;
      final headEulerAngleY = face.headEulerAngleY;
      final headEulerAngleZ = face.headEulerAngleZ;
      final boundingBox = face.boundingBox;

      debugPrint('👤 Face found! Bounding box: ${boundingBox.width.toInt()}x${boundingBox.height.toInt()}');
      debugPrint('📐 Head Euler Angle Y: $headEulerAngleY');
      debugPrint('📐 Head Euler Angle Z: $headEulerAngleZ');
      
      // Landmark'ları logla
      debugPrint('🎯 Landmarks:');
      if (face.landmarks[FaceLandmarkType.leftEye] != null) {
        debugPrint('  ✓ Left Eye detected');
      }
      if (face.landmarks[FaceLandmarkType.rightEye] != null) {
        debugPrint('  ✓ Right Eye detected');
      }
      if (face.landmarks[FaceLandmarkType.noseBase] != null) {
        debugPrint('  ✓ Nose Base detected');
      }

      // Null kontrolü - eğer açı null ise ÖN olarak kabul et
      if (headEulerAngleY == null) {
        debugPrint('⚠️ Head angle is null - assuming FRONT');
        return {
          'direction': FaceDirection.front,
          'confidence': 0.5,
          'angle': 0.0,
        };
      }

      // Yön belirleme (daha toleranslı)
      FaceDirection direction;
      double confidence;
      
      if (headEulerAngleY >= -10 && headEulerAngleY <= 10) {
        direction = FaceDirection.front;
        // Açı 0'a ne kadar yakınsa güvenilirlik o kadar yüksek
        confidence = 1.0 - (headEulerAngleY.abs() / 10.0);
        debugPrint('👤 Direction: FRONT (angle: $headEulerAngleY°, confidence: ${(confidence * 100).toInt()}%)');
      } else if (headEulerAngleY < -10) {
        direction = FaceDirection.left;
        // -10 ile -60 arası için güvenilirlik hesapla
        if (headEulerAngleY >= -60) {
          confidence = 0.8;
        } else {
          confidence = 0.5; // Çok ekstrem açı
        }
        debugPrint('👈 Direction: LEFT (angle: $headEulerAngleY°, confidence: ${(confidence * 100).toInt()}%)');
      } else {
        direction = FaceDirection.right;
        // +10 ile +60 arası için güvenilirlik hesapla
        if (headEulerAngleY <= 60) {
          confidence = 0.8;
        } else {
          confidence = 0.5; // Çok ekstrem açı
        }
        debugPrint('👉 Direction: RIGHT (angle: $headEulerAngleY°, confidence: ${(confidence * 100).toInt()}%)');
      }
      
      return {
        'direction': direction,
        'confidence': confidence,
        'angle': headEulerAngleY,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Error detecting face direction: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'direction': FaceDirection.unknown,
        'confidence': 0.0,
        'angle': null,
      };
    }
  }

  /// Yüzün kalitesini kontrol et
  /// Görüntü boyutuna göre yüzün %6'dan büyük olup olmadığını kontrol eder
  Future<Map<String, dynamic>> checkFaceQuality(XFile imageFile) async {
    if (!_isInitialized) {
      debugPrint('❌ Face detector not initialized for quality check');
      return {
        'quality': FaceQuality.bad,
        'isGood': false,
        'facePercentage': 0.0,
        'message': 'Yüz algılayıcı hazır değil',
      };
    }

    try {
      final inputImage = InputImage.fromFile(File(imageFile.path));
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        debugPrint('❌ No face found for quality check');
        return {
          'quality': FaceQuality.bad,
          'isGood': false,
          'facePercentage': 0.0,
          'message': 'Yüz tespit edilemedi',
        };
      }

      final face = faces.first;
      final boundingBox = face.boundingBox;
      final faceArea = boundingBox.width * boundingBox.height;
      
      // Görüntü boyutunu al
      final imageWidth = inputImage.metadata?.size.width ?? 1920.0;
      final imageHeight = inputImage.metadata?.size.height ?? 1080.0;
      final imageArea = imageWidth * imageHeight;
      
      // Yüzün görüntüdeki yüzdesini hesapla
      final facePercentage = (faceArea / imageArea) * 100;
      
      debugPrint('📊 Image: ${imageWidth.toInt()}x${imageHeight.toInt()} (${imageArea.toInt()} px²)');
      debugPrint('📊 Face: ${boundingBox.width.toInt()}x${boundingBox.height.toInt()} (${faceArea.toInt()} px²)');
      debugPrint('📊 Face coverage: ${facePercentage.toStringAsFixed(2)}%');

      // Minimum %6 yüz kapsamı kontrolü
      if (facePercentage < 6.0) {
        debugPrint('⚠️ Face is too small: ${facePercentage.toStringAsFixed(2)}% < 6%');
        return {
          'quality': FaceQuality.tooFar,
          'isGood': false,
          'facePercentage': facePercentage,
          'message': 'Biraz yaklaş',
        };
      }

      // Yüz çok büyükse (ekranın %50'sinden fazlası)
      if (facePercentage > 50.0) {
        debugPrint('⚠️ Face is too large: ${facePercentage.toStringAsFixed(2)}% > 50%');
        return {
          'quality': FaceQuality.tooSmall,
          'isGood': false,
          'facePercentage': facePercentage,
          'message': 'Biraz uzaklaş',
        };
      }

      debugPrint('✅ Face quality OK. Coverage: ${facePercentage.toStringAsFixed(2)}%');
      return {
        'quality': FaceQuality.good,
        'isGood': true,
        'facePercentage': facePercentage,
        'message': 'Yüz kalitesi iyi',
      };
    } catch (e) {
      debugPrint('❌ Error checking face quality: $e');
      return {
        'quality': FaceQuality.bad,
        'isGood': false,
        'facePercentage': 0.0,
        'message': 'Kalite kontrolü başarısız: $e',
      };
    }
  }

  /// Yüz ve yön kontrolünü birlikte yap - JSON formatında sonuç döndür
  /// {detected: direction, confidence: value, quality: good/bad, message: string}
  Future<Map<String, dynamic>> analyzeFace(
    XFile imageFile,
    FaceDirection expectedDirection,
  ) async {
    debugPrint('🔬 ========== FACE ANALYSIS START ==========');
    debugPrint('🎯 Expected direction: $expectedDirection');
    
    // 1. Yön tespiti
    final directionResult = await detectFaceDirection(imageFile);
    final detectedDirection = directionResult['direction'] as FaceDirection;
    final confidence = directionResult['confidence'] as double;
    final angle = directionResult['angle'];
    
    // 2. Kalite kontrolü
    final qualityResult = await checkFaceQuality(imageFile);
    final isQualityGood = qualityResult['isGood'] as bool;
    final facePercentage = qualityResult['facePercentage'] as double;
    final qualityMessage = qualityResult['message'] as String;
    
    // 3. Yön doğruluğunu kontrol et
    final isCorrectDirection = detectedDirection == expectedDirection;

    // 4. Sonuç mesajı oluştur
    String message;
    if (detectedDirection == FaceDirection.unknown) {
      message = 'Yüz tespit edilemedi';
    } else if (!isQualityGood) {
      message = qualityMessage;
    } else if (!isCorrectDirection) {
      message = 'Yanlış yön! ${_getDirectionName(expectedDirection)} olmalı';
    } else {
      message = '✓ Başarılı!';
    }

    final isValid = isCorrectDirection && isQualityGood;

    debugPrint('📊 ========== ANALYSIS RESULT ==========');
    debugPrint('  Detected: $detectedDirection (angle: $angle°)');
    debugPrint('  Expected: $expectedDirection');
    debugPrint('  Direction match: $isCorrectDirection');
    debugPrint('  Confidence: ${(confidence * 100).toInt()}%');
    debugPrint('  Quality: ${isQualityGood ? 'GOOD' : 'BAD'}');
    debugPrint('  Face coverage: ${facePercentage.toStringAsFixed(1)}%');
    debugPrint('  Overall valid: $isValid');
    debugPrint('  Message: $message');
    debugPrint('========================================');

    return {
      'detected': detectedDirection,
      'expected': expectedDirection,
      'confidence': confidence,
      'angle': angle,
      'quality': isQualityGood ? 'good' : 'bad',
      'facePercentage': facePercentage,
      'isCorrectDirection': isCorrectDirection,
      'isQualityGood': isQualityGood,
      'isValid': isValid,
      'message': message,
    };
  }

  String _getDirectionName(FaceDirection direction) {
    switch (direction) {
      case FaceDirection.front:
        return 'Ön yüz';
      case FaceDirection.left:
        return 'Sol tarafa dön';
      case FaceDirection.right:
        return 'Sağ tarafa dön';
      case FaceDirection.unknown:
        return 'Bilinmiyor';
    }
  }

  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
      _isInitialized = false;
    }
  }
}
