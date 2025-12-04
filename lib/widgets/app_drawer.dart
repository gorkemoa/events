import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class AppDrawer extends StatefulWidget {
  final String? userFullname;
  final String? userEmail;
  final String? profilePhoto;
  final Function(int)? onPageSelected;

  const AppDrawer({
    Key? key,
    this.userFullname,
    this.userEmail,
    this.profilePhoto,
    this.onPageSelected,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // User Profile Section with Pixlomi Logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 45),
                  Image.asset(
                    'assets/logo/pixlomi.png',
                    height: 60,
                    width: 200,
                    fit: BoxFit.contain,
                    color: Colors.white,
                  ),

                  // User Profile
                  Row(),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  _buildMenuItemCustom(
                    icon: Icons.headset_mic_outlined,
                    title: context.tr('drawer.menu_support'),
                    onTap: () {
                      Navigator.pop(context);
                      _showSupportDialog();
                    },
                  ),
                  _buildMenuItemCustom(
                    icon: Icons.email_outlined,
                    title: context.tr('drawer.menu_contact'),
                    onTap: () {
                      Navigator.pop(context);
                      _showContactDialog();
                    },
                  ),
                  _buildMenuItemCustom(
                    icon: Icons.info_outline,
                    title: context.tr('drawer.menu_about'),
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog();
                    },
                  ),
                ],
              ),
            ),

            // Footer - Company Info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // ilk satır solda
                children: [
                  Text(
                    context.tr(
                      'drawer.footer',
                      args: {'version': _appVersion ?? '1.0.0'},
                    ),
                    style: const TextStyle(fontSize: 9.7, color: Colors.grey),
                  ),

                 
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Logout Button
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Logout confirmation
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.tr('drawer.logout_title')),
                        content: Text(context.tr('drawer.logout_confirm')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(context.tr('common.cancel')),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(context.tr('drawer.button_logout')),
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
                        await FirebaseMessagingService.unsubscribeFromUserTopic(
                          userId.toString(),
                        );
                      }

                      if (mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    context.tr('drawer.button_logout'),
                    style: const TextStyle(
                      fontSize: 10,
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
            ),
            const SizedBox(height: 10),

            // LOGO ORTADA
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCustom({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(context.tr('drawer.about_title')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('drawer.company_name'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('drawer.company_tagline'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('drawer.app_name'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('drawer.app_description'),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.verified, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    context.tr(
                      'drawer.version',
                      args: {'version': _appVersion ?? '1.0.0'},
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('drawer.copyright'),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
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

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.headset_mic_outlined, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(context.tr('drawer.support_title')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('drawer.support_question'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.email_outlined, 'destek@office701.com'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_outlined, '+90 (850) 444 0701'),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.access_time,
                context.tr('drawer.support_hours'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('drawer.support_faq'),
                        style: TextStyle(fontSize: 11, color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
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

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email_outlined, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(context.tr('drawer.contact_title')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('drawer.company_name'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('drawer.company_tagline'),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.location_on_outlined,
                context.tr('drawer.location'),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.email_outlined, 'destek@office701.com'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_outlined, '+90 (850) 444 0701'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.language, 'www.office701.com'),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
