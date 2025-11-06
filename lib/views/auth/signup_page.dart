import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Ahmet');
  final _surnameController = TextEditingController(text: 'Yılmaz');
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  bool _isFormComplete() {
    return _nameController.text.isNotEmpty &&
        _surnameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _agreeToTerms;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen şartları kabul edin')),
        );
        return;
      }
      // Perform sign up logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesap başarıyla oluşturuldu!')),
      );
      // Navigate to face verification page
      Navigator.of(context).pushReplacementNamed('/faceVerification');
    }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Etkinliğe Kaydol',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'E-postanızı girin, size bir doğrulama kodu göndereceğiz',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Full Name Field
                Text(
                  'Ad',
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
                  'Soyad',
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

                // Email Field
                Text(
                  'E-posta',
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
                  'Şifre',
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

                // Terms Checkbox
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
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Kaydolarak ',
                              style: AppTheme.captionLarge,
                            ),
                            TextSpan(
                              text: 'Kullanım Koşulları',
                              style: AppTheme.captionLarge.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' ve ',
                              style: AppTheme.captionLarge,
                            ),
                            TextSpan(
                              text: 'Gizlilik Politikası',
                              style: AppTheme.captionLarge.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' kabul ediyorsunuz',
                              style: AppTheme.captionLarge,
                            ),
                          ],
                        ),
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
                    onPressed: _isFormComplete() ? _signUp : null,
                    child: Text(
                      'Devam Et',
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
