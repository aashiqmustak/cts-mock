import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_role.dart';

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
      duration: const Duration(seconds: 22),
    )..repeat();
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
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(RouteNames.dashboard);
    } else {
      setState(() => _errorMsg = ref.read(authProvider).errorMessage);
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
    final isMobile = size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: Stack(
        children: [
          // Dynamic mesh background
          Positioned.fill(
            child: _AmbientMeshBackground(animation: _bgAnimationCtrl),
          ),

          // Tech Grid lines
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // Content Layout
          Row(
            children: [
              // Left hero panel (hidden on mobile)
              if (!isMobile)
                Expanded(
                  child: _HeroPanel(),
                ),

              // Right register form
              SizedBox(
                width: isMobile ? size.width : 550,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.035),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title
                                  Text(
                                    'Create your account',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),

                                  const SizedBox(height: 6),

                                  Text(
                                    'Register to join the PriorX clinical network',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.15),

                                  const SizedBox(height: 28),

                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Name
                                        TextFormField(
                                          controller: _nameCtrl,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          decoration: _buildInputDecoration(
                                            label: 'Full Name',
                                            icon: PhosphorIconsRegular.user,
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Full Name is required';
                                            return null;
                                          },
                                        ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.15),

                                        const SizedBox(height: 16),

                                        // Email
                                        TextFormField(
                                          controller: _emailCtrl,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: _buildInputDecoration(
                                            label: 'Email address',
                                            icon: PhosphorIconsRegular.envelope,
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Email is required';
                                            if (!v.contains('@')) return 'Enter a valid email';
                                            return null;
                                          },
                                        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15),

                                        const SizedBox(height: 16),

                                        // Role Dropdown
                                        DropdownButtonFormField<UserRole>(
                                          value: _selectedRole,
                                          dropdownColor: const Color(0xFF131A2C),
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          decoration: _buildInputDecoration(
                                            label: 'Account Role',
                                            icon: PhosphorIconsRegular.userGear,
                                          ),
                                          items: UserRole.values.map((role) {
                                            return DropdownMenuItem<UserRole>(
                                              value: role,
                                              child: Row(
                                                children: [
                                                  Icon(role.icon, size: 16, color: role.color),
                                                  const SizedBox(width: 8),
                                                  Text(role.displayName, style: const TextStyle(color: Colors.white)),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedRole = val;
                                              });
                                            }
                                          },
                                        ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15),

                                        // Conditional: Facility
                                        if (_showFacilityField) ...[
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _facilityCtrl,
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                            decoration: _buildInputDecoration(
                                              label: 'Healthcare Facility / Organization',
                                              icon: PhosphorIconsRegular.hospital,
                                            ),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) return 'Facility name is required';
                                              return null;
                                            },
                                          ).animate().fadeIn().slideY(begin: 0.1),
                                        ],

                                        // Conditional: Doctor Specialization
                                        if (_showDoctorFields) ...[
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _specializationCtrl,
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                            decoration: _buildInputDecoration(
                                              label: 'Clinical Specialization',
                                              icon: PhosphorIconsRegular.stethoscope,
                                            ),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) return 'Specialization is required';
                                              return null;
                                            },
                                          ).animate().fadeIn().slideY(begin: 0.1),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _licenseCtrl,
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                            decoration: _buildInputDecoration(
                                              label: 'Medical License Number (NPI)',
                                              icon: PhosphorIconsRegular.identificationCard,
                                            ),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) return 'License number is required';
                                              return null;
                                            },
                                          ).animate().fadeIn().slideY(begin: 0.1),
                                        ],

                                        const SizedBox(height: 16),

                                        // Password
                                        TextFormField(
                                          controller: _passCtrl,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          obscureText: _obscurePass,
                                          decoration: _buildInputDecoration(
                                            label: 'Password',
                                            icon: PhosphorIconsRegular.lock,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                                size: 16,
                                                color: Colors.white.withOpacity(0.5),
                                              ),
                                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Password is required';
                                            if (v.length < 6) return 'Password must be at least 6 characters';
                                            return null;
                                          },
                                        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15),

                                        const SizedBox(height: 16),

                                        // Confirm Password
                                        TextFormField(
                                          controller: _confirmPassCtrl,
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                          obscureText: _obscureConfirmPass,
                                          decoration: _buildInputDecoration(
                                            label: 'Confirm Password',
                                            icon: PhosphorIconsRegular.lockSimple,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                                size: 16,
                                                color: Colors.white.withOpacity(0.5),
                                              ),
                                              onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) return 'Please confirm your password';
                                            if (v != _passCtrl.text) return 'Passwords do not match';
                                            return null;
                                          },
                                        ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.15),

                                        // Error Message banner
                                        if (_errorMsg != null) ...[
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.error.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: AppColors.error.withOpacity(0.24)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(PhosphorIconsRegular.warning, size: 16, color: AppColors.error),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    _errorMsg!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
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

                                        // Register button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _signUp,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6E56CF),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Register Account',
                                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                                                  ),
                                          ),
                                        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.15),

                                        const SizedBox(height: 20),

                                        // Redirect back to Login
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Already have an account?",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.6),
                                                fontSize: 13,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => context.go(RouteNames.login),
                                              style: TextButton.styleFrom(
                                                foregroundColor: const Color(0xFF0EA5E9),
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                              ),
                                              child: const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.15),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
      prefixIcon: Icon(icon, size: 16, color: Colors.white.withOpacity(0.5)),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6E56CF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error.withOpacity(0.4)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.02),
    );
  }
}

// ─── Ambient Animated Background Mesh ─────────────────────────────────────────
class _AmbientMeshBackground extends StatelessWidget {
  final Animation<double> animation;
  const _AmbientMeshBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeshPainter(animation.value),
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double progress;
  _MeshPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF6E56CF).withOpacity(0.18) // Deep Royal Purple
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    final paint2 = Paint()
      ..color = const Color(0xFF0EA5E9).withOpacity(0.14) // Sky Blue
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 140);

    final paint3 = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.12) // Healthcare blue
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    final angle = progress * 2 * math.pi;

    // Orbiting Blob 1
    final x1 = size.width * 0.3 + (size.width * 0.15) * math.cos(angle);
    final y1 = size.height * 0.3 + (size.height * 0.1) * math.sin(angle);
    canvas.drawCircle(Offset(x1, y1), 220, paint1);

    // Orbiting Blob 2 (Offset by 90deg)
    final x2 = size.width * 0.75 + (size.width * 0.12) * math.sin(angle + math.pi / 2);
    final y2 = size.height * 0.55 + (size.height * 0.15) * math.cos(angle + math.pi / 2);
    canvas.drawCircle(Offset(x2, y2), 260, paint2);

    // Orbiting Blob 3 (Offset by 180deg)
    final x3 = size.width * 0.5 + (size.width * 0.2) * math.cos(angle + math.pi);
    final y3 = size.height * 0.25 + (size.height * 0.12) * math.sin(angle + math.pi);
    canvas.drawCircle(Offset(x3, y3), 180, paint3);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => oldDelegate.progress != progress;
}

// ─── Grid Painter ────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const step = 45.0;
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

// ─── Hero Panel ───────────────────────────────────────────────────────────────
class _HeroPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo and App Name
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF6E56CF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6E56CF).withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(PhosphorIconsRegular.pulse, color: Color(0xFF0EA5E9), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'PriorX',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Text(
                  'Join clinical network',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ).animate().slideX(begin: -0.2).fadeIn(duration: 500.ms),

          const SizedBox(height: 36),

          Text(
            'Secure Clinical Portal Registration',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
          ).animate(delay: 100.ms).slideX(begin: -0.2).fadeIn(duration: 500.ms),

          const SizedBox(height: 16),

          Text(
            'Create your professional credentials to submit and track medical prior authorizations in real-time, utilizing our sub-second AI core decisioning.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  height: 1.6,
                ),
          ).animate(delay: 200.ms).slideX(begin: -0.2).fadeIn(duration: 500.ms),

          const SizedBox(height: 40),

          // Benefit cards
          _BenefitItem(
            icon: PhosphorIconsRegular.shieldCheck,
            title: 'HIPAA & SOC 2 Compliant',
            description: 'Your clinical data is protected by industry standard encryption and access logs.',
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 20),

          _BenefitItem(
            icon: PhosphorIconsRegular.lightning,
            title: 'Real-time Approvals',
            description: 'AI model validates coverage criteria and returns instant decisions when possible.',
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 20),

          _BenefitItem(
            icon: PhosphorIconsRegular.treeStructure,
            title: 'HL7 FHIR Interoperability',
            description: 'Easily exchange clinical data and structure records dynamically.',
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: const Color(0xFF0EA5E9), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
