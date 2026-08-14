import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../models/user_role.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/utils/platform_helper.dart';
import '../../../core/providers/authorizations_provider.dart';
import '../../../core/utils/patient_portal_helper.dart';

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user?.role == UserRole.patient) {
      return _buildPatientPortalDashboard(context);
    }

    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isMobile ? _buildMobileDashboard(context) : _buildDesktopDashboard(context),
      ),
    );
  }

  // ─── Desktop Dashboard (Mockup Left/Right Panels) ───────────────────────────
  Widget _buildDesktopDashboard(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Left Content Column
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(PhosphorIconsRegular.magnifyingGlass, color: Colors.grey.shade500, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              "Search anything here...",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Action Icons
                    Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.neutral50,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Icon(PhosphorIconsRegular.bell, color: AppColors.mockupDark, size: 20),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Profile Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.mockupPurpleLight,
                          child: const Text(
                            "RF",
                            style: TextStyle(
                              color: AppColors.mockupPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Robert Fox',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.mockupDark),
                            ),
                            Text(
                              user?.role.displayName ?? 'Surgeon',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Welcome Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Good morning, Dr.Robert!",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.mockupDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "☀️",
                              style: TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Access a summary of key metrics and patient care status.",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                    // Export button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.mockupTeal,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mockupTeal.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(PhosphorIconsRegular.downloadSimple, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Export data  .xls",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Stat Cards Row (Total Patients & Total Appointments)
                Row(
                  children: [
                    Expanded(
                      child: _buildDesktopStatCard(
                        title: "Total patients",
                        value: "58",
                        trend: "+13%",
                        trendColor: AppColors.mockupTeal,
                        isUp: true,
                        sparkHeights: [8, 12, 6, 18, 22, 10, 15, 28, 20, 25, 14],
                        trendMessage: "Patients coming increased by 13%\nin last 7 days",
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildDesktopStatCard(
                        title: "Total appointments",
                        value: "340",
                        trend: "-5%",
                        trendColor: Colors.red.shade400,
                        isUp: false,
                        sparkHeights: [25, 20, 18, 22, 14, 12, 10, 8, 6, 8, 4],
                        trendMessage: "Decrease in appointments by 5%\nin the last 7 days",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Consultations stacked bar chart
                Container(
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.mockupCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: _ConsultationsChart(),
                ),

                const SizedBox(height: 20),

                // Bottom row: Surgeries Performed & Satisfaction Rate
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 220,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.mockupCardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: _buildSurgeriesPerformed(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 220,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.mockupCardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: _buildSatisfactionRate(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Divider line
        Container(
          width: 1,
          color: Colors.grey.shade100,
          height: double.infinity,
        ),
        // Right Panel (Calendar and Appointments List)
        Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DesktopCalendar(),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  "Today's appointments",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.mockupDark),
                ),
                const SizedBox(height: 16),
                _buildAppointmentsList(),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── Stat Card Widget ───────────────────────────────────────────────────────
  Widget _buildDesktopStatCard({
    required String title,
    required String value,
    required String trend,
    required Color trendColor,
    required bool isUp,
    required List<double> sparkHeights,
    required String trendMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mockupCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.calendar, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    const Text("Week", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Value and trend indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.mockupDark, letterSpacing: -1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trend,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor),
                      ),
                      Icon(
                        isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                        color: trendColor,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // mini spark bar and message Row
                  Row(
                    children: [
                      _MiniBarChart(heights: sparkHeights),
                      const SizedBox(width: 10),
                      Text(
                        trendMessage,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, height: 1.2),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Surgeries Performed widget ──────────────────────────────────────────────
  Widget _buildSurgeriesPerformed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Surgeries performed",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendar, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  const Text("Week", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              "24",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.mockupDark),
            ),
            const SizedBox(width: 6),
            Text(
              "-5%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade400),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: Colors.red.shade400, size: 16),
          ],
        ),
        const Spacer(),
        // Sparklines or grid columns for surgeries
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(24, (index) {
            final h = (index % 3 == 0) ? 22.0 : ((index % 2 == 0) ? 14.0 : 8.0);
            return Container(
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: index < 16 ? AppColors.mockupPurple : AppColors.mockupPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        // Breakdown Row
        Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.mockupPurple, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text("Elective", style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(width: 8),
            const Text("16", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mockupDark)),
            const SizedBox(width: 24),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.mockupPurple.withOpacity(0.3), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text("Emergency", style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(width: 8),
            const Text("8", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mockupDark)),
          ],
        ),
      ],
    );
  }

  // ─── Satisfaction Rate widget ───────────────────────────────────────────────
  Widget _buildSatisfactionRate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Satisfaction rate",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendar, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  const Text("Week", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: const [
            Text(
              "92%",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.mockupDark),
            ),
            SizedBox(width: 6),
            Text(
              "+1%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mockupTeal),
            ),
            Icon(Icons.arrow_drop_up_rounded, color: AppColors.mockupTeal, size: 16),
          ],
        ),
        const Spacer(),
        // Bezier satisfaction rate visual
        SizedBox(
          height: 60,
          width: double.infinity,
          child: CustomPaint(
            painter: _SatisfactionPainter(),
          ),
        ),
      ],
    );
  }

  // ─── Desktop Appointments List ──────────────────────────────────────────────
  Widget _buildAppointmentsList() {
    final list = [
      {
        'name': 'Dr. Leslie Alexander',
        'specialty': 'Orthopedic surgeon',
        'date': 'Mar 24',
        'initials': 'LA',
      },
      {
        'name': 'Dr. Jane Cooper',
        'specialty': 'Anesthesiologist',
        'date': 'Mar 24',
        'initials': 'JC',
      },
      {
        'name': 'Dr. Wade Warren',
        'specialty': 'Physiotherapist',
        'date': 'Mar 24',
        'initials': 'WW',
      },
    ];

    return Column(
      children: list.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.mockupPurpleLight,
              child: Text(
                item['initials']!,
                style: const TextStyle(
                  color: AppColors.mockupPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.mockupDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['specialty']!,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendar, size: 10, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    item['date']!,
                    style: const TextStyle(fontSize: 9, color: AppColors.mockupDark, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ─── Mobile Dashboard (Patient App style mockup) ───────────────────────────
  Widget _buildMobileDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.mockupPurpleLight,
                    child: const Text(
                      "GS",
                      style: TextStyle(
                        color: AppColors.mockupPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Good Morning",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        "Gwen Stacy",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.mockupDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  // Bell
                  Stack(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(PhosphorIconsRegular.bell, color: AppColors.mockupDark, size: 18),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Menu
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(PhosphorIconsRegular.list, color: AppColors.mockupDark, size: 18),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Mood Slider Card
          const _MoodSlider(),

          const SizedBox(height: 24),

          // Calendar Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Calendar",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.mockupDark),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("View all >", style: TextStyle(color: AppColors.mockupTeal, fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Horizontal scrollable date picker
          _HorizontalDatePicker(),

          const SizedBox(height: 24),

          // Date Text Header
          const Text(
            "Wednesday, 24 March",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.mockupDark),
          ),

          const SizedBox(height: 16),

          // Timed Appointments Timeline list
          _TimelineAppointments(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ─── Patient Portal Dashboard ──────────────────────────────────────────────
  Widget _buildPatientPortalDashboard(BuildContext context) {
    final patientName = 'Emily Thompson';
    final allAuths = ref.watch(authorizationsProvider);
    final allAppeals = MockDataRepository.instance.appeals
        .where((a) => a.patientName.toLowerCase() == patientName.toLowerCase())
        .toList();
    final patientNotifs = MockDataRepository.instance.notifications;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(PhosphorIconsRegular.pulse, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'PriorX Patient Portal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Text('ET', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left main section
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, Emily!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'UnitedHealthcare PPO Plus · Member ID: UHC-998877',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Manage your healthcare decisions, review prior authorizations, track active appeals, and securely upload clinical files.',
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.05),

                  const SizedBox(height: 28),

                  // Section Title
                  Text(
                    'Your Prior Authorizations & Coverages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  if (allAuths.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(child: Text('No active prior authorization requests found.')),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allAuths.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) => _buildPatientAuthCard(allAuths[idx]),
                    ).animate(delay: 100.ms).fadeIn(),

                  const SizedBox(height: 28),

                  // Section Title: Appeals
                  Text(
                    'Active Appeals Tracker',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  if (allAppeals.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          'No appeals have been filed yet.',
                          style: TextStyle(color: AppColors.textTertiary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allAppeals.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) => _buildPatientAppealCard(allAppeals[idx]),
                    ).animate(delay: 200.ms).fadeIn(),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right sidebar
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Care Team panel
                  _buildCareTeamPanel(),
                  const SizedBox(height: 24),
                  // Upload Center panel
                  _buildPatientUploadVault(patientName),
                  const SizedBox(height: 24),
                  // Notification Box
                  _buildPatientNotifBox(patientNotifs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Patient: Auth Request Card ───
  Widget _buildPatientAuthCard(AuthorizationRequest auth) {
    final isRejected = auth.status == AuthorizationStatus.rejected;
    final isApproved = auth.status == AuthorizationStatus.approved;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isRejected 
              ? AppColors.error.withOpacity(0.3) 
              : (isApproved ? AppColors.success.withOpacity(0.3) : AppColors.border),
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: auth.status.bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(auth.status.icon, size: 18, color: auth.status.color),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.drugName ?? auth.procedureDescription,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        'Requested by: ${auth.requestingDoctorName}',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: auth.status.bgColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  auth.status.label,
                  style: TextStyle(color: auth.status.color, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diagnosis', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(auth.diagnosisDescription, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Insurance Plan', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(auth.insurancePlanName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isRejected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(PhosphorIconsRegular.warningOctagon, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Coverage Rejected by Insurance Company',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Denial Code: ${auth.policyClauseCited ?? "Standard Step Therapy Policy"}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPatientDenialExplanation(context, auth),
                      icon: const Icon(PhosphorIconsRegular.chatCircleText, size: 14),
                      label: const Text('Understand Rejection & View Next Steps', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Patient: Show Denial Explanation Dialog ───
  void _showPatientDenialExplanation(BuildContext ctx, AuthorizationRequest auth) {
    final explanation = PatientPortalExplanation.generate(auth, null);

    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(PhosphorIconsRegular.chatCircleText, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            const Text('Explanation of Benefit Decision', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  explanation.title,
                  style: Theme.of(dialogCtx).textTheme.titleSmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                
                // Plain language description
                Text(
                  explanation.description,
                  style: const TextStyle(height: 1.5, color: AppColors.textPrimary),
                ),

                const Divider(height: 32),

                // Next steps
                Text('What Happens Next (Your Steps):', style: Theme.of(dialogCtx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...explanation.nextSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                )),

                const Divider(height: 32),

                // Layperson Glossary
                Text('Understand Medical Terms:', style: Theme.of(dialogCtx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...explanation.glossary.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text(entry.value, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  // ─── Patient: Appeal Tracking Card ───
  Widget _buildPatientAppealCard(AppealCase appeal) {
    final status = appeal.status;
    final isActionRequired = status == AppealStatus.underReview;

    // Timeline steps definition
    final steps = [
      {'title': 'Appeal Submitted', 'done': true, 'subtitle': 'Filed on ${DateFormat('MMM d').format(appeal.filedAt)}'},
      {
        'title': 'Insurer Clinical Review', 
        'done': status == AppealStatus.underReview || status == AppealStatus.overturned || status == AppealStatus.upheld,
        'subtitle': isActionRequired ? 'Action Required: Logs Requested' : 'Insurer reviewing details'
      },
      {
        'title': 'Final Decision', 
        'done': status == AppealStatus.overturned || status == AppealStatus.upheld,
        'subtitle': status == AppealStatus.overturned 
            ? 'Approved (Decision Overturned)' 
            : (status == AppealStatus.upheld ? 'Rejected (Denial Upheld)' : 'Awaiting reviewer final outcome')
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: isActionRequired ? AppColors.warning.withOpacity(0.3) : AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appeal Case #${appeal.appealNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    'Reference Auth: ${appeal.authNumber}',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActionRequired 
                      ? AppColors.warning.withOpacity(0.12)
                      : (status == AppealStatus.overturned 
                          ? AppColors.success.withOpacity(0.12) 
                          : (status == AppealStatus.upheld ? AppColors.error.withOpacity(0.12) : AppColors.primary.withOpacity(0.12))),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  status.statusLabel,
                  style: TextStyle(
                    color: isActionRequired 
                        ? AppColors.warning 
                        : (status == AppealStatus.overturned 
                            ? AppColors.success 
                            : (status == AppealStatus.upheld ? AppColors.error : AppColors.primary)), 
                    fontSize: 10, 
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Horizontal Progress steps
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (i) {
              final step = steps[i];
              final isDone = step['done'] as bool;
              final subtitle = step['subtitle'] as String;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i == 0 ? Colors.transparent : (isDone ? AppColors.primary : AppColors.neutral200),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primary : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: isDone ? AppColors.primary : AppColors.neutral300, width: 2),
                          ),
                          child: Center(
                            child: Icon(
                              isDone ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                              size: 14,
                              color: isDone ? Colors.white : AppColors.neutral300,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: i == steps.length - 1 ? Colors.transparent : (steps[i+1]['done'] as bool ? AppColors.primary : AppColors.neutral200),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                        color: isDone ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 9, color: AppColors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),

          if (isActionRequired) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Insurer Action Required: Missing Clinical Logs',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.warning, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appeal.rejectionReason ?? 'The medical reviewer has requested conservative therapy documentation (e.g. proof of step therapy medication or physical therapy trials).',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showProvideLogsDialog(appeal),
                      icon: const Icon(PhosphorIconsRegular.upload, size: 14),
                      label: const Text('Provide Clinical Documents / Logs', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Patient: Provide logs form ───
  void _showProvideLogsDialog(AppealCase appeal) {
    final logController = TextEditingController();
    final fileController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Submit Requested Clinical Records', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Provide details of your conservative treatments or therapy logs to resolve the insurer information request.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: logController,
                decoration: const InputDecoration(
                  labelText: 'Treatment / Conservative Therapy Logs Description',
                  hintText: 'e.g. Completed 6 weeks physical therapy log for chronic migraine prevention.',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please describe the logs' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fileController,
                decoration: const InputDecoration(
                  labelText: 'File Name Attachment Reference',
                  hintText: 'e.g. physical_therapy_preventative_logs_Q2.pdf',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please specify file reference name' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';

                final docName = fileController.text.trim();

                // Update appeal case
                final idx = MockDataRepository.instance.appeals.indexWhere((a) => a.id == appeal.id);
                if (idx != -1) {
                  final old = MockDataRepository.instance.appeals[idx];
                  MockDataRepository.instance.appeals[idx] = AppealCase(
                    id: old.id,
                    appealNumber: old.appealNumber,
                    authorizationId: old.authorizationId,
                    authNumber: old.authNumber,
                    patientName: old.patientName,
                    filedById: old.filedById,
                    filedByName: old.filedByName,
                    status: AppealStatus.submitted, // return status to submitted
                    filedAt: old.filedAt,
                    groundsForAppeal: old.groundsForAppeal + '\n\nPatient Uploaded Info: ' + logController.text.trim(),
                    supportingEvidence: old.supportingEvidence,
                    aiSuccessProbability: old.aiSuccessProbability,
                    aiProbabilityLow: old.aiProbabilityLow,
                    aiProbabilityHigh: old.aiProbabilityHigh,
                    draftAppealLetter: old.draftAppealLetter,
                    documentIds: [...old.documentIds, docName],
                  );
                }

                // Log audit trail
                MockDataRepository.instance.auditLogs.add(
                  AuditLogEntry(
                    id: 'log-$randomId',
                    action: 'appeal.document_uploaded',
                    actorId: 'usr-005',
                    actorName: 'Emily Thompson',
                    actorRole: 'Patient',
                    resourceId: appeal.id,
                    resourceType: 'AppealCase',
                    description: 'Patient uploaded documentation: $docName for Appeal #${appeal.appealNumber}',
                    timestamp: DateTime.now(),
                    entryHash: 'e${randomId}h',
                    previousHash: prevHash,
                    ipAddress: '192.168.1.105',
                    metadata: {'file_name': docName},
                  ),
                );

                // Add notification
                MockDataRepository.instance.notifications.insert(
                  0,
                  AppNotification(
                    id: 'notif-$randomId',
                    title: 'Medical Documents Submitted',
                    message: 'Patient Emily Thompson submitted additional file: $docName.',
                    type: NotificationType.appeal,
                    isRead: false,
                    resourceId: appeal.id,
                    resourceType: 'AppealCase',
                    createdAt: DateTime.now(),
                  ),
                );

                Navigator.pop(dialogCtx);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Document "$docName" has been submitted successfully to insurer review queue.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Submit Documents'),
          ),
        ],
      ),
    );
  }

  // ─── Patient: Care Team Panel ───
  Widget _buildCareTeamPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Medical Care Team', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 12),
          _careTeamMember('Dr. Michael Johnson', 'Primary Treating Neurologist', PhosphorIconsRegular.userCircle),
          const SizedBox(height: 10),
          _careTeamMember('Sarah Jenkins', 'Clinical Review Coordinator', PhosphorIconsRegular.userCircleGear),
          const SizedBox(height: 10),
          _careTeamMember('UnitedHealthcare Support', 'Insurance Payer Representative', PhosphorIconsRegular.shieldCheck),
        ],
      ),
    );
  }

  Widget _careTeamMember(String name, String role, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              Text(role, style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Patient: Documents vault panel ───
  Widget _buildPatientUploadVault(String patientName) {
    // Collect document IDs currently in mock data matching Emily
    final files = ['emily_migraine_history_2023.pdf', 'er_billing_summary.pdf'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Medical Documents Vault', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  final filenameController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Mock Upload Document', style: TextStyle(fontWeight: FontWeight.w700)),
                      content: TextFormField(
                        controller: filenameController,
                        decoration: const InputDecoration(
                          labelText: 'File Name',
                          hintText: 'e.g. lab_results_october.pdf',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            if (filenameController.text.trim().isNotEmpty) {
                              final name = filenameController.text.trim();
                              // Log audit trail
                              final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                              final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                                  ? MockDataRepository.instance.auditLogs.last.entryHash 
                                  : 'f9e2d1c6b3a8';

                              MockDataRepository.instance.auditLogs.add(
                                AuditLogEntry(
                                  id: 'log-$randomId',
                                  action: 'patient.document_uploaded',
                                  actorId: 'usr-005',
                                  actorName: 'Emily Thompson',
                                  actorRole: 'Patient',
                                  resourceId: 'pat-009',
                                  resourceType: 'Patient',
                                  description: 'Patient Emily Thompson uploaded file: $name to their document vault.',
                                  timestamp: DateTime.now(),
                                  entryHash: 'e${randomId}h',
                                  previousHash: prevHash,
                                  ipAddress: '192.168.1.105',
                                  metadata: {'file_name': name},
                                ),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Document "$name" uploaded to vault successfully.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('Upload'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...files.map((file) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            elevation: 0,
            color: AppColors.neutral50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: ListTile(
              dense: true,
              leading: const Icon(PhosphorIconsRegular.filePdf, size: 18, color: AppColors.neutral600),
              title: Text(file, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
              trailing: const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Patient: Notification Box panel ───
  Widget _buildPatientNotifBox(List<AppNotification> notifs) {
    // Show only the 3 most recent notifications for simplicity
    final displayNotifs = notifs.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Portal Alerts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 12),
          if (displayNotifs.isEmpty)
            const Text('No recent alerts.', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontStyle: FontStyle.italic))
          else
            ...displayNotifs.map((notif) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    notif.type == NotificationType.appeal ? PhosphorIconsRegular.gavel : PhosphorIconsRegular.bell, 
                    size: 16, 
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                        Text(notif.message, style: TextStyle(color: AppColors.textSecondary, fontSize: 10, height: 1.2)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

// ─── Mini Bar Chart component ────────────────────────────────────────────────
class _MiniBarChart extends StatelessWidget {
  final List<double> heights;
  const _MiniBarChart({required this.heights});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((h) => Container(
        width: 4,
        height: h,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(
          color: AppColors.mockupPurple,
          borderRadius: BorderRadius.circular(1.5),
        ),
      )).toList(),
    );
  }
}

// ─── Satisfaction Rate Bezier Custom Painter ─────────────────────────────────
class _SatisfactionPainter extends CustomPainter {
  final List<double> points = [20, 35, 25, 45, 40, 55, 48, 60, 52];
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mockupPurple
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.mockupPurple.withOpacity(0.15),
          AppColors.mockupPurple.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final double dx = size.width / (points.length - 1);
    
    path.moveTo(0, size.height - (points[0] / 100 * size.height));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (points[0] / 100 * size.height));

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * dx;
      final y1 = size.height - (points[i] / 100 * size.height);
      final x2 = (i + 1) * dx;
      final y2 = size.height - (points[i + 1] / 100 * size.height);
      
      final cx1 = x1 + dx / 2;
      final cy1 = y1;
      final cx2 = x1 + dx / 2;
      final cy2 = y2;

      path.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
      fillPath.cubicTo(cx1, cy1, cx2, cy2, x2, y2);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots at intervals
    final dotPaint = Paint()..color = AppColors.mockupPurple..style = PaintingStyle.fill;
    final dotOuterPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    for (int i = 0; i < points.length; i++) {
      if (i % 2 == 0) {
        final x = i * dx;
        final y = size.height - (points[i] / 100 * size.height);
        canvas.drawCircle(Offset(x, y), 5, dotOuterPaint);
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Desktop Calendar Grid ───────────────────────────────────────────────────
class _DesktopCalendar extends StatefulWidget {
  @override
  State<_DesktopCalendar> createState() => _DesktopCalendarState();
}

class _DesktopCalendarState extends State<_DesktopCalendar> {
  int _selectedDay = 14;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = 31;
    final firstDayOffset = 5; // Saturday start March 2025
    final weekdayLabels = ['Moe', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 16),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Text(
              "March, 2025",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.mockupDark),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 16),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdayLabels.map((w) => Expanded(
            child: Center(
              child: Text(
                w,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + firstDayOffset,
          itemBuilder: (context, index) {
            if (index < firstDayOffset) {
              return const SizedBox.shrink();
            }
            final day = index - firstDayOffset + 1;
            final isSelected = day == _selectedDay;
            final isHighlight = [1, 9, 14, 22, 23, 29, 30].contains(day);

            return InkWell(
              onTap: () => setState(() => _selectedDay = day),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.mockupPurple
                      : (isHighlight ? AppColors.mockupPurpleLight : Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    "$day",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: (isSelected || isHighlight) ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isHighlight ? AppColors.mockupPurple : AppColors.mockupDark),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Consultations Segmented Stacked Bar Chart ───────────────────────────────
class _ConsultationsChart extends StatefulWidget {
  @override
  State<_ConsultationsChart> createState() => _ConsultationsChartState();
}

class _ConsultationsChartState extends State<_ConsultationsChart> {
  int _hoveredIndex = 2;

  final List<Map<String, dynamic>> _chartData = [
    {'day': 'Mon', 'male': 4, 'female': 3},
    {'day': 'Tue', 'male': 5, 'female': 4},
    {'day': 'Wed', 'male': 5, 'female': 5},
    {'day': 'Thu', 'male': 3, 'female': 2},
    {'day': 'Fri', 'male': 6, 'female': 4},
    {'day': 'Sat', 'male': 2, 'female': 1},
    {'day': 'Sun', 'male': 1, 'female': 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Consultations",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.mockupDark),
            ),
            const Spacer(),
            // Legend
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.mockupTeal, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text("Male", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.mockupPurple, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text("Female", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.calendar, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  const Text("Week", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Chart Area
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Grid lines
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => Container(
                  height: 1,
                  color: Colors.grey.shade100,
                )),
              ),
              // Columns
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _chartData.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final data = entry.value;
                    final maleVal = data['male'] as int;
                    final femaleVal = data['female'] as int;
                    final day = data['day'] as String;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _hoveredIndex = idx),
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Male Blocks (Teal)
                                ...List.generate(maleVal, (i) => Container(
                                  width: 20,
                                  height: 10,
                                  margin: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.mockupTeal,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )),
                                // Female Blocks (Purple)
                                ...List.generate(femaleVal, (i) => Container(
                                  width: 20,
                                  height: 10,
                                  margin: const EdgeInsets.only(bottom: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.mockupPurple,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                )),
                                const SizedBox(height: 8),
                                Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: _hoveredIndex == idx ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            // Tooltip Box above Wednesday/Selected
                            if (_hoveredIndex == idx)
                              Positioned(
                                bottom: (maleVal + femaleVal) * 12.0 + 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$day, 26",
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.mockupTeal, shape: BoxShape.circle)),
                                          const SizedBox(width: 4),
                                          Text("Male $maleVal", style: const TextStyle(color: Colors.white70, fontSize: 9)),
                                          const SizedBox(width: 10),
                                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.mockupPurple, shape: BoxShape.circle)),
                                          const SizedBox(width: 4),
                                          Text("Female $femaleVal", style: const TextStyle(color: Colors.white70, fontSize: 9)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Mobile Interactive Mood Slider ──────────────────────────────────────────
class _MoodSlider extends StatefulWidget {
  const _MoodSlider();

  @override
  State<_MoodSlider> createState() => _MoodSliderState();
}

class _MoodSliderState extends State<_MoodSlider> {
  double _value = 2.0;

  final List<String> _emojis = ['😢', '😕', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mockupTealLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mockupTeal.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How are you feeling?",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.mockupDark),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isSelected = index == _value.round();
              return AnimatedScale(
                scale: isSelected ? 1.4 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    _emojis[index],
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: AppColors.mockupTeal,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppColors.mockupTeal,
              overlayColor: AppColors.mockupTeal.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: 4,
              divisions: 4,
              onChanged: (val) {
                setState(() => _value = val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile Horizontal Date Picker ───────────────────────────────────────────
class _HorizontalDatePicker extends StatefulWidget {
  @override
  State<_HorizontalDatePicker> createState() => _HorizontalDatePickerState();
}

class _HorizontalDatePickerState extends State<_HorizontalDatePicker> {
  int _selectedDayIndex = 2; // Wednesday (24) default

  final List<Map<String, String>> _days = [
    {'day': 'Mon', 'date': '22'},
    {'day': 'Tue', 'date': '23'},
    {'day': 'Wed', 'date': '24'},
    {'day': 'Thu', 'date': '25'},
    {'day': 'Fri', 'date': '26'},
    {'day': 'Sat', 'date': '27'},
    {'day': 'Sun', 'date': '28'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _days.asMap().entries.map((entry) {
          final idx = entry.key;
          final d = entry.value;
          final isSelected = idx == _selectedDayIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mockupPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    d['day']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : Colors.grey,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d['date']!,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.white : AppColors.mockupDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Mobile Timeline Appointments list ───────────────────────────────────────
class _TimelineAppointments extends StatelessWidget {
  final List<Map<String, dynamic>> appointments = [
    {
      'time': '09:00',
      'apt': {
        'name': 'Dr. Leslie Alexander',
        'specialty': 'Orthopedic surgeon',
        'timeText': 'Wednesday, 24 March · 09:30 AM',
        'initials': 'LA',
      }
    },
    {
      'time': '10:00',
      'apt': null,
    },
    {
      'time': '11:00',
      'apt': {
        'name': 'Dr. Wade Warren',
        'specialty': 'Physiotherapist',
        'timeText': 'Wednesday, 24 March · 11:30 AM',
        'initials': 'WW',
      }
    },
    {
      'time': '12:00',
      'apt': null,
    },
    {
      'time': '13:00',
      'apt': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final item = appointments[index];
        final time = item['time'] as String;
        final apt = item['apt'] as Map<String, dynamic>?;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left side time label
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Vertical divider node
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: apt != null ? AppColors.mockupPurple : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Right content card / placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: apt != null
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.mockupPurpleLight,
                                child: Text(
                                  apt['initials']!,
                                  style: const TextStyle(
                                    color: AppColors.mockupPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      apt['name']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mockupDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      apt['specialty']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(PhosphorIconsRegular.clock, size: 10, color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(
                                          apt['timeText']!,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "Available slots",
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade300, fontStyle: FontStyle.italic),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

