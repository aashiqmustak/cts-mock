import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class Error403Screen extends StatelessWidget {
  const Error403Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.errorLight, shape: BoxShape.circle), child: const Icon(PhosphorIconsRegular.lock, size: 48, color: AppColors.error)).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text('403 — Access Denied', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)).animate(delay: 150.ms).fadeIn(),
        const SizedBox(height: 8),
        Text('You do not have permission to access this resource.\nPlease contact your administrator if you believe this is an error.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)).animate(delay: 250.ms).fadeIn(),
        const SizedBox(height: 32),
        ElevatedButton.icon(onPressed: () => context.go(RouteNames.dashboard), icon: const Icon(PhosphorIconsRegular.house, size: 16), label: const Text('Go to Dashboard')).animate(delay: 350.ms).fadeIn(),
      ])),
    );
  }
}
