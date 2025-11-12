import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:convert';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _userService = UserService();
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  int _selectedGender = 1;
  String? _base64ProfilePhoto;

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
      final userId = await StorageHelper.getUserId();
      final userToken = await StorageHelper.getUserToken();

      if (userId == null || userToken == null) {
        if (mounted) {
          Navigator.pop(context);
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
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
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
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

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
              content: Text('Oturum bilgisi bulunamadı.'),
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
        profilePhoto: _base64ProfilePhoto ?? '',
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
          Navigator.pop(context, true);
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
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Crop the image with circular shape
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressQuality: 85,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Fotoğrafı Düzenle',
              toolbarColor: AppTheme.primary,
              toolbarWidgetColor: Colors.white,
            ),
            IOSUiSettings(
              title: 'Fotoğrafı Düzenle',
            ),
          ],
        );

        if (croppedFile != null) {
          final bytes = await File(croppedFile.path).readAsBytes();
          final base64String = base64Encode(bytes);
          
          final mimeType = croppedFile.path.toLowerCase().endsWith('.png') 
              ? 'image/png' 
              : 'image/jpeg';
          
          setState(() {
            _base64ProfilePhoto = 'data:$mimeType;base64,$base64String';
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fotoğraf seçildi'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata: $e'),
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
              title: const Text('Kamera'),
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profili Düzenle',
          style: AppTheme.headingSmall,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingL),
            child: Center(
              child: GestureDetector(
                onTap: _isSaving ? null : _saveUserData,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      )
                    : Icon(
                        Icons.check,
                        color: AppTheme.primary,
                        size: 28,
                      ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingL,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppTheme.spacingL),

                    // Profile Photo
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary,
                                width: 3,
                              ),
                              color: AppTheme.surfaceColor,
                            ),
                            child: ClipOval(
                              child: _base64ProfilePhoto != null
                                  ? Image.memory(
                                      base64Decode(_base64ProfilePhoto!.split(',').last),
                                      fit: BoxFit.cover,
                                    )
                                  : (_currentUser?.profilePhoto.isNotEmpty == true
                                      ? (_currentUser!.profilePhoto.startsWith('data:image')
                                          ? Image.memory(
                                              base64Decode(_currentUser!.profilePhoto.split(',').last),
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              _currentUser!.profilePhoto,
                                              fit: BoxFit.cover,
                                            ))
                                      : Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.textTertiary,
                                        )),
                            ),
                          ),
                        ),
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

                    const SizedBox(height: AppTheme.spacing2XL),

                    _buildTextField('Ad', _firstNameController),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTextField('Soyad', _lastNameController),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTextField('Kullanıcı Adı', _userNameController),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTextField('E-posta', _emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTextField('Telefon', _phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTextField('Doğum Tarihi (GG.AA.YYYY)', _birthdayController),
                    const SizedBox(height: AppTheme.spacingL),

                    // Gender
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cinsiyet',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
                            border: Border.all(
                              color: AppTheme.dividerColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: RadioListTile<int>(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                                  title: const Text('Erkek', style: AppTheme.bodyMedium),
                                  value: 1,
                                  groupValue: _selectedGender,
                                  onChanged: (value) => setState(() => _selectedGender = value!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                                  title: const Text('Kadın', style: AppTheme.bodyMedium),
                                  value: 2,
                                  groupValue: _selectedGender,
                                  onChanged: (value) => setState(() => _selectedGender = value!),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacing3XL),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: const BorderSide(
                color: AppTheme.dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: const BorderSide(
                color: AppTheme.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              borderSide: const BorderSide(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: maxLines > 1 ? AppTheme.spacingM : AppTheme.spacingM,
            ),
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textHint,
            ),
          ),
        ),
      ],
    );
  }
}
