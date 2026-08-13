import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_role.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;
  String? _errorMsg;
  int _selectedDemoRole = 0; // 0=admin, 1=doctor, 2=reviewer, 3=staff, 4=patient
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bgAnimationCtrl.dispose();
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

              // Right login form
              SizedBox(
                width: isMobile ? size.width : 500,
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
        ],
      ),
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
                  'AI Prior Auth',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ).animate().slideX(begin: -0.2).fadeIn(duration: 500.ms),

          const SizedBox(height: 36),

          Text(
            'Automate clinical authorizations with sub-second decisioning',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
          ).animate(delay: 100.ms).slideX(begin: -0.2).fadeIn(duration: 500.ms),

          const SizedBox(height: 32),

          // Live Feed Ticker
          Expanded(
            child: const _LiveAuthFeedWidget(),
          ),

          const SizedBox(height: 24),

          // Compliance Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ComplianceBadge('HIPAA Compliant'),
              _ComplianceBadge('HL7 FHIR R4'),
              _ComplianceBadge('SOC 2 Type II'),
              _ComplianceBadge('CMS 2026 Aligned'),
            ],
          ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
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
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── Simulated Live Prior Auth Ticker Feed ───────────────────────────────────
class _MockClaim {
  final String id;
  final String patientName;
  final String procedure;
  final String payer;
  final String status; // 'receiving', 'analyzing', 'completed'
  final String result; // 'Approved', 'Escalated'
  final double confidence;
  final double seconds;

  _MockClaim({
    required this.id,
    required this.patientName,
    required this.procedure,
    required this.payer,
    required this.status,
    required this.result,
    required this.confidence,
    required this.seconds,
  });
}

class _LiveAuthFeedWidget extends StatefulWidget {
  const _LiveAuthFeedWidget();

  @override
  State<_LiveAuthFeedWidget> createState() => _LiveAuthFeedWidgetState();
}

class _LiveAuthFeedWidgetState extends State<_LiveAuthFeedWidget> {
  late Timer _timer;
  final List<_MockClaim> _claims = [];
  int _counter = 9483;

  final List<Map<String, String>> _mockProcedures = [
    {'name': 'Jane Cooper', 'procedure': 'MRI Brain w/o Contrast', 'payer': 'Aetna'},
    {'name': 'Robert Fox', 'procedure': 'CT Chest w/ Contrast', 'payer': 'Cigna'},
    {'name': 'Albert Flores', 'procedure': 'Lumbar Spine Fusion', 'payer': 'UHC'},
    {'name': 'Kristin Watson', 'procedure': 'Echocardiogram 2D', 'payer': 'Humana'},
    {'name': 'Cody Fisher', 'procedure': 'PET Scan Whole Body', 'payer': 'Blue Shield'},
    {'name': 'Esther Howard', 'procedure': 'Knee Arthroscopy', 'payer': 'Aetna'},
    {'name': 'Ronald Richards', 'procedure': 'Polysomnography Study', 'payer': 'Medicare'},
  ];

  @override
  void initState() {
    super.initState();
    // Seed with a few completed claims
    _claims.addAll([
      _MockClaim(
        id: 'PA-9482',
        patientName: 'Jane Cooper',
        procedure: 'MRI Brain w/o Contrast',
        payer: 'Aetna',
        status: 'completed',
        result: 'Approved',
        confidence: 0.98,
        seconds: 1.2,
      ),
      _MockClaim(
        id: 'PA-9481',
        patientName: 'Robert Fox',
        procedure: 'CT Chest w/ Contrast',
        payer: 'Cigna',
        status: 'completed',
        result: 'Approved',
        confidence: 0.96,
        seconds: 1.5,
      ),
    ]);

    // Periodically insert a new claim
    _timer = Timer.periodic(const Duration(milliseconds: 3800), (timer) {
      if (!mounted) return;
      _addNewClaim();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _addNewClaim() {
    final rand = math.Random();
    final item = _mockProcedures[rand.nextInt(_mockProcedures.length)];
    final claimId = 'PA-${_counter++}';
    final isEscalated = rand.nextDouble() < 0.15; // 15% escalation rate

    final newClaim = _MockClaim(
      id: claimId,
      patientName: item['name']!,
      procedure: item['procedure']!,
      payer: item['payer']!,
      status: 'receiving',
      result: isEscalated ? 'Escalated' : 'Approved',
      confidence: 0.84 + rand.nextDouble() * 0.15,
      seconds: 0.8 + rand.nextDouble() * 1.4,
    );

    setState(() {
      _claims.insert(0, newClaim);
      if (_claims.length > 5) {
        _claims.removeLast();
      }
    });

    // Ingesting -> Policy Analysis
    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final idx = _claims.indexWhere((c) => c.id == claimId);
      if (idx != -1) {
        setState(() {
          _claims[idx] = _MockClaim(
            id: _claims[idx].id,
            patientName: _claims[idx].patientName,
            procedure: _claims[idx].procedure,
            payer: _claims[idx].payer,
            status: 'analyzing',
            result: _claims[idx].result,
            confidence: _claims[idx].confidence,
            seconds: _claims[idx].seconds,
          );
        });
      }
    });

    // Policy Analysis -> Complete
    Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      final idx = _claims.indexWhere((c) => c.id == claimId);
      if (idx != -1) {
        setState(() {
          _claims[idx] = _MockClaim(
            id: _claims[idx].id,
            patientName: _claims[idx].patientName,
            procedure: _claims[idx].procedure,
            payer: _claims[idx].payer,
            status: 'completed',
            result: _claims[idx].result,
            confidence: _claims[idx].confidence,
            seconds: _claims[idx].seconds,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Header Ticker Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.01),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(PhosphorIconsRegular.pulse, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(
                      'CLINICAL INTELLIGENCE ENGINE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ACTIVE CORE',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Claims feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _claims.length,
              itemBuilder: (context, index) {
                return _MockClaimWidget(claim: _claims[index]);
              },
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().scaleY(begin: 0.95);
  }
}

class _MockClaimWidget extends StatelessWidget {
  final _MockClaim claim;
  const _MockClaimWidget({required this.claim});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Widget statusWidget;

    if (claim.status == 'receiving') {
      statusColor = const Color(0xFF0EA5E9);
      statusWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF0EA5E9)),
          ),
          const SizedBox(width: 6),
          Text(
            'Ingesting',
            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (claim.status == 'analyzing') {
      statusColor = const Color(0xFFF59E0B);
      statusWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 6),
          Text(
            'Analyzing',
            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else {
      final isApproved = claim.result == 'Approved';
      statusColor = isApproved ? const Color(0xFF10B981) : const Color(0xFF8B5CF6);
      statusWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: statusColor.withOpacity(0.24)),
        ),
        child: Text(
          isApproved ? 'Approved' : 'Escalated',
          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: claim.status == 'completed'
              ? statusColor.withOpacity(0.18)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              claim.status != 'completed'
                  ? PhosphorIconsRegular.pulse
                  : (claim.result == 'Approved' ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.userGear),
              color: statusColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      claim.patientName,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      claim.id,
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${claim.procedure} · ${claim.payer}',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (claim.status == 'completed') ...[
                  const SizedBox(height: 5),
                  Text(
                    claim.result == 'Approved'
                        ? 'Approved in ${claim.seconds.toStringAsFixed(1)}s · ${(claim.confidence * 100).toStringAsFixed(0)}% confidence'
                        : 'Review needed · Auto-routed to Clinical Coordinator',
                    style: TextStyle(
                      color: claim.result == 'Approved' ? Colors.green.shade200 : Colors.purple.shade200,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          statusWidget,
        ],
      ),
    );
  }
}

// ─── Login Form Card (Glassmorphic) ──────────────────────────────────────────
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
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscurePass,
    required this.isLoading,
    required this.errorMsg,
    required this.selectedDemo,
    required this.onTogglePass,
    required this.onSignIn,
    required this.onFillDemo,
    required this.onForgotPass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: Colors.transparent,
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
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15),

                        const SizedBox(height: 6),

                        Text(
                          'Sign in to your PriorX account',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.15),

                        const SizedBox(height: 28),

                        // Demo accounts
                        _DemoSelector(selectedIndex: selectedDemo, onSelect: onFillDemo),

                        const SizedBox(height: 28),

                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              // Email
                              TextFormField(
                                controller: emailCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email address',
                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                  prefixIcon: Icon(PhosphorIconsRegular.envelope, size: 16, color: Colors.white.withOpacity(0.5)),
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
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email is required';
                                  if (!v.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15),

                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: passCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                obscureText: obscurePass,
                                onFieldSubmitted: (_) => onSignIn(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                  prefixIcon: Icon(PhosphorIconsRegular.lock, size: 16, color: Colors.white.withOpacity(0.5)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePass ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    onPressed: onTogglePass,
                                  ),
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
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password is required';
                                  return null;
                                },
                              ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15),

                              const SizedBox(height: 10),

                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: onForgotPass,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF0EA5E9),
                                  ),
                                  child: const Text('Forgot password?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ),

                              // Error Message banner
                              if (errorMsg != null) ...[
                                const SizedBox(height: 8),
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
                                          errorMsg!,
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

                              const SizedBox(height: 20),

                              // Sign in button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : onSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6E56CF),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                                        ),
                                ),
                              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Footer
                        Text(
                          'HIPAA Compliant · SOC 2 Type II · HL7 FHIR R4',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate(delay: 450.ms).fadeIn(),
                      ],
                    ),
                  ),
                ),
              ),
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
    ('Hosp Admin', UserRole.adminHospital, PhosphorIconsRegular.briefcase),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.lightning, size: 14, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Text(
                'Quick Demo — Select a role',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? role.color.withOpacity(0.16) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? role.color : Colors.white.withOpacity(0.06),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 13, color: isSelected ? role.color : Colors.white.withOpacity(0.6)),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? role.color : Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.15);
  }
}
