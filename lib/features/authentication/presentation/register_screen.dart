import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_role.dart';
import 'widgets/priorx_auth_widgets.dart';

/// Redesigned PriorX Healthcare Insurance Register Screen.
/// Fits 100% inside a single viewport — NO scrolling.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  UserRole _selectedRole = UserRole.patient;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;
  String? _errorMsg;
  late AnimationController _bgAnimationCtrl;

  @override
  void initState() {
    super.initState();
    _bgAnimationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _facilityCtrl.dispose();
    _specializationCtrl.dispose();
    _licenseCtrl.dispose();
    _phoneCtrl.dispose();
    _bgAnimationCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          name: _nameCtrl.text,
          role: _selectedRole,
          facility: _showFacilityField ? _facilityCtrl.text : null,
          specialization: _showDoctorFields ? _specializationCtrl.text : null,
          licenseNumber: _showDoctorFields ? _licenseCtrl.text : null,
          phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(RouteNames.dashboard);
    } else {
      setState(() => _errorMsg = ref.read(authProvider).errorMessage ?? 'Registration failed');
    }
  }

  bool get _showDoctorFields => _selectedRole == UserRole.doctor;
  bool get _showFacilityField =>
      _selectedRole == UserRole.doctor ||
      _selectedRole == UserRole.hospitalStaff ||
      _selectedRole == UserRole.adminHospital ||
      _selectedRole == UserRole.insuranceReviewer;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final vw = size.width;
    final vh = size.height;
    final isMobile = vw < 950;

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
                                    flex: 50,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: PriorXLeftPromotionalSection(vh: vh),
                                    ),
                                  ),

                                if (!isMobile) SizedBox(width: vw > 1400 ? 36 : 20),

                                // Right Side: Register Card
                                Expanded(
                                  flex: isMobile ? 1 : 50,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: _RegisterCard(
                                      formKey: _formKey,
                                      nameCtrl: _nameCtrl,
                                      emailCtrl: _emailCtrl,
                                      passCtrl: _passCtrl,
                                      confirmPassCtrl: _confirmPassCtrl,
                                      facilityCtrl: _facilityCtrl,
                                      specializationCtrl: _specializationCtrl,
                                      licenseCtrl: _licenseCtrl,
                                      phoneCtrl: _phoneCtrl,
                                      selectedRole: _selectedRole,
                                      showFacilityField: _showFacilityField,
                                      showDoctorFields: _showDoctorFields,
                                      obscurePass: _obscurePass,
                                      obscureConfirmPass: _obscureConfirmPass,
                                      isLoading: _isLoading,
                                      errorMsg: _errorMsg,
                                      onRoleChanged: (role) => setState(() => _selectedRole = role),
                                      onTogglePass: () => setState(() => _obscurePass = !_obscurePass),
                                      onToggleConfirmPass: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                                      onSignUp: _signUp,
                                      onLogin: () => context.go(RouteNames.login),
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

// ─── Right Side: Register Card Widget ────────────────────────────────────────
class _RegisterCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmPassCtrl;
  final TextEditingController facilityCtrl;
  final TextEditingController specializationCtrl;
  final TextEditingController licenseCtrl;
  final TextEditingController phoneCtrl;
  final UserRole selectedRole;
  final bool showFacilityField;
  final bool showDoctorFields;
  final bool obscurePass;
  final bool obscureConfirmPass;
  final bool isLoading;
  final String? errorMsg;
  final Function(UserRole) onRoleChanged;
  final VoidCallback onTogglePass;
  final VoidCallback onToggleConfirmPass;
  final VoidCallback onSignUp;
  final VoidCallback onLogin;
  final bool isMobile;
  final double vh;

  const _RegisterCard({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmPassCtrl,
    required this.facilityCtrl,
    required this.specializationCtrl,
    required this.licenseCtrl,
    required this.phoneCtrl,
    required this.selectedRole,
    required this.showFacilityField,
    required this.showDoctorFields,
    required this.obscurePass,
    required this.obscureConfirmPass,
    required this.isLoading,
    required this.errorMsg,
    required this.onRoleChanged,
    required this.onTogglePass,
    required this.onToggleConfirmPass,
    required this.onSignUp,
    required this.onLogin,
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

    String nameHint;
    switch (selectedRole) {
      case UserRole.doctor:
        nameHint = 'e.g. Dr. Hemachandran';
        break;
      case UserRole.patient:
        nameHint = 'e.g. Susmitha';
        break;
      case UserRole.insuranceReviewer:
        nameHint = 'e.g. Mohana';
        break;
      case UserRole.hospitalStaff:
        nameHint = 'e.g. Amirtha';
        break;
      case UserRole.adminHospital:
        nameHint = 'e.g. Aswitha';
        break;
      case UserRole.administrator:
        nameHint = 'e.g. Aashiq';
        break;
    }

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
              if (!isMobile) PriorXLogoHeader(height: isTall ? 34 : 28) else const SizedBox.shrink(),
              PriorXTopControlsHeader(compact: !isTall),
            ],
          ),

          SizedBox(height: gap),

          // MANDATORY Healthcare City Vector Illustration (Centered above Create Account)
          Center(
            child: PriorXCityIllustration(width: isTall ? 180 : (isMedium ? 150 : 120), height: illustrationHeight),
          ),

          SizedBox(height: gap * 0.5),

          // Register Header
          Center(
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isTall ? 22 : (isMedium ? 19 : 16),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                    children: [
                      const TextSpan(text: 'Create your '),
                      TextSpan(
                        text: 'account',
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
                SizedBox(height: isTall ? 2 : 1),
                Text(
                  'Join PriorX for automated health insurance decisions',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: isTall ? 12 : (isMedium ? 11 : 9.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ).animate(delay: 50.ms).fadeIn(),

          SizedBox(height: gap),

          // Compact 2-Column Side-by-Side Form Grid Layout
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Button-Based Account Role Selector
                PriorXRoleSelector(
                  selectedRole: selectedRole,
                  onRoleSelected: (role) => onRoleChanged(role),
                  compact: !isTall,
                  labelText: 'Account Role',
                ),

                SizedBox(height: fieldGap),

                // Row 1: Full Name (50%) & Phone Number (50%)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Full Name', style: _labelStyle(isTall)),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: inputHeight,
                            child: TextFormField(
                              controller: nameCtrl,
                              style: _inputTextStyle(isTall),
                              decoration: _inputDecoration(
                                hint: nameHint,
                                icon: PhosphorIconsRegular.user,
                                isTall: isTall,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone Number', style: _labelStyle(isTall)),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: inputHeight,
                            child: TextFormField(
                              controller: phoneCtrl,
                              style: _inputTextStyle(isTall),
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration(
                                hint: 'e.g. +1 (555) 019-2834',
                                icon: PhosphorIconsRegular.phone,
                                isTall: isTall,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: fieldGap),

                // Row 2: Email Address & Facility Name OR Email Address & Password
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email Address', style: _labelStyle(isTall)),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: inputHeight,
                            child: TextFormField(
                              controller: emailCtrl,
                              style: _inputTextStyle(isTall),
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration(
                                hint: 'name@mediauth.ai',
                                icon: PhosphorIconsRegular.envelopeSimple,
                                isTall: isTall,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                if (!v.contains('@')) return 'Invalid email';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (showFacilityField) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Facility Name', style: _labelStyle(isTall)),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: facilityCtrl,
                                style: _inputTextStyle(isTall),
                                decoration: _inputDecoration(
                                  hint: 'Hospital name',
                                  icon: PhosphorIconsRegular.hospital,
                                  isTall: isTall,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password', style: _labelStyle(isTall)),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: passCtrl,
                                style: _inputTextStyle(isTall),
                                obscureText: obscurePass,
                                decoration: _inputDecoration(
                                  hint: 'Min 6 chars',
                                  icon: PhosphorIconsRegular.lockSimple,
                                  isTall: isTall,
                                  suffix: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                      size: 14,
                                      color: const Color(0xFF64748B),
                                    ),
                                    onPressed: onTogglePass,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (v.length < 6) return 'Min 6 chars';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: fieldGap),

                // Row 3: Password & Confirm Password (if facility shown) OR Confirm Password & Empty (if facility not shown)
                Row(
                  children: [
                    if (showFacilityField) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password', style: _labelStyle(isTall)),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: passCtrl,
                                style: _inputTextStyle(isTall),
                                obscureText: obscurePass,
                                decoration: _inputDecoration(
                                  hint: 'Min 6 chars',
                                  icon: PhosphorIconsRegular.lockSimple,
                                  isTall: isTall,
                                  suffix: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                      size: 14,
                                      color: const Color(0xFF64748B),
                                    ),
                                    onPressed: onTogglePass,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (v.length < 6) return 'Min 6 chars';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Confirm Password', style: _labelStyle(isTall)),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: inputHeight,
                            child: TextFormField(
                              controller: confirmPassCtrl,
                              style: _inputTextStyle(isTall),
                              obscureText: obscureConfirmPass,
                              decoration: _inputDecoration(
                                hint: 'Re-enter password',
                                icon: PhosphorIconsRegular.lockSimple,
                                isTall: isTall,
                                suffix: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    obscureConfirmPass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                    size: 14,
                                    color: const Color(0xFF64748B),
                                  ),
                                  onPressed: onToggleConfirmPass,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (v != passCtrl.text) return 'Mismatch';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!showFacilityField) ...[
                      const SizedBox(width: 10),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ],
                ),

                // Row 4 (Conditional Doctor Fields: Specialization & License)
                if (showDoctorFields) ...[
                  SizedBox(height: fieldGap),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Specialization', style: _labelStyle(isTall)),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: specializationCtrl,
                                style: _inputTextStyle(isTall),
                                decoration: _inputDecoration(
                                  hint: 'Cardiology, etc.',
                                  icon: PhosphorIconsRegular.stethoscope,
                                  isTall: isTall,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('License / NPI', style: _labelStyle(isTall)),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: inputHeight,
                              child: TextFormField(
                                controller: licenseCtrl,
                                style: _inputTextStyle(isTall),
                                decoration: _inputDecoration(
                                  hint: 'NPI-1234567890',
                                  icon: PhosphorIconsRegular.identificationCard,
                                  isTall: isTall,
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Error Message Banner
                if (errorMsg != null) ...[
                  SizedBox(height: isTall ? 6 : 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

                // Primary Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSignUp,
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
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTall ? 14 : 12.5,
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

                SizedBox(height: isTall ? 8 : 4),

                // Sign In Link
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(color: const Color(0xFF64748B), fontSize: isTall ? 11.5 : 10.5),
                        ),
                        GestureDetector(
                          onTap: onLogin,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontSize: isTall ? 11.5 : 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isTall ? 10 : 6),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                SizedBox(height: isTall ? 8 : 4),

                // Bottom Trust Indicators
                PriorXTrustIndicators(compact: !isTall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(bool isTall) {
    return TextStyle(
      color: const Color(0xFF334155),
      fontSize: isTall ? 11.5 : 10.5,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _inputTextStyle(bool isTall) {
    return TextStyle(
      color: const Color(0xFF0F172A),
      fontSize: isTall ? 12 : 11,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isTall,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: isTall ? 11.5 : 10.5),
      prefixIcon: Icon(icon, size: isTall ? 15 : 13, color: const Color(0xFF64748B)),
      suffixIcon: suffix,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTall ? 10 : 8,
        vertical: isTall ? 8 : 4,
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
