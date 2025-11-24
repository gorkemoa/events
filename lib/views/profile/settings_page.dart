import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';
import 'package:pixlomi/services/language_service.dart';
import 'package:pixlomi/views/profile/edit_profile_page.dart';
import 'package:pixlomi/views/policies/membership_agreement_page.dart';
import 'package:pixlomi/views/policies/privacy_policy_page.dart';
import 'package:pixlomi/localizations/app_localizations.dart';
import 'package:pixlomi/main.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const SettingsPage({
    Key? key,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserService _userService = UserService();
  bool _hasFacePhotos = false;
  bool _isCheckingPhotos = true;
  String _currentLanguage = 'tr';

  @override
  void initState() {
    super.initState();
    _checkFacePhotos();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LanguageService.getSavedLanguage();
    setState(() {
      _currentLanguage = language;
    });
  }

  Future<void> _checkFacePhotos() async {
    try {
      final userToken = await StorageHelper.getUserToken();
      final userId = await StorageHelper.getUserId();
      
      if (userToken == null || userId == null) {
        setState(() {
          _isCheckingPhotos = false;
          _hasFacePhotos = false;
        });
        return;
      }

      final response = await _userService.getUserById(
        userId: userId,
        userToken: userToken,
      );
      
      setState(() {
        // Yüz fotoğrafları varsa ve boş değilse true
        _hasFacePhotos = response.success && 
                        response.data != null && 
                        response.data!.user.frontImage.isNotEmpty &&
                        response.data!.user.leftImage.isNotEmpty &&
                        response.data!.user.rightImage.isNotEmpty;
        _isCheckingPhotos = false;
      });
    } catch (e) {
      setState(() {
        _hasFacePhotos = false;
        _isCheckingPhotos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('settings.title'),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Settings Section Title
                Text(
                  context.tr('settings.section_account'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                // Settings Menu Items
                _buildSettingsTile(
                  icon: Icons.edit,
                  title: context.tr('settings.menu_edit_profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.lock,
                  title: context.tr('settings.menu_change_password'),
                  onTap: () {
                    // Navigate to change password page
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: context.tr('settings.menu_notifications'),
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.language,
                  title: context.tr('settings.menu_language'),
                  trailing: Text(
                    LanguageService.languageNames[_currentLanguage] ?? 'Türkçe',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    _showLanguageDialog();
                  },
                ),

                const SizedBox(height: 30),

                // Security Section Title
                Text(
                  context.tr('settings.section_security'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                // Eğer fotoğraflar yoksa "Yüz Doğrulama" göster
                if (!_isCheckingPhotos && !_hasFacePhotos) ...[
                  _buildSettingsTile(
                    icon: Icons.face,
                    title: context.tr('settings.menu_face_verification'),
                    onTap: () {
                      Navigator.pushNamed(context, '/faceVerification');
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Eğer fotoğraflar varsa "Doğrulama Fotoğraflarım" göster
                if (!_isCheckingPhotos && _hasFacePhotos) ...[
                  _buildSettingsTile(
                    icon: Icons.photo_library,
                    title: context.tr('settings.menu_face_photos'),
                    onTap: () {
                      Navigator.pushNamed(context, '/facePhotos');
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Loading durumu
                if (_isCheckingPhotos) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 30),

                // Information Section Title
                Text(
                  context.tr('settings.section_information'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                _buildSettingsTile(
                  icon: Icons.info,
                  title: context.tr('settings.menu_about'),
                  onTap: () {
                    // Show about dialog
                    _showAboutDialog();
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.description,
                  title: context.tr('settings.menu_membership_agreement'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembershipAgreementPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: context.tr('settings.menu_privacy_policy'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 15),

                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  title: context.tr('settings.menu_delete_account'),
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () async {
                    // 1. Onay
                    final firstConfirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.tr('settings.delete_title')),
                        content: Text(
                          context.tr('settings.delete_confirm'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(context.tr('common.cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              context.tr('common.delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (firstConfirm == true && mounted) {
                      // 2. Son Onay
                      final secondConfirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.tr('settings.delete_final_title')),
                          content: Text(
                            context.tr('settings.delete_final_confirm'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.tr('common.cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                context.tr('settings.delete_final_button'),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (secondConfirm == true) {
                        try {
                          // Get userId before clearing session
                          final userId = await StorageHelper.getUserId();
                          
                          // Clear user session
                          await StorageHelper.clearUserSession();
                          
                          // Unsubscribe from Firebase topic
                          if (userId != null) {
                            await FirebaseMessagingService.unsubscribeFromUserTopic(userId.toString());
                          }
                          
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
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
                        }
                      }
                    }
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
  }) {
    final effectiveIconColor = iconColor ?? AppTheme.primary;
    final effectiveTitleColor = titleColor ?? Colors.black87;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: effectiveTitleColor,
                  ),
                ),
              ],
            ),
            trailing ?? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.about_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('settings.about_app_name'),
                
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
             
              const SizedBox(height: 8),
              Text(
                context.tr('settings.about_description'),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('settings.about_copyright'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.close')),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.language_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.supportedLocales.map((locale) {
            final languageCode = locale.languageCode;
            final languageName = LanguageService.languageNames[languageCode] ?? languageCode;
            final isSelected = _currentLanguage == languageCode;
            
            return RadioListTile<String>(
              title: Text(languageName),
              value: languageCode,
              groupValue: _currentLanguage,
              activeColor: AppTheme.primary,
              selected: isSelected,
              onChanged: (value) async {
                if (value != null) {
                  await LanguageService.saveLanguage(value);
                  setState(() {
                    _currentLanguage = value;
                  });
                  
                  // Dili değiştir
                  final appState = context.findRootAncestorStateOfType<State<MyApp>>();
                  if (appState is MyAppState) {
                    appState.setLocale(Locale(value, ''));
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
