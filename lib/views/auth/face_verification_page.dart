import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/camera_service.dart';
import 'package:pixlomi/services/face_detection_service.dart';
import 'package:pixlomi/services/face_photo_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';

class FaceVerificationPage extends StatefulWidget {
  final bool isUpdateMode;
  
  const FaceVerificationPage({
    Key? key,
    this.isUpdateMode = false,
  }) : super(key: key);

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final FacePhotoService _facePhotoService = FacePhotoService();

  int _currentStep = 0;
  bool _isProcessing = false;
  bool _isCameraReady = false;
  String _statusMessage = '';
  bool _hasPermission = false;
  bool _isDetecting = false;
  DateTime? _lastDetectionTime;

  // Fotoğrafları saklamak için
  final Map<String, XFile?> _capturedImages = {
    'front': null,
    'left': null,
    'right': null,
  };

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Ön Yüz',
      'description': 'Yüzünüzü ekran ortasında hizalayın',
      'instruction': 'Düz bakın ve sabit durun',
      'direction': FaceDirection.front,
      'icon': Icons.face,
      'key': 'front',
    },
    {
      'title': 'Sol Taraf',
      'description': 'Başınızı yavaşça sola çevirin',
      'instruction': 'Yaklaşık 30° açıyla sabit durun',
      'direction': FaceDirection.left,
      'icon': Icons.arrow_back,
      'key': 'left',
    },
    {
      'title': 'Sağ Taraf',
      'description': 'Başınızı yavaşça sağa çevirin',
      'instruction': 'Yaklaşık 30° açıyla sabit durun',
      'direction': FaceDirection.right,
      'icon': Icons.arrow_forward,
      'key': 'right',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Direkt kamerayı başlatmayı dene - bu native izin popup'ı tetikler
    _initializeCameraDirectly();
  }

  Future<void> _initializeCameraDirectly() async {
    try {
      debugPrint('📷 Attempting to initialize camera (will trigger native permission)...');
      
      // availableCameras() çağrısı iOS'ta otomatik olarak native izin popup'ı açar
      await _cameraService.initializeCameras();
      bool initialized = await _cameraService.initializeCamera();

      if (initialized && mounted) {
        debugPrint('✅ Camera initialized successfully');
        setState(() {
          _isCameraReady = true;
          _hasPermission = true;
          _statusMessage = 'Hazır! Pozisyon: ${_steps[_currentStep]['title']}';
        });
        _startLiveDetection();
      } else {
        debugPrint('❌ Camera initialization failed');
        setState(() {
          _hasPermission = false;
          _statusMessage = 'Kamera başlatılamadı';
        });
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      
      // Hata mesajına göre durum belirle
      if (e.toString().contains('denied') || e.toString().contains('authorized')) {
        setState(() {
          _hasPermission = false;
          _statusMessage = 'Kamera izni gerekli.\n\nAyarlar > Events > Kamera';
        });
        _showPermissionDialog();
      } else {
        setState(() {
          _hasPermission = false;
          _statusMessage = 'Kamera hatası: $e';
        });
      }
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    // Bu fonksiyon "İzin Ver" butonuna basıldığında çağrılır
    debugPrint('📷 User clicked permission button, trying camera again...');
    
    var status = await Permission.camera.status;
    debugPrint('📷 Current permission status: $status');
    
    if (status.isPermanentlyDenied) {
      debugPrint('🚫 Opening app settings...');
      await openAppSettings();
    } else {
      // Tekrar kamera başlatmayı dene
      await _initializeCameraDirectly();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kamera İzni Gerekli'),
        content: const Text(
          'Yüz doğrulaması için kamera iznine ihtiyacımız var.\n\n'
          'Lütfen:\n'
          '1. Ayarlar\'a gidin\n'
          '2. Events uygulamasını bulun\n'
          '3. Kamera iznini açın',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Ayarları Aç'),
          ),
        ],
      ),
    );
  }

  void _startLiveDetection() async {
    if (!_isCameraReady) return;

    setState(() {
      _statusMessage = '🎯 "${_steps[_currentStep]['title']}" pozisyonuna geçin';
    });

    // 2 saniye bekle - kullanıcı hazırlansın
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    debugPrint('📹 Starting live face detection...');

    await _cameraService.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      
      // Saniyede 2 kez kontrol et (500ms aralık)
      final now = DateTime.now();
      if (_lastDetectionTime != null && 
          now.difference(_lastDetectionTime!).inMilliseconds < 500) {
        return;
      }
      
      _lastDetectionTime = now;
      _processFrame(image);
    });
  }

  void _processFrame(CameraImage image) async {
    if (_isDetecting || !mounted) return;
    
    _isDetecting = true;

    try {
      final camera = _cameraService.currentCamera;
      if (camera == null) {
        _isDetecting = false;
        return;
      }

      final expectedDirection = _steps[_currentStep]['direction'] as FaceDirection;
      
      // Canlı yüz tespiti
      final result = await _faceDetectionService.detectFaceFromCameraImage(image, camera);
      
      if (!mounted) {
        _isDetecting = false;
        return;
      }

      final faceDetected = result['faceDetected'] as bool;
      
      if (!faceDetected) {
        setState(() {
          _statusMessage = '👤 Yüzünüzü kameraya gösterin';
        });
        _isDetecting = false;
        return;
      }

      // Yüz bulundu!
      final detectedDirection = result['direction'] as FaceDirection;
      final isCorrect = detectedDirection == expectedDirection;

      if (isCorrect) {
        debugPrint('✅ Doğru yön tespit edildi: $detectedDirection');
        
        // Stream'i durdur
        await _cameraService.stopImageStream();
        
        if (!mounted) return;

        // Fotoğraf çek
        try {
          final photo = await _cameraService.takePicture();
          if (photo != null) {
            final stepKey = _steps[_currentStep]['key'] as String;
            _capturedImages[stepKey] = photo;
            debugPrint('📸 Photo captured for $stepKey: ${photo.path}');
          }
        } catch (e) {
          debugPrint('❌ Photo capture error: $e');
        }
        
        _showSuccess('✓ Başarılı!');
        await Future.delayed(const Duration(milliseconds: 1000));

        if (_currentStep < _steps.length - 1) {
          if (mounted) {
            setState(() {
              _currentStep++;
              _isDetecting = false;
            });
            await Future.delayed(const Duration(milliseconds: 500));
            _startLiveDetection();
          }
        } else {
          if (mounted) {
            _completeVerification();
          }
        }
      } else {
        final directionName = _getDirectionName(expectedDirection);
        setState(() {
          _statusMessage = '↻ $directionName';
        });
      }
    } catch (e) {
      debugPrint('❌ Frame processing error: $e');
    }
    
    _isDetecting = false;
  }

  String _getDirectionName(FaceDirection direction) {
    switch (direction) {
      case FaceDirection.front:
        return 'Düz bakın';
      case FaceDirection.left:
        return 'Sola dönün';
      case FaceDirection.right:
        return 'Sağa dönün';
      case FaceDirection.unknown:
        return 'Yüz bulunamadı';
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_steps[_currentStep]['title']} başarılı!'),
        backgroundColor: AppTheme.success,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _completeVerification() async {
    // Önce fotoğrafları API'ye yükle
    setState(() {
      _statusMessage = 'Fotoğraflar yükleniyor...';
    });

    final success = await _uploadFacesToAPI();

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotoğraflar yüklenirken bir hata oluştu. Lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing2XL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 50,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  widget.isUpdateMode ? 'Güncelleme Başarılı!' : 'Doğrulama Başarılı!',
                  style: AppTheme.headingSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  widget.isUpdateMode ? 'Fotoğraflarınız güncellendi!' : 'Yüz taraması tamamlandı!',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing2XL),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.isUpdateMode) {
                        // Güncelleme modunda fotoğraflar sayfasına geri dön
                        Navigator.of(context).pushReplacementNamed('/facePhotos');
                      } else {
                        // İlk kayıt modunda home'a git
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    child: Text(
                      'Devam Et',
                      style: AppTheme.buttonMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _uploadFacesToAPI() async {
    try {
      debugPrint('📤 Starting photo upload to API...');

      // userToken'ı al
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        debugPrint('❌ User token not found');
        return false;
      }

      // Tüm fotoğrafların çekildiğinden emin ol
      if (_capturedImages['front'] == null ||
          _capturedImages['left'] == null ||
          _capturedImages['right'] == null) {
        debugPrint('❌ Missing photos');
        return false;
      }

      // Fotoğrafları Base64'e çevir - EXIF orientation'a göre düzelt
      final frontBytes = await _capturedImages['front']!.readAsBytes();
      final leftBytes = await _capturedImages['left']!.readAsBytes();
      final rightBytes = await _capturedImages['right']!.readAsBytes();

      // Image paketini kullanarak fotoğrafları decode et ve EXIF'e göre düzelt
      var frontImage = img.decodeImage(frontBytes);
      var leftImage = img.decodeImage(leftBytes);
      var rightImage = img.decodeImage(rightBytes);

      if (frontImage == null || leftImage == null || rightImage == null) {
        debugPrint('❌ Could not decode images');
        return false;
      }

      // EXIF orientation varsa otomatik düzelt
      frontImage = img.bakeOrientation(frontImage);
      leftImage = img.bakeOrientation(leftImage);
      rightImage = img.bakeOrientation(rightImage);

      // Yeniden JPEG olarak encode et
      final frontCorrected = img.encodeJpg(frontImage, quality: 85);
      final leftCorrected = img.encodeJpg(leftImage, quality: 85);
      final rightCorrected = img.encodeJpg(rightImage, quality: 85);

      final frontBase64 = base64Encode(frontCorrected);
      final leftBase64 = base64Encode(leftCorrected);
      final rightBase64 = base64Encode(rightCorrected);

      // Data URI prefix ekle
      final frontDataUri = 'data:image/jpeg;base64,$frontBase64';
      final leftDataUri = 'data:image/jpeg;base64,$leftBase64';
      final rightDataUri = 'data:image/jpeg;base64,$rightBase64';

      debugPrint('✅ Photos converted to Base64 with data URI');
      debugPrint('  - Front: ${frontDataUri.length} chars');
      debugPrint('  - Left: ${leftDataUri.length} chars');
      debugPrint('  - Right: ${rightDataUri.length} chars');

      // Request modelini oluştur
      final request = FacePhotoRequest(
        userToken: userToken,
        frontPhoto: frontDataUri,
        leftPhoto: leftDataUri,
        rightPhoto: rightDataUri,
      );

      // Service'i kullanarak API çağrısı yap
      final response = widget.isUpdateMode
          ? await _facePhotoService.updateFacePhotos(request: request)
          : await _facePhotoService.addFacePhotos(request: request);

      if (response.isSuccess) {
        debugPrint('✅ Photos ${widget.isUpdateMode ? "updated" : "uploaded"} successfully');
        return true;
      } else {
        debugPrint('❌ Upload failed: ${response.errorMessage}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return false;
    }
  }

  void _skipVerification() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _cameraService.stopImageStream();
    _cameraService.dispose();
    _faceDetectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _skipVerification,
            child: const Text('Atla', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing2XL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 80, color: AppTheme.textTertiary),
                    const SizedBox(height: AppTheme.spacingXL),
                    Text('Kamera İzni Gerekli', style: AppTheme.headingSmall, textAlign: TextAlign.center),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(_statusMessage, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppTheme.spacing2XL),
                    ElevatedButton(onPressed: _checkAndRequestPermissions, child: const Text('İzin Ver' , style: TextStyle(color: AppTheme.backgroundColor),)),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing2XL),
                child: Column(
                  children: [
                    Text('Yüz Doğrulaması', style: AppTheme.headingMedium),
                    const SizedBox(height: AppTheme.spacingS),
                    Text('3 aşamalı yüz taraması', style: AppTheme.bodyMedium),
                    const SizedBox(height: AppTheme.spacing2XL),
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isProcessing ? AppTheme.primary : AppTheme.dividerColor,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _isCameraReady && _cameraService.controller != null
                            ? CameraPreview(_cameraService.controller!)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2XL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index < _currentStep
                                      ? AppTheme.success
                                      : index == _currentStep
                                          ? AppTheme.primary
                                          : AppTheme.surfaceColor,
                                  border: Border.all(
                                    color: index <= _currentStep ? AppTheme.primary : AppTheme.dividerColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  index < _currentStep ? Icons.check : _steps[index]['icon'],
                                  color: index <= _currentStep ? Colors.white : AppTheme.textTertiary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _steps[index]['title'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: index <= _currentStep ? AppTheme.primary : AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppTheme.spacing2XL),
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(_steps[_currentStep]['description'], style: AppTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text(_steps[_currentStep]['instruction'], style: AppTheme.captionLarge),
                        ],
                      ),
                    ),
                    if (_statusMessage.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      Text(_statusMessage, style: AppTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
