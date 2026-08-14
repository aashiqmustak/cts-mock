import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_role.dart';

/// Redesigned PriorX Healthcare Insurance Login Screen.
/// Preserves 100% of underlying controllers, callbacks, Riverpod auth, and navigation.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  String? _errorMsg;
  int _selectedDemoRole = 0; // 0=admin, 1=doctor, 2=reviewer, 3=staff, 4=patient, 5=hospAdmin
  late AnimationController _bgAnimationCtrl;

  @override
  void initState() {
    super.initState();
    _bgAnimationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // Default pre-fill to first demo credential for fast testing
    _fillDemo(0);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgAnimationCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final success = await ref.read(authProvider.notifier).signIn(
          _emailCtrl.text,
          _passCtrl.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(RouteNames.dashboard);
    } else {
      setState(() => _errorMsg = ref.read(authProvider).errorMessage ?? 'Invalid email or password');
    }
  }

  void _fillDemo(int index) {
    if (index >= 0 && index < AppConstants.demoCredentials.length) {
      final creds = AppConstants.demoCredentials[index];
      _emailCtrl.text = creds['email']!;
      _passCtrl.text = creds['password']!;
      setState(() {
        _selectedDemoRole = index;
        _errorMsg = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Ambient Healthcare Soft Gradient Blobs
          Positioned.fill(
            child: _HealthcareAmbientBackground(animation: _bgAnimationCtrl),
          ),

          // Main Layout Wrapper
          SafeArea(
            child: Column(
              children: [
                // Top Mobile Bar (shown only on mobile screens)
                if (isMobile)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _PriorXLogoHeader(),
                        _TopControlsHeader(),
                      ],
                    ),
                  ),

                // Main Split Content View
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 40,
                        vertical: isMobile ? 16 : 24,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Side: Promotional Healthcare Section (Desktop Only)
                          if (!isMobile)
                            const Expanded(
                              flex: 12,
                              child: _LeftHealthcarePromotionalSection(),
                            ),

                          if (!isMobile) const SizedBox(width: 48),

                          // Right Side: Login Card
                          SizedBox(
                            width: isMobile ? size.width : 480,
                            child: _LoginCard(
                              formKey: _formKey,
                              emailCtrl: _emailCtrl,
                              passCtrl: _passCtrl,
                              obscurePass: _obscurePass,
                              isLoading: _isLoading,
                              rememberMe: _rememberMe,
                              errorMsg: _errorMsg,
                              selectedDemo: _selectedDemoRole,
                              onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
                              onToggleRemember: (val) => setState(() => _rememberMe = val ?? false),
                              onSignIn: _signIn,
                              onFillDemo: _fillDemo,
                              onForgotPass: () => context.go(RouteNames.forgotPassword),
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: Text(
                    'PRIORX HEALTH INSURANCE PLATFORM · Protecting lives. Building trust.',
                    style: TextStyle(
                      color: const Color(0xFF64748B).withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient Soft Healthcare Background ───────────────────────────────────────
class _HealthcareAmbientBackground extends StatelessWidget {
  final Animation<double> animation;
  const _HealthcareAmbientBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        final angle = progress * math.pi;

        return Stack(
          children: [
            // Top Left Soft Lavender Blob
            Positioned(
              top: -80 + (20 * math.sin(angle)),
              left: -80 + (20 * math.cos(angle)),
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE0E7FF).withOpacity(0.6),
                      const Color(0xFFE0E7FF).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom Right Soft Cyan/Blue Blob
            Positioned(
              bottom: -100 + (30 * math.cos(angle)),
              right: -100 + (30 * math.sin(angle)),
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFDDD6FE).withOpacity(0.5),
                      const Color(0xFFDDD6FE).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── PriorX Logo Header ───────────────────────────────────────────────────────
class _PriorXLogoHeader extends StatelessWidget {
  const _PriorXLogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            PhosphorIconsRegular.heartbeat,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'PRIORX',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'HEALTH INSURANCE',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Top Controls Header (Theme & Language Selector) ─────────────────────────
class _TopControlsHeader extends StatelessWidget {
  const _TopControlsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme toggle button placeholder
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Icon(
            PhosphorIconsRegular.sun,
            size: 18,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 8),
        // Language selector placeholder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: const [
              Icon(PhosphorIconsRegular.globe, size: 16, color: Color(0xFF334155)),
              SizedBox(width: 6),
              Text(
                'English',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(PhosphorIconsRegular.caretDown, size: 12, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Left Side: Healthcare Promotional Section ────────────────────────────────
class _LeftHealthcarePromotionalSection extends StatelessWidget {
  const _LeftHealthcarePromotionalSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top Brand Header
        const _PriorXLogoHeader().animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

        const SizedBox(height: 32),

        // Headline
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.15,
              letterSpacing: -1.0,
            ),
            children: [
              const TextSpan(text: 'Care today.\n'),
              TextSpan(
                text: 'Covered',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                ),
              ),
              const TextSpan(text: ' always.'),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn(duration: 600.ms).slideX(begin: -0.1),

        const SizedBox(height: 14),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: const Text(
            'Smart health insurance plans that put you and your family first. Sub-second clinical approvals powered by AI.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 600.ms),

        const SizedBox(height: 28),

        // 4 Benefit Tiles
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _BenefitTile(
                icon: PhosphorIconsRegular.shieldCheck,
                title: 'Health Coverage',
                subtitle: 'Comprehensive plans for every need',
              ),
              _BenefitTile(
                icon: PhosphorIconsRegular.usersThree,
                title: 'Family Protection',
                subtitle: 'Secure your loved ones\' future',
              ),
              _BenefitTile(
                icon: PhosphorIconsRegular.lightning,
                title: 'Cashless Claims',
                subtitle: 'Hassle-free & instant settlement',
              ),
              _BenefitTile(
                icon: PhosphorIconsRegular.headset,
                title: '24/7 Support',
                subtitle: 'We\'re here for you, always',
              ),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 600.ms),

        const SizedBox(height: 36),

        // Phone & Healthcare Dashboard Graphic Mockup
        const _HealthcareAppGraphicMockup()
            .animate(delay: 400.ms)
            .fadeIn(duration: 700.ms)
            .scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }
}

// ─── Benefit Tile ─────────────────────────────────────────────────────────────
class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Healthcare Graphic Mockup (Phone + Floating Health Cards) ────────────────
class _HealthcareAppGraphicMockup extends StatelessWidget {
  const _HealthcareAppGraphicMockup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: 520,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Smartphone Frame
          Positioned(
            left: 20,
            top: 0,
            child: Container(
              width: 220,
              height: 235,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone App Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(PhosphorIconsRegular.pulse, size: 14, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'PriorX App',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Policy Info
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsRegular.shieldCheck, color: Color(0xFF2563EB), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Policy #PX-98421', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('Full Coverage · \$500,000', style: TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Claim Status Widget
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                            child: const Icon(PhosphorIconsRegular.check, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Claim Approved', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                              Text('Sub-second auto decision', style: TextStyle(fontSize: 9, color: Color(0xFF3B82F6))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Analytical Badge 1: Instant Approval
          Positioned(
            right: 40,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(PhosphorIconsRegular.lightning, color: Color(0xFFD97706), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('< 1.5s Speed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text('Instant AI Auth', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Analytical Badge 2: 99.4% Settlement Rate
          Positioned(
            right: 15,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(PhosphorIconsRegular.shieldCheck, color: Color(0xFF16A34A), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('99.4% Accuracy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      Text('CMS 2026 Compliant', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
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

// ─── Right Side: Login Card Widget ───────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscurePass;
  final bool isLoading;
  final bool rememberMe;
  final String? errorMsg;
  final int selectedDemo;
  final VoidCallback onTogglePass;
  final Function(bool?) onToggleRemember;
  final VoidCallback onSignIn;
  final Function(int) onFillDemo;
  final VoidCallback onForgotPass;
  final bool isMobile;

  const _LoginCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscurePass,
    required this.isLoading,
    required this.rememberMe,
    required this.errorMsg,
    required this.selectedDemo,
    required this.onTogglePass,
    required this.onToggleRemember,
    required this.onSignIn,
    required this.onFillDemo,
    required this.onForgotPass,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 36,
        vertical: isMobile ? 28 : 36,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Bar (Controls on desktop)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isMobile) const _PriorXLogoHeader() else const SizedBox.shrink(),
              const _TopControlsHeader(),
            ],
          ),

          const SizedBox(height: 24),

          // Healthcare Icon Badge
          Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
              ),
              child: const Icon(
                PhosphorIconsRegular.shieldCheck,
                color: Color(0xFF4F46E5),
                size: 28,
              ),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 16),

          // Welcome Header
          Center(
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                    children: [
                      const TextSpan(text: 'Welcome '),
                      TextSpan(
                        text: 'back!',
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 40.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to your PRIORX account',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 24),

          // Quick Demo Role Pills Selector
          _QuickDemoRoleSelector(
            selectedIndex: selectedDemo,
            onSelect: onFillDemo,
          ),

          const SizedBox(height: 24),

          // Form
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Field Label
                const Text(
                  'Email or Mobile Number',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // Email Field
                TextFormField(
                  controller: emailCtrl,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email or mobile number',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(PhosphorIconsRegular.envelopeSimple, size: 18, color: Color(0xFF64748B)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error.withOpacity(0.6)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Field Label
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // Password Field
                TextFormField(
                  controller: passCtrl,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
                  obscureText: obscurePass,
                  onFieldSubmitted: (_) => onSignIn(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon: const Icon(PhosphorIconsRegular.lockSimple, size: 18, color: Color(0xFF64748B)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: onTogglePass,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error.withOpacity(0.6)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Remember me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: onToggleRemember,
                            activeColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: onForgotPass,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Error Message Banner
                if (errorMsg != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.warningCircle, size: 18, color: Color(0xFFDC2626)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMsg!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1),
                ],

                const SizedBox(height: 24),

                // Primary Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSignIn,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Create Account Row
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'New to PRIORX? ',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Quick hint message for demo mode or navigation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a Quick Demo role above to test PriorX features.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 18),

                // Bottom Trust Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _TrustBadge(icon: PhosphorIconsRegular.shieldCheck, label: 'Trusted & Secure'),
                    _TrustBadge(icon: PhosphorIconsRegular.lightning, label: 'Quick Claim'),
                    _TrustBadge(icon: PhosphorIconsRegular.fileText, label: '100% Paperless'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Demo Role Selector Pills ──────────────────────────────────────────
class _QuickDemoRoleSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const _QuickDemoRoleSelector({
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _roles = [
    ('Admin', UserRole.administrator, PhosphorIconsRegular.crown),
    ('Doctor', UserRole.doctor, PhosphorIconsRegular.stethoscope),
    ('Reviewer', UserRole.insuranceReviewer, PhosphorIconsRegular.shieldCheck),
    ('Staff', UserRole.hospitalStaff, PhosphorIconsRegular.hospital),
    ('Patient', UserRole.patient, PhosphorIconsRegular.user),
    ('Hosp Admin', UserRole.adminHospital, PhosphorIconsRegular.briefcase),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(PhosphorIconsRegular.lightning, size: 14, color: Color(0xFFD97706)),
              SizedBox(width: 6),
              Text(
                'Quick Demo — Select a role to auto-fill',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _roles.asMap().entries.map((e) {
              final i = e.key;
              final (label, role, icon) = e.value;
              final isSelected = i == selectedIndex;
              return InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 13,
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Trust Badge Widget ───────────────────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF10B981)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
