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
import 'package:pixlomi/localizations/app_localizations.dart';

class FaceVerificationPage extends StatefulWidget {
  final bool isUpdateMode;
  
  const FaceVerificationPage({
    Key? key,
    this.isUpdateMode = false,
  }) : super(key: key);

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final FacePhotoService _facePhotoService = FacePhotoService();

  int _currentStep = 0;
  bool _isCameraReady = false;
  bool _hasPermission = false;
  bool _isDetecting = false;
  DateTime? _lastDetectionTime;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      'displayText': 'Ön Yüzünüzü Gösterin',
      'direction': FaceDirection.front,
      'icon': Icons.face,
      'key': 'front',
    },
    {
      'title': 'Sol Taraf',
      'description': 'Başınızı yavaşça sola çevirin',
      'instruction': 'Yaklaşık 30° açıyla sabit durun',
      'displayText': 'Sola Dönün',
      'direction': FaceDirection.left,
      'icon': Icons.arrow_back,
      'key': 'left',
    },
    {
      'title': 'Sağ Taraf',
      'description': 'Başınızı yavaşça sağa çevirin',
      'instruction': 'Yaklaşık 30° açıyla sabit durun',
      'displayText': 'Sağa Dönün',
      'direction': FaceDirection.right,
      'icon': Icons.arrow_forward,
      'key': 'right',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _animationController.forward();
    
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
        });
        _startLiveDetection();
      } else {
        debugPrint('❌ Camera initialization failed');
        setState(() {
          _hasPermission = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      
      // Hata mesajına göre durum belirle
      if (e.toString().contains('denied') || e.toString().contains('authorized')) {
        setState(() {
          _hasPermission = false;
        });
        _showPermissionDialog();
      } else {
        setState(() {
          _hasPermission = false;
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
          '2. Pixlomi uygulamasını bulun\n'
          '3. Kamera iznini açın',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
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
            // Animasyonu tekrar oynat
            _animationController.reset();
            _animationController.forward();
            await Future.delayed(const Duration(milliseconds: 500));
            _startLiveDetection();
          }
        } else {
          if (mounted) {
            _completeVerification();
          }
        }
      } else {
        // Wrong direction detected - user will see instruction in UI
      }
    } catch (e) {
      debugPrint('❌ Frame processing error: $e');
    }
    
    _isDetecting = false;
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    
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
                  widget.isUpdateMode ? context.tr('face_verification.completion_title_update') : context.tr('face_verification.completion_title'),
                  style: AppTheme.headingSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  widget.isUpdateMode ? context.tr('face_verification.completion_subtitle_update') : context.tr('face_verification.completion_subtitle'),
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
                        // Güncelleme modunda bir önceki sayfaya result ile dön
                        Navigator.of(context).pop(true);
                      } else {
                        // İlk kayıt modunda home'a git
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    child: Text(
                      context.tr('face_verification.button_continue'),
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

  @override
  void dispose() {
    _animationController.dispose();
    _cameraService.stopImageStream();
    _cameraService.dispose();
    _faceDetectionService.dispose();
    super.dispose();
  }

  Widget _buildPermissionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: widget.isUpdateMode 
          ? IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
        actions: widget.isUpdateMode
            ? null
            : [
               
              ],
      ),
      body: !_hasPermission
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing2XL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera Icon Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 60,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2XL),
                    
                    // Title
                    Text(
                      context.tr('face_verification.permission_title'),
                      style: AppTheme.headingMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    
                    // Description
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.tr('face_verification.permission_description'),
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2XL),
                    
                    // Steps
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('face_verification.permission_step1'),
                            style: AppTheme.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPermissionStep('1', context.tr('face_verification.permission_step1')),
                          const SizedBox(height: 8),
                          _buildPermissionStep('2', context.tr('face_verification.permission_step2')),
                          const SizedBox(height: 8),
                          _buildPermissionStep('3', context.tr('face_verification.permission_step3')),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing3XL),
                    
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _checkAndRequestPermissions,
                        icon: const Icon(Icons.settings, color: Colors.white),
                        label: Text(
                          context.tr('face_verification.permission_button'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryLight.withOpacity(0.05),
                    AppTheme.backgroundColor,
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Header - Üstte yazı
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXL,
                        vertical: AppTheme.spacingL,
                      ),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    _steps[_currentStep]['displayText'] as String,
                                    style: AppTheme.headingMedium.copyWith(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _steps[_currentStep]['instruction'] as String,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Camera Preview with Oval Frame
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Oval Camera Container
                            Container(
                              width: screenSize.width * 0.75,
                              height: screenSize.width * 1.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(screenSize.width * 0.375),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.secondary.withOpacity(0.2),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(screenSize.width * 0.375),
                                child: _isCameraReady && _cameraService.controller != null
                                    ? CameraPreview(_cameraService.controller!)
                                    : Container(
                                        color: AppTheme.surfaceColor,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.secondary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            
                            // Oval Border
                            Container(
                              width: screenSize.width * 0.75,
                              height: screenSize.width * 1.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(screenSize.width * 0.375),
                                border: Border.all(
                                  color: AppTheme.secondary,
                                  width: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Alt kısım - Buton ve progress
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: Column(
                        children: [
                          // Capture Button - Mavi yuvarlak
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.secondary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.secondary,
                                  border: Border.all(
                                    color: AppTheme.backgroundColor,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Progress Indicators - Alt çizgi stili
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_steps.length, (index) {
                              final isCompleted = index < _currentStep;
                              final isCurrent = index == _currentStep;
                              
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 60,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: isCompleted || isCurrent
                                      ? AppTheme.textSecondary
                                      : AppTheme.dividerColor,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
