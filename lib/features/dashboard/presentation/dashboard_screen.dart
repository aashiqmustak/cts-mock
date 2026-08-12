import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../models/user_role.dart';
import '../../../repositories/mock/mock_data_repository.dart';
import '../../../core/utils/platform_helper.dart';

// ─── Dashboard Providers ──────────────────────────────────────────────────────
import '../../../core/providers/authorizations_provider.dart';

final approvalTrendProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return MockDataRepository.instance.approvalTrend;
});

final recentAuthsProvider = Provider<List<AuthorizationRequest>>((ref) {
  final auths = ref.watch(authorizationsProvider);
  return auths.take(5).toList();
});

// Simulated live SLA percentage that ticks upward
final liveSlaProvider = StateProvider<double>((ref) => 0.971);

// ─── Dashboard Screen ─────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate live updates
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(liveSlaProvider.notifier).state = 0.974;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats   = ref.watch(dashboardStatsProvider);
    final user    = ref.watch(currentUserProvider);
    final isAdmin = user?.hasPermission(Permission.viewOrgWideDashboard) ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          _DashboardHeader(user: user).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          const SizedBox(height: 16),

          const _TaskFlowPreviewBanner(),

          const SizedBox(height: 20),

          // ── Stat Cards Row ────────────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isMobile = isMobileLayout(ctx);
            final cols = constraints.maxWidth > 900 ? 4 : 2;
            final aspect = constraints.maxWidth > 900 ? 1.6 : (isMobile ? 1.3 : 1.4);
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: isMobile ? 12 : 16,
              mainAxisSpacing: isMobile ? 12 : 16,
              childAspectRatio: aspect,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  title: 'Approved Today',
                  value: stats.approvedToday,
                  subtitle: '+12% vs yesterday',
                  icon: PhosphorIconsRegular.checkCircle,
                  color: AppColors.success,
                  gradient: AppColors.successGradient,
                  delay: 0,
                ),
                _StatCard(
                  title: 'Pending Review',
                  value: stats.pendingCount,
                  subtitle: '${stats.pendingCount} in queue',
                  icon: PhosphorIconsRegular.clock,
                  color: AppColors.warning,
                  gradient: AppColors.warningGradient,
                  delay: 100,
                ),
                _StatCard(
                  title: 'Rejected Today',
                  value: stats.rejectedToday,
                  subtitle: 'Step therapy issues',
                  icon: PhosphorIconsRegular.xCircle,
                  color: AppColors.error,
                  gradient: AppColors.errorGradient,
                  delay: 200,
                ),
                _StatCard(
                  title: 'AI Accuracy',
                  value: null,
                  valueStr: '${(stats.aiAccuracy * 100).toStringAsFixed(1)}%',
                  subtitle: 'Target: 95%+',
                  icon: PhosphorIconsRegular.brain,
                  color: AppColors.accent,
                  gradient: AppColors.aiGradient,
                  delay: 300,
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          // ── SLA Ring + Quick Stats ────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 700;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _SlaRingCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _QuickStatsCard(stats: stats)),
                ],
              );
            }
            return Column(
              children: [_SlaRingCard(), const SizedBox(height: 16), _QuickStatsCard(stats: stats)],
            );
          }),

          const SizedBox(height: 20),

          // ── Charts Row ────────────────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _ApprovalTrendChart()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _DiseaseStatsChart()),
                ],
              );
            }
            return Column(children: [
              _ApprovalTrendChart(),
              const SizedBox(height: 16),
              _DiseaseStatsChart(),
            ]);
          }),

          const SizedBox(height: 20),

          // ── Bottom Row: Recent Auths + Fraud Radar ────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _RecentAuthorizationsCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _FraudAnomalyCard()),
                ],
              );
            }
            return Column(children: [
              _RecentAuthorizationsCard(),
              const SizedBox(height: 16),
              _FraudAnomalyCard(),
            ]);
          }),

          const SizedBox(height: 20),

          // ── FHIR Sync Health ──────────────────────────────────────────────
          _FhirSyncHealthBar(),
        ],
      ),
    );
  }
}

// ─── Dashboard Header ─────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final dynamic user;
  const _DashboardHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, ${user?.name.split(' ').first ?? 'User'}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  )),
              const SizedBox(height: 4),
              Text(
                'Here\'s what\'s happening across your authorization pipeline today.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Live indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat()).custom(
                duration: 1200.ms,
                builder: (ctx, v, child) => Opacity(opacity: 0.4 + v * 0.6, child: child),
              ),
              const SizedBox(width: 6),
              Text('Live',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.successDark,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatefulWidget {
  final String title;
  final int? value;
  final String? valueStr;
  final String subtitle;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final int delay;

  const _StatCard({
    required this.title, this.value, this.valueStr,
    required this.subtitle, required this.icon,
    required this.color, required this.gradient, required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.animCounter),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = isMobileLayout(context);
    final cardPadding = isMobile ? 12.0 : 20.0;
    final iconSize = isMobile ? 28.0 : 36.0;
    final innerIconSize = isMobile ? 14.0 : 18.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.border),
            boxShadow: AppTheme.shadowSm,
          ),
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: (isMobile
                          ? Theme.of(context).textTheme.labelSmall
                          : Theme.of(context).textTheme.labelMedium)
                          ?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      gradient: widget.gradient,
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                    child: Icon(widget.icon, size: innerIconSize, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.valueStr ?? '${(widget.value! * _anim.value).round()}',
                style: (isMobile
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.headlineMedium)
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: (isMobile
                    ? Theme.of(context).textTheme.labelSmall
                    : Theme.of(context).textTheme.bodySmall)
                    ?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    ).animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

// ─── SLA Ring Gauge ───────────────────────────────────────────────────────────
class _SlaRingCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SlaRingCard> createState() => _SlaRingCardState();
}

class _SlaRingCardState extends ConsumerState<_SlaRingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sla = ref.watch(liveSlaProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Decision SLA',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  Text('% within 5 seconds today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(children: [
                  Icon(PhosphorIconsRegular.lightning,
                      size: 12, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Live',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.successDark,
                        fontWeight: FontWeight.w600,
                      )),
                ]),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160, height: 160,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (ctx, _) => PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: sla * 100 * _anim.value,
                          color: AppColors.success,
                          radius: 28,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: (1 - sla * _anim.value) * 100,
                          color: AppColors.neutral100,
                          radius: 28,
                          title: '',
                        ),
                      ],
                      centerSpaceRadius: 52,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(sla * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      )),
                  Text('within SLA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SlaLegend(color: AppColors.success, label: 'Within SLA'),
              const SizedBox(width: 16),
              _SlaLegend(color: AppColors.neutral300, label: 'Exceeded'),
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _SlaLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _SlaLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
    ]);
  }
}

// ─── Quick Stats Card ─────────────────────────────────────────────────────────
class _QuickStatsCard extends StatelessWidget {
  final DashboardStats stats;
  const _QuickStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Overview',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Real-time KPIs vs targets',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ...[
            _KpiRow('AI Decision Accuracy', stats.aiAccuracy, '95% target', AppColors.accent),
            _KpiRow('Requests Within SLA', stats.percentWithinSla, '95% target', AppColors.primary),
            _KpiRow('Instant Decisions', stats.percentInstantDecision, '90% target', AppColors.success),
            _KpiRow('Appeal Success Rate', stats.appealSuccessRate, '80% target', AppColors.warning),
          ].asMap().entries.map((e) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: e.value,
            ).animate(delay: Duration(milliseconds: 100 + e.key * 80)).fadeIn().slideX(begin: 0.1)
          ).toList(),

          const Divider(height: 24),

          // Revenue saved
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Administrative Cost Saved',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    )),
                Text(fmt.format(stats.revenueSavedUsd),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    )),
              ]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(PhosphorIconsRegular.currencyDollar,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _KpiRow extends StatelessWidget {
  final String label;
  final double value;
  final String target;
  final Color color;
  const _KpiRow(this.label, this.value, this.target, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            Text('${(value * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Approval Trend Chart ─────────────────────────────────────────────────────
class _ApprovalTrendChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(approvalTrendProvider);
    final last14 = trend.skip(trend.length - 14).toList();

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Approval Trend',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            _ChipFilter('30 Days'),
          ]),
          const SizedBox(height: 4),
          Text('Authorization decisions over the last 14 days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 30,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColors.neutral100,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, meta) => Text(
                        v.round().toString(),
                        style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx >= last14.length || idx % 3 != 0) return const SizedBox.shrink();
                        final date = last14[idx]['date'] as DateTime;
                        return Text(DateFormat('M/d').format(date),
                            style: TextStyle(fontSize: 10, color: AppColors.textTertiary));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: last14.asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), (e.value['approved'] as int).toDouble())
                    ).toList(),
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.success.withOpacity(0.15), AppColors.success.withOpacity(0.0)],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: last14.asMap().entries.map((e) =>
                        FlSpot(e.key.toDouble(), (e.value['rejected'] as int).toDouble())
                    ).toList(),
                    isCurved: true,
                    color: AppColors.error,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _ChartLegend(color: AppColors.success, label: 'Approved'),
            const SizedBox(width: 16),
            _ChartLegend(color: AppColors.error, label: 'Rejected'),
          ]),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _ChipFilter extends StatelessWidget {
  final String label;
  const _ChipFilter(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.primary, fontWeight: FontWeight.w600)),
  );
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 16, height: 3, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
  ]);
}

// ─── Disease Stats Donut ──────────────────────────────────────────────────────
class _DiseaseStatsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = MockDataRepository.instance.diseaseStats;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disease Distribution',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text('ICD-10 category breakdown',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(PieChartData(
                    sections: data.take(5).toList().asMap().entries.map((e) {
                      return PieChartSectionData(
                        value: (e.value['pct'] as double) * 100,
                        color: AppColors.chartPalette[e.key],
                        radius: 36,
                        title: '',
                      );
                    }).toList(),
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.take(5).toList().asMap().entries.map((e) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(children: [
                            Container(width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.chartPalette[e.key],
                                  shape: BoxShape.circle,
                                )),
                            const SizedBox(width: 6),
                            Expanded(child: Text(e.value['diagnosis'] as String,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ), overflow: TextOverflow.ellipsis)),
                            Text('${((e.value['pct'] as double) * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                          ]),
                        )
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.1);
  }
}

// ─── Recent Authorizations ────────────────────────────────────────────────────
class _RecentAuthorizationsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auths = ref.watch(recentAuthsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Authorizations',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        'Latest 5 requests across all facilities',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go(RouteNames.authorizations),
                  child: const Text('View all →'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...auths.asMap().entries.map((e) =>
              _AuthRow(auth: e.value, isLast: e.key == auths.length - 1)
                  .animate(delay: Duration(milliseconds: 100 + e.key * 60)).fadeIn().slideX(begin: 0.05)
          ).toList(),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _AuthRow extends StatelessWidget {
  final AuthorizationRequest auth;
  final bool isLast;
  const _AuthRow({required this.auth, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: auth.status.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(auth.status.icon, size: 18, color: auth.status.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auth.patientName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                Text('${auth.authNumber} · ${auth.diagnosisDescription}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                    ), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StatusChip(status: auth.status),
            const SizedBox(height: 4),
            if (auth.processingTimeMs != null)
              Text('${(auth.processingTimeMs! / 1000).toStringAsFixed(1)}s',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: auth.isWithinSla ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  )),
          ]),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AuthorizationStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(status.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: status.color,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}

// ─── Fraud Anomaly Radar ──────────────────────────────────────────────────────
class _FraudAnomalyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final signals = [
      ('Billing Freq.', 0.22, 'CPT 70553 pattern'),
      ('CMS Benchmark', 0.51, 'CPT 22612 outlier'),
      ('Duplicate Detect.', 0.09, 'No duplicates'),
      ('Geo Anomaly', 0.12, 'Within region'),
      ('Provider Pattern', 0.43, 'M54.5 frequency'),
      ('Drug Eligibility', 0.15, 'DailyMed verified'),
      ('Fraud Flagged', 0.07, 'auth-005 escalated'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(PhosphorIconsRegular.shield,
                  size: 16, color: AppColors.error),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fraud & Anomaly Radar',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    'CMS benchmark deviation signals',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 16),

          ...signals.asMap().entries.map((e) {
            final (label, score, note) = e.value;
            Color barColor;
            if (score >= AppConstants.fraudHighRiskScore) {
              barColor = AppColors.error;
            } else if (score >= AppConstants.fraudMediumRiskScore) {
              barColor = AppColors.warning;
            } else {
              barColor = AppColors.success;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary, fontWeight: FontWeight.w500))),
                    Text('${(score * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: barColor, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: score,
                      backgroundColor: barColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 5,
                    ),
                  ),
                ],
              ).animate(delay: Duration(milliseconds: 100 + e.key * 50)).fadeIn().slideX(begin: 0.1),
            );
          }).toList(),
        ],
      ),
    ).animate(delay: 550.ms).fadeIn().slideY(begin: 0.1);
  }
}

// ─── FHIR Sync Health Bar ─────────────────────────────────────────────────────
class _FhirSyncHealthBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final syncs = MockDataRepository.instance.fhirSyncs.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(children: [
                  Icon(PhosphorIconsRegular.plugsConnected,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('FHIR R4 Sync Health',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
                  ),
                ]),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context.go(RouteNames.integrations),
                child: const Text('View all →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (ctx, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: syncs.map((sync) => _FhirResourceTile(sync: sync)).toList(),
              );
            }
            return Row(
              children: syncs.asMap().entries.map((e) {
                final sync = e.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: e.key < syncs.length - 1 ? 12 : 0),
                    child: _FhirResourceTile(sync: sync),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _FhirResourceTile extends StatelessWidget {
  final FhirResourceSync sync;
  const _FhirResourceTile({required this.sync});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10.0 : 14.0,
        vertical: isMobile ? 8.0 : 14.0,
      ),
      decoration: BoxDecoration(
        color: sync.statusColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: sync.statusColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: sync.statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(sync.resourceType,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ]),
          const SizedBox(height: 8),
          Text('${sync.syncedCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} synced',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          if (sync.pendingCount != null && sync.pendingCount! > 0)
            Text('${sync.pendingCount} pending',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: sync.statusColor,
                  fontWeight: FontWeight.w500,
                )),
        ],
      ),
    );
  }
}

class _TaskFlowPreviewBanner extends StatelessWidget {
  const _TaskFlowPreviewBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              PhosphorIconsRegular.squaresFour,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Flow Project Dashboard Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We have drafted the new project management dashboard layout. Try the interactive demo now!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.taskFlow),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Launch Preview'),
                SizedBox(width: 6),
                Icon(PhosphorIconsRegular.arrowRight, size: 14),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1);
  }
}
