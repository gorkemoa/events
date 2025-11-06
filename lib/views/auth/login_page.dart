import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  bool _isFormComplete() {
    return _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Perform login logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş başarılı!')),
      );
      // Navigate to home page
      Navigator.of(context).pushReplacementNamed('/home');
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
                  'Etkinliğe Giriş Yap',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  'Kayıt olduğunuz e-postayı girin.',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

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
                    onPressed: _isFormComplete() ? _login : null,
                    child: Text(
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
                        'veya Şununla Devam Et',
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
