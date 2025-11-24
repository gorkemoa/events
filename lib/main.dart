import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pixlomi/theme/app_theme.dart';
import 'package:pixlomi/localizations/app_localizations.dart';
import 'package:pixlomi/views/auth/splash_page.dart';
import 'package:pixlomi/views/auth/auth_page.dart';
import 'package:pixlomi/views/auth/signup_page.dart';
import 'package:pixlomi/views/auth/login_page.dart';
import 'package:pixlomi/views/auth/email_login_page.dart';
import 'package:pixlomi/views/auth/code_verification_page.dart';
import 'package:pixlomi/views/auth/face_verification_page.dart';
import 'package:pixlomi/views/auth/onboarding_page.dart';
import 'package:pixlomi/views/main_navigation.dart';
import 'package:pixlomi/views/notifications/notifications_page.dart';
import 'package:pixlomi/views/profile/change_password_page.dart';
import 'package:pixlomi/views/profile/settings_page.dart';
import 'package:pixlomi/views/profile/face_photos_page.dart';
import 'package:pixlomi/views/profile/edit_profile_page.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';
import 'package:pixlomi/services/navigation_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';
import 'package:pixlomi/services/language_service.dart';
import 'package:pixlomi/services/deep_link_service.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/app_version_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Messaging
  await FirebaseMessagingService.initialize();
  
  // Initialize App Version Service (native version management)
  await AppVersionService().initialize();

  // Sadece dikey kullanım (portrait) açık kalsın
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Deep Link Service (but don't process initial link yet)
  DeepLinkService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
  
  // Dil değişikliği için global key
  static final GlobalKey<MyAppState> appKey = GlobalKey<MyAppState>();
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('tr', '');
  Widget? _initialPage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSavedLanguage();
    await _determineInitialPage();
  }

  Future<void> _determineInitialPage() async {
    // Check for pending deep link first
    if (DeepLinkService.hasPendingLink()) {
      final eventCode = DeepLinkService.getPendingEventCode();
      
      // Check if user is logged in
      final isLoggedIn = await StorageHelper.isLoggedIn();
      final userToken = await StorageHelper.getUserToken();
      
      if (eventCode != null) {
        if (isLoggedIn && userToken != null) {
          // User is logged in, navigate directly to event detail
          print('🚀 Cold start with deep link - navigating directly to EventDetailPage: $eventCode');
          setState(() {
            _initialPage = EventDetailPage(eventCode: eventCode);
            _isInitialized = true;
          });
          return;
        } else {
          // User not logged in, save event code and show splash (will redirect to auth)
          print('⚠️ Cold start with deep link but user not logged in - saving event code: $eventCode');
          await StorageHelper.setPendingDeepLinkEventCode(eventCode);
        }
      }
    }
    
    // Default to splash page
    setState(() {
      _initialPage = const SplashPage();
      _isInitialized = true;
    });
  }

  Future<void> _loadSavedLanguage() async {
    final savedLocale = await LanguageService.getSavedLocale();
    setState(() {
      _locale = savedLocale;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading while initializing
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Pixlomi',
      theme: AppTheme.lightTheme,
      
      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageService.supportedLocales,
      locale: _locale,
      
      home: _initialPage,
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
        '/emailLogin': (context) => const EmailLoginPage(),
        '/codeVerification': (context) => const CodeVerificationPage(),
        '/faceVerification': (context) => const FaceVerificationPage(),
        '/facePhotos': (context) => const FacePhotosPage(),
        '/home': (context) => const MainNavigation(),
        '/notifications': (context) => const NotificationsPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/settings': (context) => const SettingsPage(),
        '/editProfile': (context) => const EditProfilePage(),
      },
    );
  }
}