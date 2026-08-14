import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../models/user_role.dart';

// ─── Mandatory Reusable Healthcare City/Building Vector Illustration ─────────
class PriorXCityIllustration extends StatelessWidget {
  final double width;
  final double height;

  const PriorXCityIllustration({
    super.key,
    this.width = 200,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft circular background glow
          Container(
            width: width * 0.75,
            height: height * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEEF2FF),
                  const Color(0xFFE0E7FF).withOpacity(0.4),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.4, 0.8, 1.0],
              ),
            ),
          ),

          // Custom Paint Vector City Skyline
          CustomPaint(
            size: Size(width, height),
            painter: _CitySkylinePainter(),
          ),

          // Floating cloud accents
          Positioned(
            top: math.max(2, height * 0.08),
            left: math.max(4, width * 0.07),
            child: Icon(
              PhosphorIconsRegular.cloud,
              size: math.max(10, height * 0.18),
              color: const Color(0xFFCBD5E1).withOpacity(0.7),
            ),
          ),
          Positioned(
            top: math.max(4, height * 0.14),
            right: math.max(6, width * 0.09),
            child: Icon(
              PhosphorIconsRegular.cloud,
              size: math.max(12, height * 0.22),
              color: const Color(0xFFCBD5E1).withOpacity(0.8),
            ),
          ),
          Positioned(
            top: math.max(2, height * 0.06),
            right: math.max(20, width * 0.30),
            child: Container(
              width: math.max(4, height * 0.07),
              height: math.max(4, height * 0.07),
              decoration: const BoxDecoration(
                color: Color(0xFF818CF8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
  }
}

class _CitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Paints
    final baseLinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = math.max(1.0, h * 0.018)
      ..style = PaintingStyle.stroke;

    final buildingFillLight = Paint()..color = const Color(0xFFF1F5F9);
    final buildingFillMedium = Paint()..color = const Color(0xFFE2E8F0);
    final buildingFillMain = Paint()..color = const Color(0xFFDBEAFE);
    final accentPaint = Paint()..color = const Color(0xFF2563EB);
    final violetPaint = Paint()..color = const Color(0xFF4F46E5);
    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = math.max(0.8, h * 0.012)
      ..style = PaintingStyle.stroke;

    final baseGroundY = h * 0.85;

    // Ground Line
    canvas.drawLine(Offset(w * 0.05, baseGroundY), Offset(w * 0.95, baseGroundY), baseLinePaint);

    // Building 1: Far Left (Small Clinic)
    final b1Rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.12, h * 0.45, w * 0.28, baseGroundY),
      Radius.circular(math.max(2, h * 0.04)),
    );
    canvas.drawRRect(b1Rect, buildingFillLight);
    canvas.drawRRect(b1Rect, linePaint);
    for (double y = h * 0.52; y < baseGroundY - (h * 0.08); y += math.max(6, h * 0.10)) {
      canvas.drawRect(Rect.fromLTWH(w * 0.16, y, w * 0.03, h * 0.05), linePaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.22, y, w * 0.03, h * 0.05), linePaint);
    }

    // Building 2: Mid-Right (Secondary Hospital Wing)
    final b2Rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.68, h * 0.38, w * 0.86, baseGroundY),
      Radius.circular(math.max(3, h * 0.05)),
    );
    canvas.drawRRect(b2Rect, buildingFillMedium);
    canvas.drawRRect(b2Rect, linePaint);
    for (double y = h * 0.46; y < baseGroundY - (h * 0.08); y += math.max(7, h * 0.11)) {
      canvas.drawRect(Rect.fromLTWH(w * 0.72, y, w * 0.035, h * 0.06), linePaint);
      canvas.drawRect(Rect.fromLTWH(w * 0.79, y, w * 0.035, h * 0.06), linePaint);
    }

    // Building 3: Far Right (Small Lab)
    final b3Rect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.84, h * 0.55, w * 0.94, baseGroundY),
      Radius.circular(math.max(2, h * 0.03)),
    );
    canvas.drawRRect(b3Rect, buildingFillLight);
    canvas.drawRRect(b3Rect, linePaint);

    // Main Centerpiece: PriorX Central Hospital Building
    final mainLeft = w * 0.32;
    final mainRight = w * 0.65;
    final mainTop = h * 0.22;

    final mainBuildingRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(mainLeft, mainTop, mainRight, baseGroundY),
      topLeft: Radius.circular(math.max(4, h * 0.08)),
      topRight: Radius.circular(math.max(4, h * 0.08)),
    );
    canvas.drawRRect(mainBuildingRRect, buildingFillMain);
    canvas.drawRRect(mainBuildingRRect, baseLinePaint);

    // Center Tower Dome / Helipad Roof Feature
    final towerLeft = w * 0.42;
    final towerRight = w * 0.55;
    final towerTop = h * 0.12;
    final towerRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(towerLeft, towerTop, towerRight, mainTop),
      topLeft: Radius.circular(math.max(3, h * 0.06)),
      topRight: Radius.circular(math.max(3, h * 0.06)),
    );
    canvas.drawRRect(towerRRect, Paint()..color = const Color(0xFFEFF6FF));
    canvas.drawRRect(towerRRect, baseLinePaint);

    // Medical Cross (+) Badge on Central Tower
    final crossCenterX = (towerLeft + towerRight) / 2;
    final crossCenterY = (towerTop + mainTop) / 2;
    final crossArmWidth = math.max(2.0, h * 0.035);
    final crossArmLength = math.max(6.0, h * 0.10);

    canvas.drawRect(
      Rect.fromCenter(center: Offset(crossCenterX, crossCenterY), width: crossArmLength, height: crossArmWidth),
      accentPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(crossCenterX, crossCenterY), width: crossArmWidth, height: crossArmLength),
      accentPaint,
    );

    // Windows Grid on Main Central Building
    for (double y = mainTop + (h * 0.10); y < baseGroundY - (h * 0.12); y += math.max(8, h * 0.12)) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, y, w * 0.045, h * 0.06), const Radius.circular(1.5)),
        violetPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.44, y, w * 0.045, h * 0.06), const Radius.circular(1.5)),
        accentPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, y, w * 0.045, h * 0.06), const Radius.circular(1.5)),
        violetPaint,
      );
    }

    // Main Hospital Entrance Doors
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.44, baseGroundY - (h * 0.14), w * 0.53, baseGroundY),
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
    );
    canvas.drawRRect(doorRect, accentPaint);

    // Small Heartbeat Pulse Line at the base
    final pulsePath = Path()
      ..moveTo(w * 0.05, baseGroundY + 5)
      ..lineTo(w * 0.40, baseGroundY + 5)
      ..lineTo(w * 0.43, baseGroundY + 1)
      ..lineTo(w * 0.46, baseGroundY + 9)
      ..lineTo(w * 0.49, baseGroundY - 2)
      ..lineTo(w * 0.52, baseGroundY + 5)
      ..lineTo(w * 0.95, baseGroundY + 5);

    canvas.drawPath(
      pulsePath,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = math.max(1.0, h * 0.015)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── PriorX Logo Header ───────────────────────────────────────────────────────
class PriorXLogoHeader extends StatelessWidget {
  final double height;
  final bool showFullSubtitle;
  const PriorXLogoHeader({
    super.key,
    this.height = 42,
    this.showFullSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Image.asset(
        'assets/images/priorx_logo.png',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: height * 0.85,
              height: height * 0.85,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                PhosphorIconsRegular.heartbeat,
                color: Colors.white,
                size: height * 0.5,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PRIORX',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: height * 0.45,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  showFullSubtitle ? 'HEALTH INSURANCE & HOSPITAL CARE' : 'HEALTH INSURANCE',
                  style: TextStyle(
                    color: const Color(0xFF0D9488),
                    fontSize: height * 0.17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Controls Header (Theme & Language Selector) ─────────────────────────
class PriorXTopControlsHeader extends StatelessWidget {
  final bool compact;
  const PriorXTopControlsHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final buttonHeight = compact ? 28.0 : 34.0;
    final iconSize = compact ? 14.0 : 16.0;
    final fontSize = compact ? 11.0 : 12.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme toggle button
        Container(
          width: buttonHeight,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            PhosphorIconsRegular.sun,
            size: iconSize,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(width: 6),
        // Language selector
        Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(PhosphorIconsRegular.globe, size: iconSize, color: const Color(0xFF334155)),
              const SizedBox(width: 5),
              Text(
                'English',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 3),
              Icon(PhosphorIconsRegular.caretDown, size: iconSize - 2, color: const Color(0xFF64748B)),
            ],
          ),
        ),
      ],
    );
  }
}

typedef AuthBrandPanel = PriorXLeftPromotionalSection;

// ─── Left Side: PRIORX Healthcare City Promotional Section ───────────────────
class PriorXLeftPromotionalSection extends StatelessWidget {
  final double vh;
  const PriorXLeftPromotionalSection({super.key, this.vh = 800});

  @override
  Widget build(BuildContext context) {
    final isCompact = vh < 750;
    final isShort = vh < 680;

    final headlineSize = isShort ? 32.0 : (isCompact ? 38.0 : 44.0);
    final descSize = isShort ? 13.5 : (isCompact ? 14.5 : 16.0);
    final cardGap = isShort ? 8.0 : (isCompact ? 12.0 : 16.0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: UnconstrainedBox(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640),
          padding: EdgeInsets.only(
            left: isCompact ? 16 : 28,
            top: isCompact ? 12 : 20,
            right: isCompact ? 16 : 24,
            bottom: isCompact ? 12 : 20,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top PRIORX Brand Header
            const PriorXLogoHeader(height: 48, showFullSubtitle: true)
                .animate()
                .fadeIn(duration: 400.ms),

            SizedBox(height: isShort ? 14 : (isCompact ? 20 : 26)),

            // Main Large Healthcare Headline
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                  letterSpacing: -0.9,
                ),
                children: [
                  const TextSpan(
                    text: 'Care today.\n',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                  TextSpan(
                    text: 'Covered ',
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 180.0, 40.0)),
                    ),
                  ),
                  const TextSpan(
                    text: 'always.',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 500.ms),

            SizedBox(height: isShort ? 8 : (isCompact ? 10 : 14)),

            // Supporting Subtitle Text
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Text(
                'Smart health insurance plans that put you and your family first. Sub-second clinical approvals powered by AI.',
                style: TextStyle(
                  color: const Color(0xFF475569),
                  fontSize: descSize,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 500.ms),

            SizedBox(height: cardGap),

            // 2 x 2 Feature Cards Grid
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FeatureCard(
                    icon: PhosphorIconsRegular.shieldCheck,
                    title: 'Health Coverage',
                    subtitle: 'Comprehensive plans for every need',
                    compact: isCompact,
                  ),
                  _FeatureCard(
                    icon: PhosphorIconsRegular.usersThree,
                    title: 'Family Protection',
                    subtitle: 'Secure your loved ones\' future',
                    compact: isCompact,
                  ),
                  _FeatureCard(
                    icon: PhosphorIconsRegular.lightning,
                    title: 'Cashless Claims',
                    subtitle: 'Hassle-free & instant settlement',
                    compact: isCompact,
                  ),
                  _FeatureCard(
                    icon: PhosphorIconsRegular.headset,
                    title: '24/7 Support',
                    subtitle: 'We\'re here for you, always',
                    compact: isCompact,
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

            SizedBox(height: cardGap),

            // Lower Left Healthcare Graphic Visual with Location Pin & City Map
            _HealthcareCityMapGraphic(
              width: isCompact ? 440 : 490,
              height: isShort ? 150 : (isCompact ? 175 : 195),
            ).animate(delay: 250.ms).fadeIn(duration: 600.ms),

            SizedBox(height: isShort ? 8 : (isCompact ? 10 : 12)),

            // Bottom Badge: "Healthcare connected to you."
            const _ConnectedHealthcareBadge()
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    ),
  );
}
}

// ─── 2x2 Feature Card ────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 220 : 240,
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: compact ? 18 : 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontSize: compact ? 12.5 : 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: compact ? 10 : 11,
                    height: 1.2,
                  ),
                  maxLines: 2,
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

// ─── Healthcare City Map & Grid Illustration Graphic ─────────────────────────
class _HealthcareCityMapGraphic extends StatelessWidget {
  final double width;
  final double height;

  const _HealthcareCityMapGraphic({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Ambient soft radial glow
          Container(
            width: width * 0.8,
            height: height * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFCCFBF1).withOpacity(0.5),
                  const Color(0xFFE0F2FE).withOpacity(0.3),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Map Grid Background & Skyline Vector Painter
          Positioned.fill(
            child: CustomPaint(
              size: Size(width, height),
              painter: _HealthcareCitySkylinePainter(),
            ),
          ),

          // Floating Healthcare Icon 1: Stethoscope / Medical Care (Top Left)
          Positioned(
            top: height * 0.08,
            left: width * 0.06,
            child: const _FloatingHealthIconBadge(
              icon: PhosphorIconsRegular.stethoscope,
              label: 'Care',
              accentColor: Color(0xFF0D9488),
            ),
          ),

          // Floating Healthcare Icon 2: Shield / Protection (Top Right)
          Positioned(
            top: height * 0.06,
            right: width * 0.06,
            child: const _FloatingHealthIconBadge(
              icon: PhosphorIconsRegular.shieldCheck,
              label: 'Protection',
              accentColor: Color(0xFF2563EB),
            ),
          ),

          // Floating Healthcare Icon 3: Clipboard / Records (Mid Left)
          Positioned(
            top: height * 0.46,
            left: width * 0.01,
            child: const _FloatingHealthIconBadge(
              icon: PhosphorIconsRegular.clipboardText,
              label: 'Records',
              accentColor: Color(0xFF7C3AED),
            ),
          ),

          // Floating Healthcare Icon 4: Family / Patients (Mid Right)
          Positioned(
            top: height * 0.44,
            right: width * 0.01,
            child: const _FloatingHealthIconBadge(
              icon: PhosphorIconsRegular.usersThree,
              label: 'Family',
              accentColor: Color(0xFF10B981),
            ),
          ),

          // MANDATORY Large Teal Location Pin standing in lower-middle area
          Positioned(
            left: (width / 2) - 20,
            top: height * 0.38,
            child: const _LargeHealthcareLocationPin(),
          ),
        ],
      ),
    );
  }
}

// ─── Healthcare City Vector Skyline Painter ──────────────────────────────────
class _HealthcareCitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.82;

    // Paints
    final gridLinePaint = Paint()
      ..color = const Color(0xFFCBD5E1).withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final baseLinePaint = Paint()
      ..color = const Color(0xFF0D9488).withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final buildingLight = Paint()..color = const Color(0xFFF1F5F9);
    final buildingMedium = Paint()..color = const Color(0xFFE2E8F0);
    final buildingMain = Paint()..color = const Color(0xFFE0F2FE);
    final tealAccent = Paint()..color = const Color(0xFF0D9488);
    final blueAccent = Paint()..color = const Color(0xFF2563EB);
    final treePaint = Paint()..color = const Color(0xFF34D399);

    final lineOutline = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Isometric Base Grid Map Lines
    for (double i = -0.2; i <= 1.2; i += 0.15) {
      canvas.drawLine(
        Offset(w * i, h),
        Offset(w * (i + 0.3), groundY - (h * 0.1)),
        gridLinePaint,
      );
      canvas.drawLine(
        Offset(w * (i + 0.3), h),
        Offset(w * i, groundY - (h * 0.1)),
        gridLinePaint,
      );
    }

    // Ground Baseline
    canvas.drawLine(Offset(w * 0.05, groundY), Offset(w * 0.95, groundY), baseLinePaint);

    // 2. Connector Lines to Floating Icons
    final connectorPaint = Paint()
      ..color = const Color(0xFF0D9488).withOpacity(0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Connector 1 (Top Left)
    final path1 = Path()
      ..moveTo(w * 0.42, h * 0.30)
      ..quadraticBezierTo(w * 0.25, h * 0.18, w * 0.18, h * 0.14);
    canvas.drawPath(path1, connectorPaint);

    // Connector 2 (Top Right)
    final path2 = Path()
      ..moveTo(w * 0.58, h * 0.30)
      ..quadraticBezierTo(w * 0.75, h * 0.18, w * 0.82, h * 0.12);
    canvas.drawPath(path2, connectorPaint);

    // Connector 3 (Mid Left)
    final path3 = Path()
      ..moveTo(w * 0.38, h * 0.55)
      ..quadraticBezierTo(w * 0.22, h * 0.48, w * 0.12, h * 0.50);
    canvas.drawPath(path3, connectorPaint);

    // Connector 4 (Mid Right)
    final path4 = Path()
      ..moveTo(w * 0.62, h * 0.55)
      ..quadraticBezierTo(w * 0.78, h * 0.48, w * 0.88, h * 0.48);
    canvas.drawPath(path4, connectorPaint);

    // 3. Buildings
    // Building Left (Clinic Wing)
    final bLeft = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.15, h * 0.42, w * 0.30, groundY),
      const Radius.circular(4),
    );
    canvas.drawRRect(bLeft, buildingLight);
    canvas.drawRRect(bLeft, lineOutline);

    // Windows Left
    for (double y = h * 0.48; y < groundY - 8; y += 12) {
      canvas.drawRect(Rect.fromLTWH(w * 0.18, y, w * 0.035, 6), lineOutline);
      canvas.drawRect(Rect.fromLTWH(w * 0.24, y, w * 0.035, 6), lineOutline);
    }

    // Building Right (Specialty Hospital Pavilion)
    final bRight = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.68, h * 0.36, w * 0.85, groundY),
      const Radius.circular(4),
    );
    canvas.drawRRect(bRight, buildingMedium);
    canvas.drawRRect(bRight, lineOutline);

    // Windows Right
    for (double y = h * 0.42; y < groundY - 8; y += 13) {
      canvas.drawRect(Rect.fromLTWH(w * 0.72, y, w * 0.04, 7), lineOutline);
      canvas.drawRect(Rect.fromLTWH(w * 0.78, y, w * 0.04, 7), lineOutline);
    }

    // 4. MAIN CENTRAL HOSPITAL CENTERPIECE
    final mainLeft = w * 0.33;
    final mainRight = w * 0.66;
    final mainTop = h * 0.20;

    final mainBuilding = RRect.fromRectAndCorners(
      Rect.fromLTRB(mainLeft, mainTop, mainRight, groundY),
      topLeft: const Radius.circular(6),
      topRight: const Radius.circular(6),
    );
    canvas.drawRRect(mainBuilding, buildingMain);
    canvas.drawRRect(mainBuilding, baseLinePaint);

    // Center Tower Dome / Helipad Spire Roof Feature
    final towerLeft = w * 0.43;
    final towerRight = w * 0.56;
    final towerTop = h * 0.09;
    final towerRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(towerLeft, towerTop, towerRight, mainTop),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(towerRRect, Paint()..color = Colors.white);
    canvas.drawRRect(towerRRect, lineOutline);

    // Prominent Hospital "H" Symbol Badge on Central Building
    final hBadgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.455, h * 0.22, w * 0.08, h * 0.12),
      const Radius.circular(4),
    );
    canvas.drawRRect(hBadgeRect, tealAccent);

    // Draw White "H" Hospital Text inside badge
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'H',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((w * 0.495) - (textPainter.width / 2), (h * 0.28) - (textPainter.height / 2)),
    );

    // Glass Windows Grid on Main Hospital
    for (double y = mainTop + (h * 0.16); y < groundY - (h * 0.14); y += 14) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.36, y, w * 0.045, 7), const Radius.circular(1.5)),
        blueAccent,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.44, y, w * 0.045, 7), const Radius.circular(1.5)),
        tealAccent,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.52, y, w * 0.045, 7), const Radius.circular(1.5)),
        blueAccent,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.59, y, w * 0.045, 7), const Radius.circular(1.5)),
        tealAccent,
      );
    }

    // Hospital Entrance Doors
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.46, groundY - 18, w * 0.53, groundY),
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
    );
    canvas.drawRRect(doorRect, tealAccent);

    // Green Trees & Foliage Accents
    canvas.drawCircle(Offset(w * 0.12, groundY - 6), 7, treePaint);
    canvas.drawCircle(Offset(w * 0.31, groundY - 8), 9, treePaint);
    canvas.drawCircle(Offset(w * 0.67, groundY - 8), 9, treePaint);
    canvas.drawCircle(Offset(w * 0.88, groundY - 6), 7, treePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Large Teal Healthcare Location Pin ──────────────────────────────────────
class _LargeHealthcareLocationPin extends StatelessWidget {
  const _LargeHealthcareLocationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 52,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(40, 52),
            painter: _LocationPinPainter(),
          ),
          Positioned(
            top: 8,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                PhosphorIconsRegular.firstAid,
                size: 11,
                color: Color(0xFF0D9488),
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut);
  }
}

class _LocationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, h);
    path.cubicTo(w * 0.1, h * 0.55, 0, h * 0.35, 0, w * 0.5);
    path.arcTo(
      Rect.fromLTWH(0, 0, w, w),
      math.pi,
      math.pi,
      false,
    );
    path.cubicTo(w, h * 0.35, w * 0.9, h * 0.55, w * 0.5, h);
    path.close();

    final pinGradient = const LinearGradient(
      colors: [Color(0xFF0D9488), Color(0xFF10B981)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint = Paint()
      ..shader = pinGradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Floating Circular Health Icon Badge ─────────────────────────────────────
class _FloatingHealthIconBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;

  const _FloatingHealthIconBadge({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 12, color: accentColor),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
  }
}

// ─── Bottom Connected Healthcare Badge ────────────────────────────────────────
class _ConnectedHealthcareBadge extends StatelessWidget {
  const _ConnectedHealthcareBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFCCFBF1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFCCFBF1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsRegular.mapPin,
              size: 13,
              color: Color(0xFF0D9488),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Healthcare connected to you.',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Trust Indicators Widget ──────────────────────────────────────────────────
class PriorXTrustIndicators extends StatelessWidget {
  final bool compact;
  const PriorXTrustIndicators({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TrustBadge(icon: PhosphorIconsRegular.shieldCheck, label: 'Trusted & Secure', compact: compact),
          SizedBox(width: compact ? 6 : 10),
          _TrustBadge(icon: PhosphorIconsRegular.lightning, label: 'Quick Claim', compact: compact),
          SizedBox(width: compact ? 6 : 10),
          _TrustBadge(icon: PhosphorIconsRegular.fileText, label: '100% Paperless', compact: compact),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;

  const _TrustBadge({required this.icon, required this.label, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 12 : 14, color: const Color(0xFF10B981)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: compact ? 9 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Shared PRIORX Role Selector Widget (Button-Based Role Selection) ─────────
class PriorXRoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleSelected;
  final bool compact;
  final String? labelText;

  const PriorXRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
    this.compact = false,
    this.labelText,
  });

  static const List<(String, UserRole, IconData)> _roles = [
    ('Doctor', UserRole.doctor, PhosphorIconsRegular.stethoscope),
    ('Patient', UserRole.patient, PhosphorIconsRegular.user),
    ('Insurance Reviewer', UserRole.insuranceReviewer, PhosphorIconsRegular.shieldCheck),
    ('Hospital Staff', UserRole.hospitalStaff, PhosphorIconsRegular.hospital),
    ('Hospital Admin', UserRole.adminHospital, PhosphorIconsRegular.briefcase),
    ('Administrator', UserRole.administrator, PhosphorIconsRegular.crown),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null && labelText!.isNotEmpty) ...[
          Text(
            labelText!,
            style: TextStyle(
              color: const Color(0xFF334155),
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 3 : 5),
        ],
        Wrap(
          spacing: compact ? 5 : 6,
          runSpacing: compact ? 5 : 6,
          children: _roles.map((item) {
            final (label, role, icon) = item;
            final isSelected = role == selectedRole;
            return InkWell(
              onTap: () => onRoleSelected(role),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 10,
                  vertical: compact ? 5 : 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: compact ? 13 : 14,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                        fontSize: compact ? 10.5 : 11.5,
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
    );
  }
}
