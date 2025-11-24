import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.forgotPassword(
          userEmail: _emailController.text.trim(),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.isSuccess && response.data != null) {
          // Save codeToken for verification
          await StorageHelper.setCodeToken(response.data!.codeToken);
          print('💾 CodeToken saved: ${response.data!.codeToken}');
          print('💾 UserID: ${response.data!.userID}');
          print('💾 Email: ${response.data!.userEmail}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? context.tr('forgot_password.success')),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to code verification page
            Navigator.of(context).pushReplacementNamed('/forgotPasswordVerify');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.errorMessage ?? context.tr('forgot_password.error')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  context.tr('forgot_password.title'),
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),

                // Subtitle
                Text(
                  context.tr('forgot_password.subtitle'),
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Email Field
                Text(
                  context.tr('forgot_password.label_email'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: context.tr('forgot_password.placeholder_email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('forgot_password.placeholder_email');
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return context.tr('forgot_password.error_email_invalid');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Send Code Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetCode,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.tr('forgot_password.button_send_code'),
                            style: AppTheme.buttonLarge,
                          ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      context.tr('forgot_password.back_to_login'),
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.primary,
                      ),
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
