import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top space
            const SizedBox(height: 80),
            
            // Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Etkinliğe Hoş Geldiniz',
                    style: AppTheme.headingLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2XL,
                    ),
                    child: Text(
                      'Bize katılarak hesap oluşturun ve\nsorunsuz etkinlik planlaması deneyimi yaşayın.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2XL,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to sign up page
                        Navigator.of(context).pushNamed('/signup');
                      },
                      child: const Text(
                        'Hesap Oluştur',
                        style: AppTheme.buttonLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to login page
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text(
                        'Giriş Yap',
                        style: AppTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider line at bottom
            Container(
              width: 60,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
