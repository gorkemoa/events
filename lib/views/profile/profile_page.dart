import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/widgets/home_header.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/models/user_models.dart';
import 'dart:convert';
import 'package:pixlomi/localizations/app_localizations.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const ProfilePage({super.key, this.onMenuPressed});

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
              content: Text(
                'Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
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
              content: Text(
                response.errorMessage ?? 'Kullanıcı bilgileri alınamadı',
              ),
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
                locationText: context.tr('profile.title'),
                subtitle: context.tr('profile.subtitle'),
                onMenuPressed: widget.onMenuPressed,
                onNotificationPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                notificationIcon: Icons.settings,
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
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
                              Stack(
                                children: [
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
                                      child:
                                          _currentUser
                                                  ?.profilePhoto
                                                  .isNotEmpty ==
                                              true
                                          ? (_currentUser!.profilePhoto
                                                    .startsWith('data:image')
                                                ? Image.memory(
                                                    base64Decode(
                                                      _currentUser!.profilePhoto
                                                          .split(',')
                                                          .last,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Icon(
                                                            Icons.person,
                                                            size: 50,
                                                            color: AppTheme
                                                                .textTertiary,
                                                          );
                                                        },
                                                  )
                                                : Image.network(
                                                    _currentUser!.profilePhoto,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Icon(
                                                            Icons.person,
                                                            size: 50,
                                                            color: AppTheme
                                                                .textTertiary,
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
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (mounted) {
                                          Navigator.of(
                                            context,
                                          ).pushNamed('/editProfile');
                                        }
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.backgroundColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                                padding: const EdgeInsets.all(
                                  AppTheme.spacingXL,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.cardBorderRadius,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.dividerColor,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      context.tr('profile.label_username'),
                                      _currentUser?.userName ?? '-',
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      context.tr('profile.label_phone'),
                                      _currentUser?.userPhone ?? '-',
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      context.tr('profile.label_birthday'),
                                      _currentUser?.userBirthday ?? '-',
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      context.tr('profile.label_gender'),
                                      _getGenderText(
                                        _currentUser?.userGender ?? '',
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingL),
                                    _buildInfoRow(
                                      context.tr('profile.label_events'),
                                      _currentUser?.userRank ?? '0',
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacingL),
                              Text(
                                context.tr(
                                  'profile.app_version',
                                  args: {
                                    'version': _currentUser?.userVersion ?? '-',
                                  },
                                ),
                                textAlign: TextAlign.center,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),

                              const SizedBox(height: AppTheme.spacing3XL),

                              // Logout Button
                              SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final shouldLogout = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          context.tr('settings.logout_title'),
                                        ),
                                        content: Text(
                                          context.tr('settings.logout_confirm'),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(
                                              context.tr('common.cancel'),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(
                                              context.tr(
                                                'settings.button_logout',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldLogout == true) {
                                      final userId =
                                          await StorageHelper.getUserId();
                                      await StorageHelper.clearUserSession();

                                      if (userId != null) {
                                        await FirebaseMessagingService.unsubscribeFromUserTopic(
                                          userId.toString(),
                                        );
                                      }

                                      if (mounted) {
                                        Navigator.of(
                                          context,
                                        ).pushNamedAndRemoveUntil(
                                          '/login',
                                          (route) => false,
                                        );
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    side: BorderSide(
                                      color: Colors.red.shade300,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 16,
                                        color: Colors.red.shade400,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        context.tr('settings.button_logout'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(width: AppTheme.spacingL),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  String _getGenderText(String gender) {
    if (gender.toLowerCase() == 'erkek' || gender == '1') {
      return context.tr('profile.gender_male');
    } else if (gender.toLowerCase() == 'kadın' || gender == '2') {
      return context.tr('profile.gender_female');
    }
    return context.tr('profile.gender_unspecified');
  }
}
