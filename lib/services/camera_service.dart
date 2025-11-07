import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
      rethrow;
    }
  }

  Future<bool> initializeCamera() async {
    if (_cameras.isEmpty) {
      debugPrint('❌ No cameras available');
      return false;
    }

    // Ön kamerayı seç
    final frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    debugPrint('📷 Using camera: ${frontCamera.name} (${frontCamera.lensDirection})');

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high, // Yüksek çözünürlük - daha iyi yüz tespiti
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      
      // Otomatik odaklama ve pozlama modunu ayarla
      if (_controller!.value.isInitialized) {
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setExposureMode(ExposureMode.auto);
        debugPrint('✅ Auto focus and exposure enabled');
      }
      
      _isInitialized = true;
      debugPrint('✅ Camera controller initialized');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing camera controller: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Fotoğraf çekmeden önce odaklanma ve pozlamayı tamamla
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint('❌ Camera is not initialized');
      return null;
    }

    try {
      debugPrint('📸 Preparing to take picture...');
      
      // Odaklanma ve pozlama için kısa bir bekleme
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('📸 Taking picture...');
      final image = await _controller!.takePicture();
      debugPrint('✅ Picture taken: ${image.path}');
      
      // Dosya boyutunu kontrol et
      final file = await image.readAsBytes();
      debugPrint('📦 Image size: ${file.length} bytes (${(file.length / 1024).toStringAsFixed(2)} KB)');
      
      return image;
    } catch (e) {
      debugPrint('❌ Error taking picture: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}
