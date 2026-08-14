import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.go(RouteNames.login),
                    icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 16),
                    label: const Text('Back to Sign In'),
                  ),
                ),

                const SizedBox(height: 24),

                // Logo
                Image.asset(
                  'assets/images/priorx_logo.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ).animate().scale(curve: Curves.elasticOut, duration: 500.ms),

                const SizedBox(height: 24),

                if (!_sent) ...[
                  Text('Reset your password',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      )).animate().fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 8),

                  Text(
                    'Enter the email associated with your account and we\'ll send a password reset link.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(PhosphorIconsRegular.envelope, size: 18),
                    ),
                  ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _send,
                      child: _loading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('Send Reset Link'),
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                ] else ...[
                  // Success state
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(PhosphorIconsRegular.checkCircle,
                            size: 48, color: AppColors.success),
                        const SizedBox(height: 16),
                        Text('Check your email',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.successDark,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          'We\'ve sent a password reset link to ${_emailCtrl.text}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.successDark,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Back to Sign In'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
