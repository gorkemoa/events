import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/app_version_service.dart';
import 'package:pixlomi/views/policies/membership_agreement_page.dart';
import 'package:pixlomi/views/policies/privacy_policy_page.dart';
import 'dart:io' show Platform;
import 'package:pixlomi/localizations/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ahmet');
  final _surnameController = TextEditingController(text: 'Yılmaz');
  final _usernameController = TextEditingController(text: 'ahmetyilmaz');
  final _emailController = TextEditingController(text: 'gorkemoa35@gmail.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _authService = AuthService();
  final _versionService = AppVersionService();
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  bool _isFormComplete() {
    return _nameController.text.isNotEmpty &&
        _surnameController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _agreeToTerms;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen şartları kabul edin')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get platform info
        String platform = 'web';
        if (Platform.isIOS) {
          platform = 'ios';
        } else if (Platform.isAndroid) {
          platform = 'android';
        }

        // Call register API
        final response = await _authService.register(
          userFirstname: _nameController.text,
          userLastname: _surnameController.text,
          userName: _usernameController.text,
          userEmail: _emailController.text,
          userPassword: _passwordController.text,
          version: _versionService.fullVersion,
          platform: platform,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.isSuccess) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.successMessage ?? 'Hesap başarıyla oluşturuldu!')),
            );

            // Save codeToken, userToken and userID for later use
            if (response.data != null) {
              if (response.data!.codeToken.isNotEmpty) {
                await StorageHelper.setCodeToken(response.data!.codeToken);
                print('💾 CodeToken saved: ${response.data!.codeToken}');
              }
              
              // Save userToken and userID temporarily (will be saved again after code verification)
              await StorageHelper.saveUserSession(
                userId: response.data!.userID,
                userToken: response.data!.userToken,
              );
              print('💾 UserToken saved: ${response.data!.userToken}');
              print('💾 UserID saved: ${response.data!.userID}');
            }
            
            // Navigate to code verification page
            Navigator.of(context).pushReplacementNamed('/codeVerification');
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.errorMessage ?? 'Kayıt işlemi başarısız oldu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
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
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  context.tr('signup.login'),
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
                  context.tr('signup.title'),
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  context.tr('signup.subtitle'),
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Full Name Field
                Text(
                  context.tr('signup.label_firstname'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _nameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen ad soyadınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),
                
                Text(
                  context.tr('signup.label_lastname'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _surnameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Username Field
                Text(
                  context.tr('signup.label_username'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _usernameController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen E-Mailnızı girin';
                    }
                    if (value.length < 3) {
                      return 'E-Mail en az 3 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Email Field
                Text(
                  context.tr('signup.label_email'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-postanızı girin';
                    }
                    if (!value.contains('@')) {
                      return 'Lütfen geçerli bir e-posta girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Password Field
                Text(
                  context.tr('signup.label_password'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
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
                const SizedBox(height: AppTheme.spacing2XL),

                // Terms and Policies Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MembershipAgreementPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.tr('signup.membership_agreement'),
                                  style: AppTheme.captionLarge.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                ', ',
                                style: AppTheme.captionLarge,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PrivacyPolicyPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  context.tr('signup.privacy_policy'),
                                  style: AppTheme.captionLarge.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                context.tr('signup.terms_accept'),
                                style: AppTheme.captionLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isFormComplete() && !_isLoading) ? _signUp : null,
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
                            context.tr('signup.button_continue'),
                            style: AppTheme.buttonLarge,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
