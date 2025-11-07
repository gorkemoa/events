import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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
          
          // Video bittiğinde onboarding'e yönlendir
          _controller.addListener(() {
            if (_controller.value.position == _controller.value.duration) {
              if (mounted) {
                // Sistem UI'yi tekrar göster
                SystemChrome.setEnabledSystemUIMode(
                  SystemUiMode.manual,
                  overlays: SystemUiOverlay.values,
                );
                Navigator.of(context).pushReplacementNamed('/onboarding');
              }
            }
          });
        }
      }).catchError((error) {
        print('Video initialization error: $error');
      });
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
