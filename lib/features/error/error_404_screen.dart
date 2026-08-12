import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle), child: const Icon(PhosphorIconsRegular.mapTrifold, size: 48, color: Colors.white)).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('404 — Page Not Found', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)).animate(delay: 150.ms).fadeIn(),
        const SizedBox(height: 8),
        Text('The page you are looking for does not exist or has been moved.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)).animate(delay: 250.ms).fadeIn(),
        const SizedBox(height: 32),
        ElevatedButton.icon(onPressed: () => context.go(RouteNames.dashboard), icon: const Icon(PhosphorIconsRegular.house, size: 16), label: const Text('Go to Dashboard')).animate(delay: 350.ms).fadeIn(),
      ])),
    );
  }
}
