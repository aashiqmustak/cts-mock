import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/user_role.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;
  String? _errorMsg;
  int _selectedDemoRole = 0; // 0=admin, 1=doctor, 2=reviewer, 3=staff, 4=patient

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    final success = await ref.read(authProvider.notifier).signIn(
      _emailCtrl.text, _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(RouteNames.dashboard);
    } else {
      setState(() => _errorMsg = ref.read(authProvider).errorMessage);
    }
  }

  void _fillDemo(int index) {
    final creds = AppConstants.demoCredentials[index];
    _emailCtrl.text = creds['email']!;
    _passCtrl.text  = creds['password']!;
    setState(() { _selectedDemoRole = index; _errorMsg = null; });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      body: Row(
        children: [
          // Left hero panel (hidden on mobile)
          if (!isMobile)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                child: _HeroPanel(),
              ),
            ),

          // Right login form
          SizedBox(
            width: isMobile ? size.width : 480,
            child: _LoginForm(
              formKey: _formKey,
              emailCtrl: _emailCtrl,
              passCtrl: _passCtrl,
              obscurePass: _obscurePass,
              isLoading: _isLoading,
              errorMsg: _errorMsg,
              selectedDemo: _selectedDemoRole,
              onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
              onSignIn: _signIn,
              onFillDemo: _fillDemo,
              onForgotPass: () => context.go(RouteNames.forgotPassword),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Panel ───────────────────────────────────────────────────────────────
class _HeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background pattern
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter()),
        ),

        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medical_services_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text('MediAuth AI',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ).animate().slideX(begin: -0.3).fadeIn(duration: 500.ms),

              const SizedBox(height: 64),

              Text(
                'Automating Prior Auth\nfor the Modern Hospital',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ).animate(delay: 150.ms).slideX(begin: -0.3).fadeIn(duration: 500.ms),

              const SizedBox(height: 16),

              Text(
                '94% of physicians face prior auth delays.\nWe process 90% of requests in under 5 seconds.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.6,
                ),
              ).animate(delay: 300.ms).slideX(begin: -0.3).fadeIn(duration: 500.ms),

              const SizedBox(height: 48),

              // Stat chips
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: '95%+', sub: 'AI Accuracy'),
                  _StatChip(label: '<5s', sub: 'Decision Time'),
                  _StatChip(label: '80%', sub: 'Appeal Accuracy'),
                  _StatChip(label: '\$31B', sub: 'Market Problem'),
                ].asMap().entries.map((e) =>
                    e.value.animate(delay: Duration(milliseconds: 400 + e.key * 100))
                        .slideY(begin: 0.3).fadeIn(duration: 400.ms)
                ).toList(),
              ),

              const Spacer(),

              // Compliance badges
              Wrap(
                spacing: 8,
                children: [
                  _ComplianceBadge('HIPAA Compliant'),
                  _ComplianceBadge('HL7 FHIR R4'),
                  _ComplianceBadge('SOC 2 Type II'),
                  _ComplianceBadge('CMS Aligned'),
                ].map((b) => b.animate(delay: 800.ms).fadeIn()).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String sub;
  const _StatChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              )),
          Text(sub,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              )),
        ],
      ),
    );
  }
}

class _ComplianceBadge extends StatelessWidget {
  final String label;
  const _ComplianceBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          )),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Login Form ───────────────────────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscurePass;
  final bool isLoading;
  final String? errorMsg;
  final int selectedDemo;
  final VoidCallback onTogglePass;
  final VoidCallback onSignIn;
  final Function(int) onFillDemo;
  final VoidCallback onForgotPass;

  const _LoginForm({
    required this.formKey, required this.emailCtrl, required this.passCtrl,
    required this.obscurePass, required this.isLoading, required this.errorMsg,
    required this.selectedDemo, required this.onTogglePass, required this.onSignIn,
    required this.onFillDemo, required this.onForgotPass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text('Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 6),

                Text('Sign in to your MediAuth AI account',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 32),

                // Demo account quick-select
                _DemoSelector(selectedIndex: selectedDemo, onSelect: onFillDemo),

                const SizedBox(height: 28),

                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Email
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(PhosphorIconsRegular.envelope, size: 18),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: passCtrl,
                        obscureText: obscurePass,
                        onFieldSubmitted: (_) => onSignIn(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(PhosphorIconsRegular.lock, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                            onPressed: onTogglePass,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          return null;
                        },
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 12),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onForgotPass,
                          child: const Text('Forgot password?'),
                        ),
                      ),

                      // Error message
                      if (errorMsg != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(PhosphorIconsRegular.warning,
                                  size: 16, color: AppColors.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(errorMsg!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.errorDark,
                                    )),
                              ),
                            ],
                          ),
                        ).animate().fadeIn().slideY(begin: -0.1),
                      ],

                      const SizedBox(height: 24),

                      // Sign in button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : onSignIn,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Sign In', style: TextStyle(fontSize: 16)),
                        ),
                      ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Footer
                Text('HIPAA Compliant · SOC 2 Type II · HL7 FHIR R4',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    )).animate(delay: 500.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Demo Role Selector ───────────────────────────────────────────────────────
class _DemoSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const _DemoSelector({required this.selectedIndex, required this.onSelect});

  static const _roles = [
    ('Admin', UserRole.administrator, PhosphorIconsRegular.crown),
    ('Doctor', UserRole.doctor, PhosphorIconsRegular.stethoscope),
    ('Reviewer', UserRole.insuranceReviewer, PhosphorIconsRegular.shieldCheck),
    ('Staff', UserRole.hospitalStaff, PhosphorIconsRegular.hospital),
    ('Patient', UserRole.patient, PhosphorIconsRegular.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.lightning,
                  size: 14, color: AppColors.warning),
              const SizedBox(width: 6),
              Text('Quick Demo — Select a role',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roles.asMap().entries.map((e) {
              final i = e.key;
              final (label, role, icon) = e.value;
              final isSelected = i == selectedIndex;
              return GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? role.color.withOpacity(0.1) : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: isSelected ? role.color : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14,
                          color: isSelected ? role.color : AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(label,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected ? role.color : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2);
  }
}
