import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:pixlomi/services/storage_helper.dart';
import 'package:pixlomi/services/user_service.dart';
import 'package:pixlomi/services/firebase_messaging_service.dart';
import 'package:pixlomi/services/deep_link_service.dart';
import 'package:pixlomi/views/events/event_detail_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Tam ekran için sistem UI'yi gizle
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _controller = VideoPlayerController.asset('assets/splash/powered_by.mp4')
      ..setVolume(0.0) // Ses kapalı
      ..setPlaybackSpeed(1.0)
      ..initialize().then((_) {
        if (mounted) {
          // Video resolution'ı kontrol et
          final videoSize = _controller.value.size;
          print('Video Resolution: ${videoSize.width}x${videoSize.height}');
          
          setState(() {
            _isVideoInitialized = true;
          });
          _controller.play();
          
          // Video bittiğinde oturum kontrolü yap ve yönlendir
          _controller.addListener(() {
            if (_controller.value.position == _controller.value.duration) {
              if (mounted) {
                _checkSessionAndNavigate();
              }
            }
          });
        }
      }).catchError((error) {
        print('Video initialization error: $error');
      });
  }

  Future<void> _checkSessionAndNavigate() async {
    // Sistem UI'yi tekrar göster
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    // Check if there's a pending deep link
    if (DeepLinkService.hasPendingLink()) {
      final eventCode = DeepLinkService.getPendingEventCode();
      if (eventCode != null && mounted) {
        print('🔗 Processing pending deep link: $eventCode');
        
        // Check if user is logged in first
        final isLoggedIn = await StorageHelper.isLoggedIn();
        final userToken = await StorageHelper.getUserToken();
        
        if (isLoggedIn && userToken != null) {
          // User is logged in, navigate to event detail
          print('✅ User logged in, navigating to EventDetailPage with code: $eventCode');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EventDetailPage(eventCode: eventCode),
            ),
          );
          return;
        } else {
          // User not logged in, save event code to storage for after login
          print('⚠️ User not logged in, saving event code and will redirect to auth first');
          await StorageHelper.setPendingDeepLinkEventCode(eventCode);
        }
      }
    }

    // Oturum kontrolü yap
    final isLoggedIn = await StorageHelper.isLoggedIn();
    final userId = await StorageHelper.getUserId();
    final userToken = await StorageHelper.getUserToken();
    final hasSeenOnboarding = await StorageHelper.hasSeenOnboarding();
    
    print('🔍 Session Check:');
    print('  - isLoggedIn: $isLoggedIn');
    print('  - userId: $userId');
    print('  - userToken: ${userToken?.substring(0, 10)}...');
    print('  - hasSeenOnboarding: $hasSeenOnboarding');
    
    if (!mounted) return;

    if (isLoggedIn && userToken != null) {
      // Kullanıcı giriş yapmış - yüz fotoğraflarını kontrol et
      print('✅ User logged in, checking face photos...');
      
      // Subscribe to Firebase topic with userId
      if (userId != null) {
        await FirebaseMessagingService.subscribeToUserTopic(userId.toString());
      }
      
      try {
        final photosResponse = await _userService.getUserById(
          userId: userId!,
          userToken: userToken,
        );
        
        if (!mounted) return;
        
        // 403 hatası sonrası session temizlenmiş olabilir, kontrol et
        final stillLoggedIn = await StorageHelper.isLoggedIn();
        if (!stillLoggedIn) {
          // Session temizlenmiş (403), ApiHelper zaten login'e yönlendirdi
          print('🔒 Session cleared by 403, navigation already handled by ApiHelper');
          return;
        }
        
        // Yüz fotoğrafları kontrol et
        final hasFacePhotos = photosResponse.success && 
                              photosResponse.data != null && 
                              photosResponse.data!.user.frontImage.isNotEmpty &&
                              photosResponse.data!.user.leftImage.isNotEmpty &&
                              photosResponse.data!.user.rightImage.isNotEmpty;
        
        if (!hasFacePhotos) {
          // Yüz fotoğrafları yok - face verification'a yönlendir
          print('⚠️ Face photos not found, navigating to /faceVerification');
          Navigator.of(context).pushReplacementNamed('/faceVerification');
        } else {
          // Yüz fotoğrafları var - home'a yönlendir
          print('✅ Face photos found, navigating to /home');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        print('❌ Error checking face photos: $e');
        
        if (!mounted) return;
        
        // 403 hatası durumunda session temizlenmiş olabilir, tekrar kontrol et
        final stillLoggedIn = await StorageHelper.isLoggedIn();
        
        if (!stillLoggedIn) {
          // Session temizlenmiş (403 hatası), ApiHelper zaten login'e yönlendirdi
          print('🔒 Session was cleared (403), navigation already handled by ApiHelper');
          return;
        }
        
        // Başka bir hata - yine de login'e yönlendir
        print('⚠️ Unknown error, redirecting to auth');
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    } else if (!hasSeenOnboarding) {
      // Kullanıcı onboarding görmemişse, onboarding'e yönlendir
      print('❌ User not logged in and hasn\'t seen onboarding, navigating to /onboarding');
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else {
      // Kullanıcı onboarding görmüş ama giriş yapmamış, auth sayfasına yönlendir
      print('❌ User not logged in but has seen onboarding, navigating to /auth');
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Sistem UI'yi tekrar göster
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isVideoInitialized
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
