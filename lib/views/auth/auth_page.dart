import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/localizations/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Kaç piksel yukarı kaydırmak istiyorsan burayı değiştir
  static const double _bgYOffset = -160; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 ARKA PLAN FOTO (piksel bazlı yukarı kaydırma + cover)
          Positioned.fill(
            child: ClipRect(
              child: Transform.translate(
                offset: const Offset(0, _bgYOffset),
                child: Image.asset(
                  'assets/onboarding/foto13.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 🔹 ÜSTTE GRADYAN ÖRTÜ
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(1.0),
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // 🔹 İÇERİK
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 300),

                // Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        context.tr('auth.welcome'),
                        style: AppTheme.headingLarge,           
                      ),
                      const SizedBox(height: AppTheme.spacingXL),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2XL,
                        ),
                        child: Text(
                          context.tr('auth.subtitle'),
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
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: Text(
                            context.tr('auth.button_signup'),
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
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: Text(
                            context.tr('auth.button_login'),
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
        ],
      ),
    );
  }
}
