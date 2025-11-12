import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  
  const ProfilePage({
    super.key,
    this.onMenuPressed,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();
  User? _currentUser;
  bool _isLoading = true;

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
            content: Text('Bir hata oluştu: \$e'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppTheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              HomeHeader(
                locationText: 'Profil',
                subtitle: 'Hesap Bilgileri',
                onMenuPressed: widget.onMenuPressed,
                onNotificationPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                notificationIcon: Icons.settings,
              ),
              
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingXL,
                            vertical: AppTheme.spacingXL,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: AppTheme.spacingL),

                              // Profile Picture
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.dividerColor,
                                    width: 2,
                                  ),
                                  color: AppTheme.surfaceColor,
                                ),
                                child: ClipOval(
                                  child: _currentUser?.profilePhoto.isNotEmpty == true
                                      ? (_currentUser!.profilePhoto.startsWith('data:image')
                                          ? Image.memory(
                                              base64Decode(_currentUser!.profilePhoto.split(',').last),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: AppTheme.textTertiary,
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
                                                  color: AppTheme.textTertiary,
                                                );
                                              },
                                            ))
                                      : Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.textTertiary,
                                        ),
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacingL),

                              // User Name
                              Text(
                                _currentUser?.userFullname.toUpperCase() ?? '',
                                style: AppTheme.headingSmall.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacingS),

                              // User Email
                              Text(
                                _currentUser?.userEmail ?? '',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacing2XL),

                              // Info Card
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacingXL),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                                  border: Border.all(
                                    color: AppTheme.dividerColor,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      'Kullanıcı Adı',
                                      _currentUser?.userName ?? '-',
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      'Telefon',
                                      _currentUser?.userPhone ?? '-',
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      'Doğum Tarihi',
                                      _currentUser?.userBirthday ?? '-',
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      'Cinsiyet',
                                      _getGenderText(_currentUser?.userGender ?? ''),
                                    ),        
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      'Katılınan Etkinlik',
                                      _currentUser?.userRank ?? '0',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacingXL),
                              Text( 
                                'Uygulama Versiyonu ${_currentUser?.userVersion ?? '-'}',
                                textAlign: TextAlign.center,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                                  const SizedBox(height: AppTheme.spacingS),
                              Image.asset(
                                'assets/logo/office701.png',
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: AppTheme.spacingXL),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingL),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _getGenderText(String gender) {
    if (gender.toLowerCase() == 'erkek' || gender == '1') {
      return 'Erkek';
    } else if (gender.toLowerCase() == 'kadın' || gender == '2') {
      return 'Kadın';
    }
    return 'Belirtilmemiş';
  }
}
