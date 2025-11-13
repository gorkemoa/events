import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/face_photo_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'ridvan');
  final _passwordController = TextEditingController(text: '123');
  final _authService = AuthService();
  final _facePhotoService = FacePhotoService();
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
          final photosResponse = await _facePhotoService.getFacePhotos(
            userToken: response.data!.token,
          );
          
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data?.message ?? 'Giriş başarılı!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Yüz fotoğrafları yoksa face_verification'a yönlendir
          if (!photosResponse.isSuccess || photosResponse.data == null) {
            print('⚠️ Yüz fotoğrafları yok, face_verification\'a yönlendiriliyor');
            Navigator.of(context).pushReplacementNamed('/faceVerification');
          } else {
            print('✅ Yüz fotoğrafları mevcut, home\'a yönlendiriliyor');
            // Navigate to home page and remove all previous routes
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
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
      appBar: AppBar(
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Kayıt Ol',
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
                  'Etkinliğe Giriş Yap',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Kullanıcı adı ve şifrenizi girin.',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Username Field
                Text(
                  'Kullanıcı Adı',
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
                      return 'Lütfen kullanıcı adınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Password Field
                Text(
                  'Şifre',
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
                      return 'Lütfen şifrenizi girin';
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
                      'Şifremi Unuttum',
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
                            'Giriş Yap',
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
                        'veya',
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

                // Social Login Buttons
                // Facebook
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle Facebook login
                    },
                    icon: const Icon(
                      Icons.facebook,
                      color: Color(0xFF1877F2),
                      size: 24,
                    ),
                    label: const Text(
                      'Facebook ile Giriş Yap',
                      style: AppTheme.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Google
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle Google login
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset('assets/icon/google_icon.png'),
                        ),
                        const SizedBox(width: AppTheme.spacingM),
                        const Text(
                          'Google ile Giriş Yap',
                          style: AppTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Apple
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle Apple login
                    },
                    icon: const Icon(
                      Icons.apple,
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                    label: const Text(
                      'Apple ile Giriş Yap',
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
