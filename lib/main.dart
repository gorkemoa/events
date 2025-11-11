import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/views/auth/splash_page.dart';
import 'package:pixlomi/views/auth/auth_page.dart';
import 'package:pixlomi/views/auth/signup_page.dart';
import 'package:pixlomi/views/auth/login_page.dart';
import 'package:pixlomi/views/auth/code_verification_page.dart';
import 'package:pixlomi/views/auth/face_verification_page.dart';
import 'package:pixlomi/views/auth/onboarding_page.dart';
import 'package:pixlomi/views/main_navigation.dart';
import 'package:pixlomi/views/notifications/notifications_page.dart';
import 'package:pixlomi/views/profile/change_password_page.dart';
import 'package:pixlomi/views/profile/settings_page.dart';
import 'package:pixlomi/views/profile/face_photos_page.dart';
import 'package:pixlomi/services/navigation_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Events App',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Herhangi bir yere tıklandığında klavyeyi kapat
            FocusScope.of(context).unfocus();
          },
          child: child,
        );
      },
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/auth': (context) => const AuthPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/codeVerification': (context) => const CodeVerificationPage(),
        '/faceVerification': (context) => const FaceVerificationPage(),
        '/facePhotos': (context) => const FacePhotosPage(),
        '/home': (context) => const MainNavigation(),
        '/notifications': (context) => const NotificationsPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}