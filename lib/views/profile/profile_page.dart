import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  
  const ProfilePage({
    Key? key,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();
  final _imagePicker = ImagePicker();
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
  String? _base64ProfilePhoto; // Yeni profil fotoğrafı için base64 string

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
          _rolesController.text = _currentUser!.userPermissions ?? 'Standart Kullanıcı';
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
        userName: _userNameController.text,
        userFirstname: _firstNameController.text,
        userLastname: _lastNameController.text,
        userEmail: _emailController.text,
        userBirthday: _birthdayController.text.isNotEmpty ? _birthdayController.text : '01.01.1990',
        userPhone: _phoneController.text,
        userAddress: _addressController.text,
        userGender: _selectedGender,
        profilePhoto: _base64ProfilePhoto ?? '', // Base64 fotoğrafı gönder
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
            _base64ProfilePhoto = null; // Reset after save
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800, // Optimize image size
        maxHeight: 800,
        imageQuality: 85, // Compress to reduce size
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        final base64String = base64Encode(bytes);
        
        // Add data URI prefix
        final mimeType = pickedFile.path.toLowerCase().endsWith('.png') 
            ? 'image/png' 
            : 'image/jpeg';
        
        setState(() {
          _base64ProfilePhoto = 'data:$mimeType;base64,$base64String';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf seçildi. Kaydetmeyi unutmayın.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotoğraf Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: const Text('Kamera ile Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
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
                onMenuPressed: widget.onMenuPressed,
                onNotificationPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                notificationIcon: Icons.settings,
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
                                GestureDetector(
                                  onTap: _isEditMode ? _showImageSourceDialog : null,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _isEditMode ? AppTheme.primary : Colors.grey[300]!,
                                        width: _isEditMode ? 3 : 2,
                                      ),
                                      color: Colors.grey[200],
                                    ),
                                    child: ClipOval(
                                      child: _base64ProfilePhoto != null
                                          ? Image.memory(
                                              base64Decode(_base64ProfilePhoto!.split(',').last),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                );
                                              },
                                            )
                                          : (_currentUser?.profilePhoto.isNotEmpty == true
                                              ? (_currentUser!.profilePhoto.startsWith('data:image')
                                                  ? Image.memory(
                                                      base64Decode(_currentUser!.profilePhoto.split(',').last),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color: Colors.grey[400],
                                                        );
                                                      },
                                                    )
                                                  : Image.network(
                                                      _currentUser!.profilePhoto,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color: Colors.grey[400],
                                                        );
                                                      },
                                                    ))
                                              : Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey[400],
                                                )),
                                    ),
                                  ),
                                ),
                                if (_isEditMode)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _showImageSourceDialog,
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
                               enabled: _isEditMode,

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
                                          _base64ProfilePhoto = null; // Reset selected photo
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
}
