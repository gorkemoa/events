import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  CameraDescription? _currentCamera;
  bool _isInitialized = false;
  bool _isStreamingImages = false;

  CameraController? get controller => _controller;
  CameraDescription? get currentCamera => _currentCamera;
  bool get isInitialized => _isInitialized;
  bool get isStreamingImages => _isStreamingImages;

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

    _currentCamera = frontCamera;
    debugPrint('📷 Using camera: ${frontCamera.name} (${frontCamera.lensDirection})');

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium, // Medium çözünürlük - daha hızlı ve yeterli
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      
      // Otomatik odaklama ve pozlama modunu ayarla
      if (_controller!.value.isInitialized) {
        await _controller!.setFocusMode(FocusMode.auto);
        await _controller!.setExposureMode(ExposureMode.auto);
        
        // Fotoğrafların dönmesini engelle - portrait modunda kilitle
        await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
        debugPrint('✅ Auto focus, exposure enabled and orientation locked to portrait');
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

  /// Canlı görüntü akışını başlat
  Future<void> startImageStream(void Function(CameraImage image) onImage) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint('❌ Camera is not initialized for streaming');
      return;
    }

    if (_isStreamingImages) {
      debugPrint('⚠️ Already streaming images');
      return;
    }

    try {
      await _controller!.startImageStream(onImage);
      _isStreamingImages = true;
      debugPrint('✅ Image stream started');
    } catch (e) {
      debugPrint('❌ Error starting image stream: $e');
    }
  }

  /// Görüntü akışını durdur
  Future<void> stopImageStream() async {
    if (_controller == null || !_isStreamingImages) {
      return;
    }

    try {
      await _controller!.stopImageStream();
      _isStreamingImages = false;
      debugPrint('✅ Image stream stopped');
    } catch (e) {
      debugPrint('❌ Error stopping image stream: $e');
    }
  }

  void dispose() {
    if (_isStreamingImages) {
      stopImageStream();
    }
    _controller?.dispose();
    _isInitialized = false;
  }
}
