import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/auth_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class ForgotPasswordVerifyPage extends StatefulWidget {
  const ForgotPasswordVerifyPage({super.key});

  @override
  State<ForgotPasswordVerifyPage> createState() => _ForgotPasswordVerifyPageState();
}

class _ForgotPasswordVerifyPageState extends State<ForgotPasswordVerifyPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verifyCode() async {
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('forgot_password_verify.error_invalid_code')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get codeToken from storage
      final codeToken = await StorageHelper.getCodeToken();
      
      if (codeToken == null) {
        throw Exception('CodeToken bulunamadı');
      }

      final response = await _authService.verifyForgotPasswordCode(
        code: _code,
        codeToken: codeToken,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.isSuccess && response.data != null) {
        // Save passToken for password update
        await StorageHelper.setPassToken(response.data!.passToken);
        print('💾 PassToken saved: ${response.data!.passToken}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.successMessage ?? context.tr('forgot_password_verify.success')),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to reset password page
          Navigator.of(context).pushReplacementNamed('/resetPassword');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? context.tr('forgot_password_verify.error_verification_failed')),
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

  Future<void> _resendCode() async {
    // For forgot password, we need to go back to enter email again
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/forgotPassword');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen e-posta adresinizi tekrar girin'),
          backgroundColor: Colors.blue,
        ),
      );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                context.tr('forgot_password_verify.title'),
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: AppTheme.spacingS),

              // Subtitle
              Text(
                context.tr('forgot_password_verify.subtitle'),
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacing3XL),

              // Code Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        // Auto verify when all 6 digits entered
                        if (index == 5 && value.isNotEmpty && _code.length == 6) {
                          _verifyCode();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppTheme.spacing3XL),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
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
                          context.tr('forgot_password_verify.button_verify'),
                          style: AppTheme.buttonLarge,
                        ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Resend Code
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('forgot_password_verify.code_not_received'),
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _resendCode,
                      child: Text(
                        context.tr('forgot_password_verify.resend_code'),
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.primary,
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
