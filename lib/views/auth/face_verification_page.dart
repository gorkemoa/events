import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/camera_service.dart';
import 'package:pixlomi/services/face_detection_service.dart';

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({Key? key}) : super(key: key);

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage> {
  final CameraService _cameraService = CameraService();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();

  int _currentStep = 0;
  bool _isProcessing = false;
  bool _isCameraReady = false;
  String _statusMessage = '';
  bool _hasPermission = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Ön Yüz',
      'description': 'Yüzünüzü ekran ortasında hizalayın',
      'instruction': 'Düz bakın ve sabit durun',
      'direction': FaceDirection.front,
      'icon': Icons.face,
    },
    {
      'title': 'Sol Taraf',
      'description': 'Başınızı yavaşça sola çevirin',
      'instruction': 'Yaklaşık 30° açıyla sabit durun',
      'direction': FaceDirection.left,
      'icon': Icons.arrow_back,
    },
    {
      'title': 'Sağ Taraf',
      'description': 'Başınızı yavaşça sağa çevirin',
      'instruction': 'Yaklaşık 30° açıyla sabit durun',
      'direction': FaceDirection.right,
      'icon': Icons.arrow_forward,
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
        _startAutoCapture();
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

  void _startAutoCapture() async {
    if (!_isCameraReady || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = '🎯 Hazırlanıyor...\n"${_steps[_currentStep]['title']}" pozisyonuna geçin';
    });

    // 2 saniye bekle - kullanıcı pozisyon alsın
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    setState(() {
      _statusMessage = '📸 Fotoğraf çekiliyor...';
    });

    if (!mounted) return;

    try {
      // Fotoğraf çek (içinde 0.5 saniye bekleme var)
      final image = await _cameraService.takePicture();

      if (image == null) {
        _showError('❌ Fotoğraf çekilemedi. Tekrar deneniyor...');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          _startAutoCapture();
        }
        return;
      }

      setState(() {
        _statusMessage = '🔍 Yüz analiz ediliyor...';
      });

      final expectedDirection = _steps[_currentStep]['direction'] as FaceDirection;
      final analysis = await _faceDetectionService.analyzeFace(image, expectedDirection);

      if (!mounted) return;

      // Sonucu göster
      final message = analysis['message'] as String;
      final isValid = analysis['isValid'] as bool;

      if (isValid) {
        _showSuccess(message);
        await Future.delayed(const Duration(milliseconds: 1000));

        if (_currentStep < _steps.length - 1) {
          if (mounted) {
            setState(() {
              _currentStep++;
              _isProcessing = false;
            });
            await Future.delayed(const Duration(milliseconds: 500));
            _startAutoCapture();
          }
        } else {
          if (mounted) {
            _completeVerification();
          }
        }
      } else {
        _showError(message);
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          _startAutoCapture();
        }
      }
    } catch (e) {
      _showError('❌ Hata: $e');
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _startAutoCapture();
      }
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

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
    });
  }

  void _completeVerification() {
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
                  'Doğrulama Başarılı!',
                  style: AppTheme.headingSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Yüz taraması tamamlandı!',
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
                      Navigator.of(context).pushReplacementNamed('/home');
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

  void _skipVerification() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
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
