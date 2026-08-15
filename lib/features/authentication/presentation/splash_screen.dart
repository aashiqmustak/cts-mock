import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Animated splash screen using video playback (assets/lottie/splash.mp4).
/// Auto-navigates to login screen after the video finishes or after timeout.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static bool hasShown = false;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/lottie/splash.mp4');

    try {
      await _videoController.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.setVolume(0.0);
        _videoController.setLooping(false);
        await _videoController.play();

        _videoController.addListener(_videoListener);

        final videoDuration = _videoController.value.duration;
        final splashDuration = videoDuration > Duration.zero
            ? videoDuration
            : const Duration(seconds: 4);

        _navigationTimer = Timer(splashDuration + const Duration(milliseconds: 400), _navigateToNextScreen);
      }
    } catch (e) {
      debugPrint('Error initializing splash video: $e');
      _navigationTimer = Timer(const Duration(seconds: 3), _navigateToNextScreen);
    }
  }

  void _videoListener() {
    if (_videoController.value.isInitialized &&
        !_videoController.value.isPlaying &&
        _videoController.value.position >= _videoController.value.duration) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    SplashScreen.hasShown = true;
    context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Video Player or Fallback Hero Gradient
          Positioned.fill(
            child: _isVideoInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),

          // Gradient Tint Overlay for text legibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),

          // Main Foreground Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Navigation Actions & Version Tag
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: _navigateToNextScreen,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Skip', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_ios, size: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'v1.0.0 — Healthcare Enterprise Edition',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
