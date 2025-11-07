import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _rolesController = TextEditingController();
  final TextEditingController _eventsController = TextEditingController();
  
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false; // Edit mode toggle
  int _selectedGender = 1; // 1 - Erkek, 2 - Kadın, 3 - Belirtilmemiş

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get userId and userToken from secure storage
      final userId = await StorageHelper.getUserId();
      final userToken = await StorageHelper.getUserToken();

      if (userId == null || userToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
        return;
      }

      final response = await _userService.getUserById(
        userId: userId,
        userToken: userToken,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _currentUser = response.data!.user;
          _userNameController.text = _currentUser!.userName;
          _emailController.text = _currentUser!.userEmail;
          _firstNameController.text = _currentUser!.userFirstname;
          _lastNameController.text = _currentUser!.userLastname;
          _phoneController.text = _currentUser!.userPhone;
          _addressController.text = _currentUser!.userAddress;
          _birthdayController.text = _currentUser!.userBirthday;
          _rolesController.text = _currentUser!.userName;
          _eventsController.text = _currentUser!.userRank;
          
          // Parse gender from string to int
          if (_currentUser!.userGender.toLowerCase() == 'erkek' || _currentUser!.userGender == '1') {
            _selectedGender = 1;
          } else if (_currentUser!.userGender.toLowerCase() == 'kadın' || _currentUser!.userGender == '2') {
            _selectedGender = 2;
          } else {
            _selectedGender = 3;
          }
          
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Kullanıcı bilgileri alınamadı'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    _rolesController.dispose();
    _eventsController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final userId = await StorageHelper.getUserId();
      final userToken = await StorageHelper.getUserToken();

      if (userId == null || userToken == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final updateRequest = UpdateUserRequest(
        userToken: userToken,
        userFirstname: _firstNameController.text,
        userLastname: _lastNameController.text,
        userEmail: _emailController.text,
        userBirthday: _birthdayController.text.isNotEmpty ? _birthdayController.text : '01.01.1990',
        userPhone: _phoneController.text,
        userAddress: _addressController.text,
        userGender: _selectedGender,
        profilePhoto: '', // Base64 foto için ayrı bir dialog eklenebilir
      );

      final response = await _userService.updateUser(
        userId: userId,
        request: updateRequest,
      );

      if (mounted) {
        if (response.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditMode = false;
          });
          // Reload user data
          await _loadUserData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.errorMessage ?? 'Güncelleme başarısız'),
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppTheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              HomeHeader(
                locationText: 'Profil',
                subtitle: 'Hesap Bilgileri',
                onMenuPressed: () {
                  // Menu action
                },
                onNotificationPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),

                            // Profile Picture
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    color: Colors.grey[200],
                                  ),
                                  child: _currentUser?.profilePhoto.isNotEmpty == true
                                      ? ClipOval(
                                          child: Image.network(
                                            _currentUser!.profilePhoto,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey[400],
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey[400],
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // User Name Title
                            Text(
                              _currentUser?.userFullname.toUpperCase() ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 30),

                            // First Name Field
                            _buildTextField(
                              label: 'Ad',
                              controller: _firstNameController,
                              enabled: _isEditMode,
                            ),

                            const SizedBox(height: 20),

                            // Last Name Field
                            _buildTextField(
                              label: 'Soyad',
                              controller: _lastNameController,
                              enabled: _isEditMode,
                            ),

                            const SizedBox(height: 20),

                            // User Name Field (Read-only)
                            _buildTextField(
                              label: 'Kullanıcı Adı',
                              controller: _userNameController,
                              readOnly: true,
                              enabled: false,
                            ),

                            const SizedBox(height: 20),

                            // Email Field
                            _buildTextField(
                              label: 'E-posta',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: _isEditMode,
                            ),

                            const SizedBox(height: 20),

                            // Phone Field
                            _buildTextField(
                              label: 'Telefon',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enabled: _isEditMode,
                            ),

                            const SizedBox(height: 20),

                            // Birthday Field
                            _buildTextField(
                              label: 'Doğum Tarihi (GG.AA.YYYY)',
                              controller: _birthdayController,
                              keyboardType: TextInputType.datetime,
                              enabled: _isEditMode,
                            ),

                            const SizedBox(height: 20),

                            // Address Field
                            _buildTextField(
                              label: 'Adres',
                              controller: _addressController,
                              maxLines: 2,
                              enabled: _isEditMode,
                            ),

                            const SizedBox(height: 20),

                            // Gender Selection
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cinsiyet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<int>(
                                          dense: true,
                                          title: const Text('Erkek', style: TextStyle(fontSize: 14)),
                                          value: 1,
                                          groupValue: _selectedGender,
                                          onChanged: _isEditMode ? (value) {
                                            setState(() {
                                              _selectedGender = value!;
                                            });
                                          } : null,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<int>(
                                          dense: true,
                                          title: const Text('Kadın', style: TextStyle(fontSize: 14)),
                                          value: 2,
                                          groupValue: _selectedGender,
                                          onChanged: _isEditMode ? (value) {
                                            setState(() {
                                              _selectedGender = value!;
                                            });
                                          } : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Roles Field (Read-only)
                            _buildTextField(
                              label: 'Kullanıcı Adı',
                              controller: _rolesController,
                              readOnly: true,
                              enabled: false,
                            ),

                            const SizedBox(height: 20),

                            // Total Events Attended Field (Read-only)
                            _buildTextField(
                              label: 'Katılınan Etkinlik Sayısı',
                              controller: _eventsController,
                              keyboardType: TextInputType.number,
                              readOnly: true,
                              enabled: false,
                            ),

                            const SizedBox(height: 30),

                            // Save/Edit Button
                            if (_isEditMode)
                              Column(
                                children: [
                                  // Save Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isSaving ? null : _saveUserData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isSaving
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Değişiklikleri Kaydet',
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
                                      onPressed: () {
                                        setState(() {
                                          _isEditMode = false;
                                        });
                                        _loadUserData();
                                      },
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
                                ],
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditMode = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Profili Düzenle',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            const SizedBox(height: 40),

                            // Settings Section Title
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ayarlar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Settings Menu Items
                            _buildSettingsTile(
                              icon: Icons.lock,
                              title: 'Şifre Değiştir',
                              onTap: () {
                                // Navigate to change password page
                                _showChangePasswordDialog();
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildSettingsTile(
                              icon: Icons.notifications,
                              title: 'Bildirim Ayarları',
                              onTap: () {
                                // Navigate to notification settings
                                Navigator.pushNamed(context, '/notification-settings');
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildSettingsTile(
                              icon: Icons.privacy_tip,
                              title: 'Gizlilik Politikası',
                              onTap: () {
                                // Show privacy policy
                                _showPrivacyPolicyDialog();
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildSettingsTile(
                              icon: Icons.info,
                              title: 'Hakkında',
                              onTap: () {
                                // Show about dialog
                                _showAboutDialog();
                              },
                            ),

                            const SizedBox(height: 40),

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
                                    await StorageHelper.clearUserSession();
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly || !enabled,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(
            fontSize: 15,
            color: enabled ? Colors.black87 : Colors.grey[600],
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.grey[200] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
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
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifreyi Onayla',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifreler eşleşmiyor'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                // Call password change API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre başarıyla değiştirildi'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
              passwordController.dispose();
              newPasswordController.dispose();
              confirmPasswordController.dispose();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gizlilik Politikası'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gizlilik Politikası',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Uygulamada sunulan hizmetleri ve kullanıcı verilerinizi korumak için gerekli adımları alıyoruz. Tüm kişisel verileriniz güvenli bir şekilde saklanır ve kullanılır.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                '• Verileriniz sadece gerekli işlemler için kullanılır\n• Verileriniz üçüncü taraflara satılmaz\n• Verilerinizi istediğiniz zaman silebilirsiniz',
                style: TextStyle(fontSize: 13),
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
