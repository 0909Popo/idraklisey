import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../navigation/main_screen.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isFadingOut = false;
  bool _hasNavigated = false;

  late AnimationController _fallbackAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<String> _possibleVideoPaths = [
    'assets/videos/intro.mp4',
    'assets/videos/logo_intro.mp4',
    'assets/videos/splash.mp4',
    'assets/videos/logo.mp4',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fallbackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _fallbackAnimController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fallbackAnimController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    for (final path in _possibleVideoPaths) {
      try {
        final controller = VideoPlayerController.asset(path);
        await controller.initialize();
        if (!mounted) return;

        setState(() {
          _videoController = controller;
          _isVideoInitialized = true;
        });

        _videoController!.setVolume(1.0);
        await _videoController!.play();

        _videoController!.addListener(() {
          if (_videoController != null &&
              _videoController!.value.isInitialized &&
              _videoController!.value.position >= _videoController!.value.duration &&
              !_isFadingOut &&
              !_hasNavigated) {
            _onVideoComplete();
          }
        });
        return;
      } catch (_) {}
    }

    if (!_isVideoInitialized && mounted) {
      _fallbackAnimController.forward();
      Future.delayed(const Duration(milliseconds: 2600), () {
        if (mounted && !_hasNavigated) {
          _onVideoComplete();
        }
      });
    }
  }

  void _onVideoComplete() {
    if (_hasNavigated || !mounted) return;

    setState(() {
      _isFadingOut = true;
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && !_hasNavigated) {
        _hasNavigated = true;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _fallbackAnimController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fullscreen Video Player
          if (_isVideoInitialized && _videoController != null)
            GestureDetector(
              onTap: _onVideoComplete,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width > 0
                        ? _videoController!.value.size.width
                        : size.width,
                    height: _videoController!.value.size.height > 0
                        ? _videoController!.value.size.height
                        : size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
            )
          else
            // 2. Cinematic Minimal Fallback Animated Intro
            GestureDetector(
              onTap: _onVideoComplete,
              child: Container(
                color: AppColors.primaryDark,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _fallbackAnimController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryAccent.withAlpha(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryAccent.withAlpha(50),
                                      blurRadius: 36,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const IdrakLogo(size: 84, showText: false, isLightText: true),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'İDRAK LİSEYİ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent.withAlpha(25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primaryAccent.withAlpha(60)),
                                ),
                                child: const Text(
                                  'BEYNƏLXALQ TƏHSİL PORTALI',
                                  style: TextStyle(
                                    color: AppColors.primaryAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // 3. Skip Button on Top-Right
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onVideoComplete,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Keç',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.fast_forward_rounded, color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Smooth Dark Fade-Out Overlay at the end
          IgnorePointer(
            ignoring: !_isFadingOut,
            child: AnimatedOpacity(
              opacity: _isFadingOut ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeInOut,
              child: Container(
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
