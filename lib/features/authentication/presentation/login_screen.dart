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
import 'widgets/priorx_auth_widgets.dart';

/// Redesigned PriorX Healthcare Insurance Login Screen.
/// Fits 100% inside a single viewport — NO scrolling.
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
  int _selectedDemoRole = 0;
  late AnimationController _bgAnimationCtrl;

  @override
  void initState() {
    super.initState();
    _bgAnimationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

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
    final vw = size.width;
    final vh = size.height;
    final isMobile = vw < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Ambient Soft Background
          Positioned.fill(
            child: _HealthcareAmbientBackground(animation: _bgAnimationCtrl),
          ),

          // Main Fixed Viewport Layout
          SafeArea(
            child: SizedBox(
              width: vw,
              height: vh,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 28,
                  vertical: isMobile ? 8 : 12,
                ),
                child: Column(
                  children: [
                    // Mobile Top Bar
                    if (isMobile)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Flexible(child: PriorXLogoHeader(height: 26)),
                            SizedBox(width: 6),
                            PriorXTopControlsHeader(compact: true),
                          ],
                        ),
                      ),

                    // Main Viewport Center Area (No ScrollView)
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isMobile ? math.min(480, vw - 24) : math.min(1500, vw - 48),
                              maxHeight: math.max(300, vh - (isMobile ? 50 : 70)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left Side: Promotional Section (Desktop Only)
                                if (!isMobile)
                                  Expanded(
                                    flex: 52,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: PriorXLeftPromotionalSection(vh: vh),
                                    ),
                                  ),

                                if (!isMobile) SizedBox(width: vw > 1400 ? 36 : 20),

                                // Right Side: Login Card
                                Expanded(
                                  flex: isMobile ? 1 : 48,
                                  child: Align(
                                    alignment: Alignment.center,
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
                                      onRegister: () => context.go(RouteNames.register),
                                      isMobile: isMobile,
                                      vh: vh,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 2),
                      child: Text(
                        'PRIORX HEALTH INSURANCE PLATFORM · Protecting lives. Building trust.',
                        style: TextStyle(
                          color: const Color(0xFF64748B).withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
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
            Positioned(
              top: -80 + (15 * math.sin(angle)),
              left: -80 + (15 * math.cos(angle)),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE0E7FF).withOpacity(0.5),
                      const Color(0xFFE0E7FF).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100 + (20 * math.cos(angle)),
              right: -100 + (20 * math.sin(angle)),
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFDDD6FE).withOpacity(0.4),
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
  final VoidCallback onRegister;
  final bool isMobile;
  final double vh;

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
    required this.onRegister,
    required this.isMobile,
    required this.vh,
  });

  @override
  Widget build(BuildContext context) {
    // Smooth dynamic spacing based on viewport height (NO ScrollView)
    final tHeight = ((vh - 500) / 350).clamp(0.0, 1.0);
    final isTall = vh >= 850;
    final isMedium = vh >= 720 && vh < 850;
    final vw = MediaQuery.of(context).size.width;
    final cardWidth = isMobile ? math.min(480.0, vw - 24) : math.min(740.0, (vw - 60) * 0.48);

    final cardPadding = EdgeInsets.only(
      left: isMobile ? 20.0 : (28.0 + (6.0 * tHeight)),
      right: isMobile ? 20.0 : (28.0 + (6.0 * tHeight)),
      top: isMobile ? 18.0 : (32.0 + (14.0 * tHeight)),
      bottom: isMobile ? 18.0 : (32.0 + (14.0 * tHeight)),
    );

    final illustrationHeight = isMobile ? 110.0 : (150.0 + (30.0 * tHeight));
    final gap = isMobile ? 6.0 : (12.0 + (14.0 * tHeight));
    final fieldGap = isMobile ? 4.0 : (8.0 + (8.0 * tHeight));
    final inputHeight = isMobile ? 46.0 : (54.0 + (4.0 * tHeight));
    final buttonHeight = isMobile ? 48.0 : (56.0 + (4.0 * tHeight));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: cardPadding,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: UnconstrainedBox(
          child: SizedBox(
            width: cardWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
          // Top Controls Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isMobile) PriorXLogoHeader(height: isTall ? 36 : 30) else const SizedBox.shrink(),
              PriorXTopControlsHeader(compact: !isTall),
            ],
          ),

          SizedBox(height: gap),

          // MANDATORY Healthcare City Vector Illustration (Centered above Welcome Back)
          Center(
            child: PriorXCityIllustration(width: isTall ? 200 : (isMedium ? 170 : 130), height: illustrationHeight),
          ),

          SizedBox(height: gap * 0.75),

          // Welcome Header
          Center(
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isTall ? 24 : (isMedium ? 20 : 17),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                    children: [
                      const TextSpan(text: 'Welcome '),
                      TextSpan(
                        text: 'back!',
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF6366F1)],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 100.0, 30.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTall ? 4 : 2),
                Text(
                  'Sign in to your PRIORX account',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: isTall ? 13 : (isMedium ? 11 : 10),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ).animate(delay: 50.ms).fadeIn(),

          SizedBox(height: gap),

          // Quick Demo Role Pills Selector
          _QuickDemoRoleSelector(
            selectedIndex: selectedDemo,
            onSelect: onFillDemo,
            compact: !isTall,
          ),

          SizedBox(height: gap),

          // Form
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email Label
                Text(
                  'Email or Mobile Number',
                  style: TextStyle(
                    color: const Color(0xFF334155),
                    fontSize: isTall ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTall ? 4 : 2),

                // Email Input
                SizedBox(
                  height: inputHeight,
                  child: TextFormField(
                    controller: emailCtrl,
                    style: TextStyle(color: const Color(0xFF0F172A), fontSize: isTall ? 13 : 12),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      hint: 'Enter your email or mobile number',
                      icon: PhosphorIconsRegular.envelopeSimple,
                      isTall: isTall,
                      isMedium: isMedium,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                ),

                SizedBox(height: fieldGap),

                // Password Label
                Text(
                  'Password',
                  style: TextStyle(
                    color: const Color(0xFF334155),
                    fontSize: isTall ? 12 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTall ? 4 : 2),

                // Password Input
                SizedBox(
                  height: inputHeight,
                  child: TextFormField(
                    controller: passCtrl,
                    style: TextStyle(color: const Color(0xFF0F172A), fontSize: isTall ? 13 : 12),
                    obscureText: obscurePass,
                    onFieldSubmitted: (_) => onSignIn(),
                    decoration: _inputDecoration(
                      hint: 'Enter your password',
                      icon: PhosphorIconsRegular.lockSimple,
                      isTall: isTall,
                      isMedium: isMedium,
                      suffix: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                          size: isTall ? 16 : 14,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: onTogglePass,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      return null;
                    },
                  ),
                ),

                SizedBox(height: isTall ? 8 : 4),

                // Remember me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Checkbox(
                              value: rememberMe,
                              onChanged: onToggleRemember,
                              activeColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Remember me',
                              style: TextStyle(
                                color: const Color(0xFF475569),
                                fontSize: isTall ? 12 : 10,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onForgotPass,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: const Color(0xFF2563EB),
                          ),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: isTall ? 12 : 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Error Message Banner
                if (errorMsg != null) ...[
                  SizedBox(height: isTall ? 8 : 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsRegular.warningCircle, size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            errorMsg!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

                SizedBox(height: gap * 1.2),

                // Primary Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSignIn,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTall ? 14 : 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(PhosphorIconsRegular.arrowRight, color: Colors.white, size: isTall ? 16 : 14),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isTall ? 12 : 8),

                // Create Account Link
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'New to PRIORX? ',
                          style: TextStyle(color: const Color(0xFF64748B), fontSize: isTall ? 12 : 11),
                        ),
                        GestureDetector(
                          onTap: onRegister,
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontSize: isTall ? 12 : 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isTall ? 14 : 8),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SizedBox(height: isTall ? 12 : 6),

                // Bottom Trust Indicators
                PriorXTrustIndicators(compact: !isTall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isTall,
    required bool isMedium,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: isTall ? 12 : 11),
      prefixIcon: Icon(icon, size: isTall ? 16 : 14, color: const Color(0xFF64748B)),
      suffixIcon: suffix,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTall ? 12 : 10,
        vertical: isTall ? 10 : 6,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.error.withOpacity(0.6)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }
}

// ─── Quick Demo Role Selector Pills ──────────────────────────────────────────
class _QuickDemoRoleSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;
  final bool compact;

  const _QuickDemoRoleSelector({
    required this.selectedIndex,
    required this.onSelect,
    this.compact = false,
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
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.lightning, size: compact ? 11 : 12, color: const Color(0xFFD97706)),
                const SizedBox(width: 4),
                Text(
                  'Quick Demo — Select role to auto-fill',
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontSize: compact ? 9.5 : 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Wrap(
            spacing: compact ? 4 : 5,
            runSpacing: compact ? 4 : 5,
            children: _roles.asMap().entries.map((e) {
              final i = e.key;
              final (label, role, icon) = e.value;
              final isSelected = i == selectedIndex;
              return InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 8,
                    vertical: compact ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                        size: compact ? 10 : 11,
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                          fontSize: compact ? 9.5 : 10,
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
