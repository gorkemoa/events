import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get passToken from storage
        final passToken = await StorageHelper.getPassToken();
        
        if (passToken == null) {
          throw Exception('PassToken bulunamadı');
        }

        final response = await _authService.updateForgotPassword(
          passToken: passToken,
          password: _passwordController.text,
          passwordAgain: _confirmPasswordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message ?? context.tr('reset_password.success')),
                backgroundColor: Colors.green,
              ),
            );

            // Show redirecting message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('reset_password.redirecting')),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );

            // Wait a moment then navigate to login
            await Future.delayed(const Duration(seconds: 2));
            
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.errorMessage ?? context.tr('reset_password.error')),
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
                  context.tr('reset_password.title'),
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),

                // Subtitle
                Text(
                  context.tr('reset_password.subtitle'),
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Password Field
                Text(
                  context.tr('reset_password.label_password'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: context.tr('reset_password.placeholder_password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('reset_password.placeholder_password');
                    }
                    if (value.length < 6) {
                      return context.tr('reset_password.error_password_short');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Confirm Password Field
                Text(
                  context.tr('reset_password.label_password_confirm'),
                  style: AppTheme.labelMedium,
                ),
                const SizedBox(height: AppTheme.spacingS),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: context.tr('reset_password.placeholder_password_confirm'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('reset_password.placeholder_password_confirm');
                    }
                    if (value != _passwordController.text) {
                      return context.tr('reset_password.error_password_mismatch');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing3XL),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
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
                            context.tr('reset_password.button_reset'),
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
