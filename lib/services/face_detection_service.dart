import 'dart:io';
import 'dart:ui';
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
      enableContours: true,
      enableClassification: false,
      enableTracking: false,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.05, // Daha küçük yüzleri de algıla
    );
    _faceDetector = FaceDetector(options: options);
    _isInitialized = true;
    debugPrint('✅ FaceDetector initialized - minFaceSize: 0.05 (5%)');
  }

  bool get isInitialized => _isInitialized;

  /// CameraImage'dan yüz algıla (CANLI TESPIT)
  Future<Map<String, dynamic>> detectFaceFromCameraImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) async {
    if (!_isInitialized) {
      debugPrint('❌ FaceDetector is not initialized');
      return {
        'faceDetected': false,
        'boundingBox': null,
        'direction': FaceDirection.unknown,
      };
    }

    try {
      // CameraImage'ı InputImage'a çevir
      final inputImage = _inputImageFromCameraImage(cameraImage, camera);
      
      if (inputImage == null) {
        return {
          'faceDetected': false,
          'boundingBox': null,
          'direction': FaceDirection.unknown,
        };
      }

      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        return {
          'faceDetected': false,
          'boundingBox': null,
          'direction': FaceDirection.unknown,
        };
      }

      final face = faces.first;
      final boundingBox = face.boundingBox;
      
      return {
        'faceDetected': true,
        'boundingBox': {
          'x': boundingBox.left.toInt(),
          'y': boundingBox.top.toInt(),
          'width': boundingBox.width.toInt(),
          'height': boundingBox.height.toInt(),
        },
        'direction': _detectDirectionFromFace(face),
        'headEulerAngleY': face.headEulerAngleY,
        'confidence': face.headEulerAngleY != null ? 0.9 : 0.5,
      };
    } catch (e) {
      debugPrint('❌ Error in live detection: $e');
      return {
        'faceDetected': false,
        'boundingBox': null,
        'direction': FaceDirection.unknown,
      };
    }
  }

  /// CameraImage'ı InputImage'a çevir
  InputImage? _inputImageFromCameraImage(
    CameraImage cameraImage,
    CameraDescription camera,
  ) {
    // Kamera rotasyonunu belirle
    final rotation = _rotationIntToImageRotation(
      camera.sensorOrientation,
    );

    // Image format belirle
    final format = _formatFromCameraImage(cameraImage);
    if (format == null) return null;

    // InputImageMetadata oluştur
    final inputImageMetadata = InputImageMetadata(
      size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    );

    // InputImage oluştur
    final bytes = _concatenatePlanes(cameraImage.planes);
    
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetadata,
    );
  }

  /// Plane'leri birleştir
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  /// CameraImage formatını InputImageFormat'a çevir
  InputImageFormat? _formatFromCameraImage(CameraImage image) {
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return null;
    }
  }

  /// Kamera rotasyonunu InputImageRotation'a çevir
  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// Kameradan gelen frame'i işle ve yüz algıla
  /// XFile'dan yüz tespiti yapar
  Future<Map<String, dynamic>> detectFaceInFrame(XFile imageFile, CameraDescription? camera) async {
    if (!_isInitialized) {
      debugPrint('❌ FaceDetector is not initialized');
      return {
        'faceDetected': false,
        'boundingBox': null,
        'direction': FaceDirection.unknown,
      };
    }

    try {
      debugPrint('📸 Processing image: ${imageFile.path}');
      
      // Görüntü dosyasını oku
      final file = File(imageFile.path);
      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;
      
      debugPrint('📦 Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      
      // InputImage oluştur - iOS için fromFilePath en iyi çalışır
      debugPrint('🔍 Creating InputImage from file...');
      final inputImage = InputImage.fromFilePath(imageFile.path);
      
      if (camera != null) {
        debugPrint('📐 Camera info: ${camera.name}');
        debugPrint('📐 Sensor orientation: ${camera.sensorOrientation}°');
        debugPrint('📐 Lens direction: ${camera.lensDirection}');
      }
      
      debugPrint('🔍 Starting face detection...');
      final faces = await _faceDetector.processImage(inputImage);
      debugPrint('✅ Face detection completed. Found ${faces.length} face(s)');
      
      if (faces.isEmpty) {
        debugPrint('⚠️ No face detected in image');
        debugPrint('💡 Tip: Ensure good lighting, face the camera directly, and stay at arm\'s length');
        return {
          'faceDetected': false,
          'boundingBox': null,
          'direction': FaceDirection.unknown,
        };
      }

      final face = faces.first;
      final boundingBox = face.boundingBox;
      
      debugPrint('✅ Yüz bulundu!');
      debugPrint('👤 Bounding box: ${boundingBox.width.toInt()}x${boundingBox.height.toInt()} at (${boundingBox.left.toInt()}, ${boundingBox.top.toInt()})');
      debugPrint('📊 Tracking ID: ${face.trackingId}');
      debugPrint('📐 Head angles - Y: ${face.headEulerAngleY}, Z: ${face.headEulerAngleZ}');
      
      return {
        'faceDetected': true,
        'boundingBox': {
          'x': boundingBox.left.toInt(),
          'y': boundingBox.top.toInt(),
          'width': boundingBox.width.toInt(),
          'height': boundingBox.height.toInt(),
        },
        'direction': _detectDirectionFromFace(face),
        'headEulerAngleY': face.headEulerAngleY,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ Error detecting face: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'faceDetected': false,
        'boundingBox': null,
        'direction': FaceDirection.unknown,
      };
    }
  }

  /// Yüz yönünü Face nesnesinden tespit et
  FaceDirection _detectDirectionFromFace(Face face) {
    final headEulerAngleY = face.headEulerAngleY;
    
    if (headEulerAngleY == null) {
      return FaceDirection.front;
    }
    
    if (headEulerAngleY >= -10 && headEulerAngleY <= 10) {
      return FaceDirection.front;
    } else if (headEulerAngleY < -10) {
      return FaceDirection.left;
    } else {
      return FaceDirection.right;
    }
  }

  /// Yüz ve yön kontrolünü birlikte yap - XFile ile çalışır
  Future<Map<String, dynamic>> analyzeFace(
    XFile imageFile,
    FaceDirection expectedDirection, {
    CameraDescription? camera,
  }) async {
    debugPrint('🔬 ========== FACE ANALYSIS START ==========');
    debugPrint('🎯 Expected direction: $expectedDirection');
    
    // Frame'den yüz algılama
    final result = await detectFaceInFrame(imageFile, camera);
    final faceDetected = result['faceDetected'] as bool;
    final boundingBox = result['boundingBox'] as Map<String, dynamic>?;
    final detectedDirection = result['direction'] as FaceDirection;
    
    if (!faceDetected || boundingBox == null) {
      debugPrint('❌ No face detected');
      return {
        'detected': FaceDirection.unknown,
        'expected': expectedDirection,
        'isValid': false,
        'message': 'Yüz tespit edilemedi',
      };
    }
    
    debugPrint('✅ Yüz bulundu!');
    
    // Yön doğruluğunu kontrol et
    final isCorrectDirection = detectedDirection == expectedDirection;
    
    // Kalite kontrolü - basit bounding box boyutu kontrolü
    final faceWidth = boundingBox['width'] as int;
    final faceHeight = boundingBox['height'] as int;
    final faceArea = faceWidth * faceHeight;
    
    // Tahmin edilen görüntü boyutu (kameradan geldiği için)
    const imageArea = 720 * 1280; // Standart kamera çözünürlüğü
    final facePercentage = (faceArea / imageArea) * 100;
    
    final isQualityGood = facePercentage >= 6.0 && facePercentage <= 50.0;
    
    // Sonuç mesajı
    String message;
    if (!isQualityGood) {
      if (facePercentage < 6.0) {
        message = 'Biraz yaklaş';
      } else {
        message = 'Biraz uzaklaş';
      }
    } else if (!isCorrectDirection) {
      message = 'Yanlış yön! ${_getDirectionName(expectedDirection)} olmalı';
    } else {
      message = '✓ Başarılı!';
    }
    
    final isValid = isCorrectDirection && isQualityGood;
    
    debugPrint('📊 ========== ANALYSIS RESULT ==========');
    debugPrint('  Detected: $detectedDirection');
    debugPrint('  Expected: $expectedDirection');
    debugPrint('  Direction match: $isCorrectDirection');
    debugPrint('  Quality: ${isQualityGood ? 'GOOD' : 'BAD'}');
    debugPrint('  Face coverage: ${facePercentage.toStringAsFixed(1)}%');
    debugPrint('  Bounding box: $boundingBox');
    debugPrint('  Overall valid: $isValid');
    debugPrint('  Message: $message');
    debugPrint('========================================');
    
    return {
      'detected': detectedDirection,
      'expected': expectedDirection,
      'boundingBox': boundingBox,
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
      debugPrint('🗑️ FaceDetector disposed');
    }
  }
}
