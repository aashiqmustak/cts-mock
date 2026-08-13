import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/data_repository.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = ['Overview', 'Hospital', 'Physicians', 'Disease', 'Insurance', 'Financial'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Analytics & Reports',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('Comprehensive insights across authorizations, physicians, and financials',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ]),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(PhosphorIconsRegular.download, size: 16),
                label: const Text('Export Report'),
              ),
            ],
          ).animate().fadeIn(),
        ),

        // Tabs
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _OverviewTab(),
              _HospitalTab(),
              _PhysicianTab(),
              _DiseaseTab(),
              _InsuranceTab(),
              _FinancialTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final trend = MockDataRepository.instance.approvalTrend;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        // KPI cards
        LayoutBuilder(builder: (ctx, c) {
          final cols = c.maxWidth > 800 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            crossAxisSpacing: 16, mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _KpiCard('Total Requests', '1,847', '+12.4%', AppColors.primary, PhosphorIconsRegular.clipboardText),
              _KpiCard('Approval Rate', '85.3%', '+2.1%', AppColors.success, PhosphorIconsRegular.checkCircle),
              _KpiCard('Avg Processing', '3.24s', '-0.8s', AppColors.accent, PhosphorIconsRegular.lightning),
              _KpiCard('Admin Cost Saved', '\$2.84M', '+\$340K', AppColors.warning, PhosphorIconsRegular.currencyDollar),
            ],
          );
        }),

        const SizedBox(height: 20),

        // 30-day trend chart
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('30-Day Authorization Trend',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) => FlLine(color: AppColors.neutral100, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(v.round().toString(),
                            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                      )),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 22,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i % 5 != 0 || i >= trend.length) return const SizedBox.shrink();
                          final date = trend[i]['date'] as DateTime;
                          return Text('${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary));
                        },
                      )),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: trend.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: (e.value['approved'] as int).toDouble(),
                          color: AppColors.success,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: (e.value['rejected'] as int).toDouble(),
                          color: AppColors.error.withOpacity(0.7),
                          width: 8,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                _ChartLegend(color: AppColors.success, label: 'Approved'),
                const SizedBox(width: 16),
                _ChartLegend(color: AppColors.error, label: 'Rejected'),
              ]),
            ],
          ),
        ).animate(delay: 200.ms).fadeIn(),
      ]),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final Color color;
  final IconData icon;
  const _KpiCard(this.title, this.value, this.change, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    final isPositive = change.startsWith('+') || change.startsWith('-') && !change.contains('+');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, size: 18, color: color),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(change, style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.success, fontWeight: FontWeight.w600)),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext ctx) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 6),
    Text(label, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
  ]);
}

class _HospitalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderTab(
    title: 'Hospital Performance',
    icon: PhosphorIconsRegular.hospital,
    description: 'Facility-level authorization approval rates, processing times, and SLA compliance metrics.',
  );
}

class _PhysicianTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final doctors = MockDataRepository.instance.doctors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Physician Performance Leaderboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        ...doctors.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _DoctorRow(doctor: e.value, rank: e.key + 1),
        )).toList(),
      ]),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  final dynamic doctor;
  final int rank;
  const _DoctorRow({required this.doctor, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: rank <= 3 ? AppColors.warningLight : AppColors.neutral100,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('#$rank', style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: rank <= 3 ? AppColors.warning : AppColors.textSecondary,
            fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(doctor.name, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text('${doctor.specialization} · ${doctor.facility}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${(doctor.approvalRate * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800, color: AppColors.success)),
          Text('${doctor.totalRequests} requests',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
        ]),
      ]),
    );
  }
}

class _DiseaseTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = MockDataRepository.instance.diseaseStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Disease Category Statistics', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        ...data.asMap().entries.map((e) {
          final item = e.value;
          return Padding(padding: const EdgeInsets.only(bottom: 12), child: Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppColors.border)),
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(item['diagnosis'] as String,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600))),
                Text(item['icd'] as String,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primary, fontFamily: 'monospace')),
                const SizedBox(width: 12),
                Text('${item['count']} cases',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                value: item['pct'] as double,
                backgroundColor: AppColors.chartPalette[e.key % AppColors.chartPalette.length].withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.chartPalette[e.key % AppColors.chartPalette.length]),
                minHeight: 8,
              )),
              const SizedBox(height: 4),
              Text('${((item['pct'] as double) * 100).toStringAsFixed(1)}% of all authorizations',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
            ]),
          ));
        }).toList(),
      ]),
    );
  }
}

class _InsuranceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _PlaceholderTab(
    title: 'Insurance Statistics',
    icon: PhosphorIconsRegular.buildings,
    description: 'Payer-specific approval rates, denial patterns, and processing time benchmarks.',
  );
}

class _FinancialTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Financial Dashboard', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16,
          childAspectRatio: 1.5, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          children: [
            _FinancialCard('Administrative Cost Saved', '\$2,840,000', '\$31B industry problem', AppColors.success),
            _FinancialCard('Revenue Cycle Improvement', '+18.4%', 'vs. manual process', AppColors.primary),
            _FinancialCard('Cost per Authorization', '\$3.20', 'Down from \$47.00', AppColors.accent),
            _FinancialCard('Appeal Recovery Rate', '\$420,000', 'From overturned denials', AppColors.warning),
          ],
        ),
      ]),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final Color color;
  const _FinancialCard(this.title, this.value, this.sub, this.color);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      border: Border.all(color: AppColors.border),
    ),
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800, color: color)),
      Text(sub, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
    ]),
  );
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  const _PlaceholderTab({required this.title, required this.icon, required this.description});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
        child: Icon(icon, size: 36, color: Colors.white),
      ),
      const SizedBox(height: 20),
      Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      SizedBox(width: 320, child: Text(description, textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))),
    ]),
  );
}

