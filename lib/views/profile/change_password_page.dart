import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';

class ChangePasswordPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const ChangePasswordPage({
    Key? key,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _userService = UserService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  // Password validation helpers
  bool _hasMinLength(String password) => password.length >= 8;
  bool _hasNumber(String password) => password.contains(RegExp(r'[0-9]'));
  bool _hasLetter(String password) => password.contains(RegExp(r'[a-zA-Z]'));
  bool _passwordsMatch() => _newPasswordController.text == _confirmPasswordController.text;

  bool _isNewPasswordValid() {
    final password = _newPasswordController.text;
    return _hasMinLength(password) && _hasNumber(password) && _hasLetter(password);
  }

  bool _isFormValid() {
    return _currentPasswordController.text.isNotEmpty &&
        _isNewPasswordValid() &&
        _passwordsMatch();
  }

  Future<void> _changePassword() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doğru şekilde doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final updatePasswordRequest = UpdatePasswordRequest(
        userToken: userToken,
        currentPassword: _currentPasswordController.text,
        password: _newPasswordController.text,
        passwordAgain: _confirmPasswordController.text,
      );

      final response = await _userService.updatePassword(
        request: updatePasswordRequest,
      );

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          // Clear all fields
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          
          // Go back after 2 seconds
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Şifre güncelleme başarısız'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  // Title
                  Column(
                    children: [
                      Text(
                        'Hesap Güvenliği',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Şifre Değiştir',
                        style: AppTheme.labelMedium,
                      ),
                    ],
                  ),
                  // Empty space for alignment
                  SizedBox(width: 40),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                    

                      // Current Password Field
                      Text(
                        'Mevcut Şifre',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: !_showCurrentPassword,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showCurrentPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _showCurrentPassword = !_showCurrentPassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // New Password Field
                      Text(
                        'Yeni Şifre',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: !_showNewPassword,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _showNewPassword = !_showNewPassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Password Requirements
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Şifre Gereksinimleri:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildRequirementItem(
                              'En az 8 karakter',
                              _hasMinLength(_newPasswordController.text),
                            ),
                            _buildRequirementItem(
                              'En az 1 sayı (0-9)',
                              _hasNumber(_newPasswordController.text),
                            ),
                            _buildRequirementItem(
                              'En az 1 harf (a-z, A-Z)',
                              _hasLetter(_newPasswordController.text),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Confirm Password Field
                      Text(
                        'Şifreyi Onayla',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: _confirmPasswordController.text.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    _passwordsMatch()
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: _passwordsMatch()
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword =
                                          !_showConfirmPassword;
                                    });
                                  },
                                ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),

                      if (_confirmPasswordController.text.isNotEmpty &&
                          !_passwordsMatch())
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Şifreler eşleşmiyor',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Change Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isFormValid() && !_isLoading
                              ? _changePassword
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Şifreyi Değiştir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'İptal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey[600],
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
