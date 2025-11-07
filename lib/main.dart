import 'package:flutter/material.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/views/auth/splash_page.dart';
import 'package:pixlomi/views/auth/auth_page.dart';
import 'package:pixlomi/views/auth/signup_page.dart';
import 'package:pixlomi/views/auth/login_page.dart';
import 'package:pixlomi/views/auth/face_verification_page.dart';
import 'package:pixlomi/views/auth/onboarding_page.dart';
import 'package:pixlomi/views/main_navigation.dart';
import 'package:pixlomi/views/notifications/notifications_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Events App',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/auth': (context) => const AuthPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/faceVerification': (context) => const FaceVerificationPage(),
        '/home': (context) => const MainNavigation(),
        '/notifications': (context) => const NotificationsPage(),
      },
    );
  }
}