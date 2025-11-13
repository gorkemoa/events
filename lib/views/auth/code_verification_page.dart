import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/face_photo_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';

class CodeVerificationPage extends StatefulWidget {
  const CodeVerificationPage({Key? key}) : super(key: key);

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final _authService = AuthService();
  final _facePhotoService = FacePhotoService();
  final _codeControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  late FocusNode _focusNode0;
  late FocusNode _focusNode1;
  late FocusNode _focusNode2;
  late FocusNode _focusNode3;
  late FocusNode _focusNode4;
  late FocusNode _focusNode5;
  
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;
  String? _codeToken;
  String? _errorMessage;
  int _resendCounter = 0;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _focusNode0 = FocusNode();
    _focusNode1 = FocusNode();
    _focusNode2 = FocusNode();
    _focusNode3 = FocusNode();
    _focusNode4 = FocusNode();
    _focusNode5 = FocusNode();

    _focusNodes = [_focusNode0, _focusNode1, _focusNode2, _focusNode3, _focusNode4, _focusNode5];

    _loadCodeToken();
  }

  Future<void> _loadCodeToken() async {
    final codeToken = await StorageHelper.getCodeToken();
    setState(() {
      _codeToken = codeToken;
    });
    
    // Debug: Storage'daki tüm verileri kontrol et
    final userId = await StorageHelper.getUserId();
    final userToken = await StorageHelper.getUserToken();
    print('🔍 Storage Check on CodeVerification Page:');
    print('  - codeToken: $codeToken');
    print('  - userId: $userId');
    print('  - userToken: ${userToken?.substring(0, 10) ?? "null"}...');
    
    if (codeToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kod token\'ı bulunamadı'), backgroundColor: Colors.red),
      );
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.isEmpty) {
      return;
    }

    // Yapıştırma durumu - tüm kodu dağıt
    if (value.length > 1) {
      final code = value.replaceAll(RegExp(r'\D'), ''); // Sadece rakamlar
      for (int i = 0; i < code.length && i < 6; i++) {
        _codeControllers[i].text = code[i];
      }
      // Son dolu kutuya focus yap
      final lastIndex = (code.length - 1).clamp(0, 5);
      FocusScope.of(context).requestFocus(_focusNodes[lastIndex]);
      
      // Eğer 6 hane tamamsa otomatik doğrula
      if (code.length == 6) {
        _verifyCode();
      }
      return;
    }

    // Tek karakter girişi
    _codeControllers[index].text = value;
    
    // Sonraki field'a geç
    if (index < _focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else {
      // Son field - otomatik doğrula
      _verifyCode();
    }
  }

  void _onKeyPressed(RawKeyEvent event, int index) {
    // Backspace/Delete tuşu
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace || 
          event.logicalKey == LogicalKeyboardKey.delete) {
        if (_codeControllers[index].text.isEmpty && index > 0) {
          // Kutu boşsa önceki kutuyu temizle ve ona geç
          _codeControllers[index - 1].clear();
          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          setState(() {
            _errorMessage = null;
          });
        } else if (_codeControllers[index].text.isNotEmpty) {
          // Kutu doluysa temizle
          _codeControllers[index].clear();
          setState(() {
            _errorMessage = null;
          });
        }
      }
    }
  }

  String _getFullCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _verifyCode() async {
    if (_codeToken == null) {
      setState(() {
        _errorMessage = 'Kod token\'ı bulunamadı';
      });
      return;
    }

    final code = _getFullCode();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Lütfen 6 haneli kodu girin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.verifyCode(
        code: code,
        codeToken: _codeToken!,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        print('✅ Code verified successfully!');
        
        // Not: userID ve userToken zaten signup sırasında kaydedildi
        // API'den yenisi gelirse güncelle
        String? finalUserToken;
        if (response.data != null && 
            response.data!.userID > 0 && 
            response.data!.userToken.isNotEmpty) {
          
          print('🔍 Updating user session from API response:');
          print('  - userID: ${response.data!.userID}');
          print('  - userToken: ${response.data!.userToken}');
          
          await StorageHelper.saveUserSession(
            userId: response.data!.userID,
            userToken: response.data!.userToken,
          );
          
          // Subscribe to Firebase topic with userId
          await FirebaseMessagingService.subscribeToUserTopic(response.data!.userID.toString());
          
          finalUserToken = response.data!.userToken;
        } else {
          print('ℹ️ API did not return user data, keeping existing session');
          finalUserToken = await StorageHelper.getUserToken();
        }

        // Yüz fotoğraflarını kontrol et
        if (finalUserToken != null) {
          final photosResponse = await _facePhotoService.getFacePhotos(
            userToken: finalUserToken,
          );
          
          if (!mounted) return;
          
          // Kayıt sonrası yüz fotoğrafları her zaman boş olmalı
          // Ama yine de kontrol edelim
          if (!photosResponse.isSuccess || photosResponse.data == null) {
            print('⚠️ Yüz fotoğrafları yok (beklenen durum), face_verification\'a yönlendiriliyor');
            Navigator.of(context).pushReplacementNamed('/faceVerification');
          } else {
            print('⚠️ Beklenmeyen durum: Yüz fotoğrafları mevcut, yine de face_verification\'a yönlendiriliyor');
            Navigator.of(context).pushReplacementNamed('/faceVerification');
          }
        } else {
          // Token yoksa face verification'a git (güvenli seçenek)
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/faceVerification');
          }
        }
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Kod doğrulanmadı';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resendCode() async {
    if (_isResending || _resendCounter > 0) return;

    // UserToken'ı al
    final userToken = await StorageHelper.getUserToken();
    if (userToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kullanıcı token\'ı bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.resendCode(userToken: userToken);

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        // Yeni codeToken'ı kaydet
        await StorageHelper.setCodeToken(response.data!.codeToken);
        
        setState(() {
          _codeToken = response.data!.codeToken;
          _isResending = false;
        });

        print('✅ New code sent successfully!');
        print('  - New codeToken: ${response.data!.codeToken}');

        // Başarı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Yeni kod gönderildi!'),
              backgroundColor: AppTheme.success,
            ),
          );
        }

        // Timer başlat (60 saniye)
        _startResendTimer();
      } else {
        setState(() {
          _isResending = false;
        });

        // Hata mesajı göster (örn: "169 saniye bekleyin")
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Kod gönderilemedi'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isResending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startResendTimer() {
    setState(() {
      _resendCounter = 60;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCounter > 0) {
        setState(() {
          _resendCounter--;
        });
        if (_resendCounter > 0) {
          _startResendTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2XL,
            vertical: AppTheme.spacingXL,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Kodu Doğrula',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'E-postanıza gönderilen 6 haneli kodu girin',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacing3XL),

              // Code Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.surfaceColor,
                      border: Border.all(
                        color: _errorMessage != null
                            ? Colors.red
                            : (_codeControllers[index].text.isNotEmpty
                                ? AppTheme.primary
                                : AppTheme.dividerColor),
                        width: 2,
                      ),
                      boxShadow: _codeControllers[index].text.isNotEmpty
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) => _onKeyPressed(event, index),
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        maxLength: 1,
                        onChanged: (value) {
                          setState(() {
                            _errorMessage = null;
                          });
                          _onCodeChanged(value, index);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        style: AppTheme.headingMedium.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppTheme.spacing3XL),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Doğrula',
                          style: AppTheme.buttonLarge,
                        ),
                ),
              ),

              const SizedBox(height: AppTheme.spacing2XL),

              // Resend Code
              Center(
                child: Column(
                  children: [
                    Text(
                      'Kodu almadınız mı?',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    GestureDetector(
                      onTap: (_resendCounter > 0 || _isResending) ? null : _resendCode,
                      child: _isResending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            )
                          : Text(
                              _resendCounter > 0 
                                  ? 'Yeniden gönder (${_resendCounter}s)' 
                                  : 'Yeniden gönder',
                              style: AppTheme.labelMedium.copyWith(
                                color: _resendCounter > 0
                                    ? AppTheme.textTertiary
                                    : AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
