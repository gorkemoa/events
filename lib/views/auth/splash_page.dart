import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:pixlomi/services/storage_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

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

    if (isLoggedIn) {
      // Kullanıcı giriş yapmış, ana sayfaya yönlendir
      print('✅ User logged in, navigating to /home');
      Navigator.of(context).pushReplacementNamed('/home');
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
