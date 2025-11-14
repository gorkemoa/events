import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/face_photo_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';
import 'package:pixlomi/views/profile/edit_profile_page.dart';
import 'package:pixlomi/views/policies/membership_agreement_page.dart';
import 'package:pixlomi/views/policies/privacy_policy_page.dart';

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
  final FacePhotoService _facePhotoService = FacePhotoService();
  bool _hasFacePhotos = false;
  bool _isCheckingPhotos = true;

  @override
  void initState() {
    super.initState();
    _checkFacePhotos();
  }

  Future<void> _checkFacePhotos() async {
    try {
      final userToken = await StorageHelper.getUserToken();
      if (userToken == null) {
        setState(() {
          _isCheckingPhotos = false;
          _hasFacePhotos = false;
        });
        return;
      }

      final response = await _facePhotoService.getFacePhotos(userToken: userToken);
      
      setState(() {
        _hasFacePhotos = response.isSuccess && response.data != null;
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
        title: const Text(
          'Ayarlar',
          style: TextStyle(
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
                  'Hesap Ayarları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                // Settings Menu Items
                _buildSettingsTile(
                  icon: Icons.edit,
                  title: 'Profili Düzenle',
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
                  title: 'Şifre Değiştir',
                  onTap: () {
                    // Navigate to change password page
                    Navigator.pushNamed(context, '/change-password');
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Bildirim Ayarları',
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),

                const SizedBox(height: 30),

                // Security Section Title
                Text(
                  'Güvenlik',
                  style: TextStyle(
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
                    title: 'Yüz Doğrulama',
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
                    title: 'Doğrulama Fotoğraflarım',
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
                  'Bilgi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 15),

                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'Hakkında',
                  onTap: () {
                    // Show about dialog
                    _showAboutDialog();
                  },
                ),

                const SizedBox(height: 12),

                _buildSettingsTile(
                  icon: Icons.description,
                  title: 'Üyelik Sözleşmesi',
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
                  title: 'Gizlilik Politikası',
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
                  title: 'Hesabı Sil',
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () async {
                    // 1. Onay
                    final firstConfirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hesap Sil'),
                        content: const Text(
                          'Bu işlem geri alınamaz. Hesabınız ve tüm verileriniz silinecektir. '
                          'Devam etmek istediğinizden emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('İptal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Sil',
                              style: TextStyle(color: Colors.red),
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
                          title: const Text('Son Onay'),
                          content: const Text(
                            'Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Evet, Sil',
                                style: TextStyle(color: Colors.red),
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

                const SizedBox(height: 30),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Çıkış Yap'),
                          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Çıkış Yap'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
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
                      }
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
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
            const Icon(
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
        title: const Text('Hakkında'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Etkinlikler Uygulaması',
                
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Versiyon: 1.0.0',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'En yakın etkinlikleri keşfedin, etkinliklere katılın ve diğer katılımcılarla bağlantı kurun.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Text(
                '© 2025 Etkinlikler. Tüm hakları saklıdır.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
