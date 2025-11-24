import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';
import 'package:pixlomi/localizations/app_localizations.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({Key? key}) : super(key: key);

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _userService = UserService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool _isFormComplete() {
    return _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          userName: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;

        if (response.isSuccess) {
          // Login successful - save user session
          final saved = await StorageHelper.saveUserSession(
            userId: response.data!.userId,
            userToken: response.data!.token,
          );
          
          print('💾 Session saved: $saved');
          print('  - userId: ${response.data!.userId}');
          print('  - token: ${response.data!.token.substring(0, 10)}...');
          
          // Subscribe to Firebase topic with userId
          await FirebaseMessagingService.subscribeToUserTopic(response.data!.userId.toString());
          
          if (!mounted) return;
          
          // Yüz fotoğraflarını kontrol et
          try {
            final photosResponse = await _userService.getUserById(
              userId: response.data!.userId,
              userToken: response.data!.token,
            );
            
            if (!mounted) return;
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.data?.message ?? 'Giriş başarılı!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Yüz fotoğraflarını kontrol et
            final hasFacePhotos = photosResponse.success && 
                                  photosResponse.data != null && 
                                  photosResponse.data!.user.frontImage.isNotEmpty &&
                                  photosResponse.data!.user.leftImage.isNotEmpty &&
                                  photosResponse.data!.user.rightImage.isNotEmpty;
            
            // Yüz fotoğrafları yoksa face_verification'a yönlendir
            if (!hasFacePhotos) {
              print('⚠️ Yüz fotoğrafları yok, face_verification\'a yönlendiriliyor');
              Navigator.of(context).pushReplacementNamed('/faceVerification');
            } else {
              print('✅ Yüz fotoğrafları mevcut, checking pending deep link...');
              
              // Pending deep link event code'u kontrol et
              final pendingEventCode = await StorageHelper.getPendingDeepLinkEventCode();
              if (pendingEventCode != null) {
                // Pending event code var, event detail sayfasına yönlendir
                print('🔗 Pending deep link found after email login: $pendingEventCode');
                await StorageHelper.clearPendingDeepLinkEventCode();
                
                if (!mounted) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(eventCode: pendingEventCode),
                  ),
                );
              } else {
                // Pending event code yok, home'a yönlendir
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              }
            }
          } catch (e) {
            print('❌ Error checking face photos: $e');
            // 403 hatası durumunda ApiHelper zaten login'e yönlendirdi
            return;
          }
        } else {
          // Login failed - show error message from server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Giriş başarısız!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  context.tr('login.signup'),
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing2XL,
            vertical: AppTheme.spacingXL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  context.tr('login.title'),
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  context.tr('login.subtitle'),
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Username Field
                Text(
                  context.tr('login.label_username'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('login.placeholder_username');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Password Field
                Text(
                  context.tr('login.label_password'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('login.placeholder_password');
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Handle forgot password
                    },
                    child: Text(
                      context.tr('login.forgot_password'),
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isFormComplete() && !_isLoading) ? _login : null,
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
                            context.tr('login.button_login'),
                            style: AppTheme.buttonLarge,
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2XL),

                // Divider with text
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.dividerColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                      ),
                      child: Text(
                        context.tr('login.or'),
                        style: AppTheme.captionLarge,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.dividerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing2XL),

                // Back to Social Login
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 20,
                    ),
                    label: const Text(
                      'Sosyal Medya ile Giriş',
                      style: AppTheme.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
