import 'package:flutter/material.dart';
import 'package:events/theme/app_theme.dart';
import 'package:events/views/auth/splash_page.dart';
import 'package:events/views/auth/auth_page.dart';
import 'package:events/views/auth/signup_page.dart';
import 'package:events/views/auth/login_page.dart';
import 'package:events/views/auth/face_verification_page.dart';
import 'package:events/views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events App',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      routes: {
        '/auth': (context) => const AuthPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/faceVerification': (context) => const FaceVerificationPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}