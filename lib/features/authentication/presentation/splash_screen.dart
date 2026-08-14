import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Animated splash screen shown on app launch.
/// Auto-navigates to login after 2.5 seconds.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go(RouteNames.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              Text(
                'PriorX',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ).animate(delay: 300.ms).slideY(begin: 0.3).fadeIn(duration: 500.ms),

              const SizedBox(height: 8),

              Text(
                'AI-Powered Prior Authorization Platform',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ).animate(delay: 450.ms).slideY(begin: 0.3).fadeIn(duration: 500.ms),

              const SizedBox(height: 64),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 600 + i * 150))
                      .scale(begin: const Offset(0.3, 0.3), duration: 400.ms, curve: Curves.easeOut)
                      .then()
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.4, 0.4),
                          duration: 600.ms, delay: 200.ms)
                      .animate(onPlay: (c) => c.repeat(reverse: true));
                }),
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 48),

              // Version tag
              Text(
                'v1.0.0 — Healthcare Enterprise Edition',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
