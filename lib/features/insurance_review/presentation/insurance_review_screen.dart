import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/mock/mock_data_repository.dart';

class InsuranceReviewScreen extends ConsumerStatefulWidget {
  const InsuranceReviewScreen({super.key});

  @override
  ConsumerState<InsuranceReviewScreen> createState() => _InsuranceReviewScreenState();
}

class _InsuranceReviewScreenState extends ConsumerState<InsuranceReviewScreen> {
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    final all   = MockDataRepository.instance.authorizations;
    final queue = all.where((a) =>
        a.status == AuthorizationStatus.pending ||
        a.status == AuthorizationStatus.underReview ||
        a.status == AuthorizationStatus.escalated).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Insurance Review Queue',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('${queue.length} cases awaiting your decision',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ]),
          ]).animate().fadeIn(),

          const SizedBox(height: 20),

          // Summary chips
          Row(children: [
            _QueueChip('Pending', all.where((a) => a.status == AuthorizationStatus.pending).length, AppColors.warning),
            const SizedBox(width: 10),
            _QueueChip('Escalated', all.where((a) => a.status == AuthorizationStatus.escalated).length, AppColors.escalated),
            const SizedBox(width: 10),
            _QueueChip('Under Review', all.where((a) => a.status == AuthorizationStatus.underReview).length, AppColors.info),
          ]).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 20),

          // Cards
          Expanded(
            child: ListView.separated(
              itemCount: queue.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _ReviewCard(auth: queue[i])
                  .animate(delay: Duration(milliseconds: 100 + i * 60)).fadeIn().slideY(begin: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _QueueChip(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(children: [
      Text('$count', style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
    ]),
  );
}

class _ReviewCard extends StatelessWidget {
  final AuthorizationRequest auth;
  const _ReviewCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: auth.status == AuthorizationStatus.escalated
            ? AppColors.escalated.withOpacity(0.4)
            : AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: auth.status.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(auth.status.icon, size: 22, color: auth.status.color),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(auth.patientName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  if (auth.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                      child: Text('URGENT', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                ]),
                Text('${auth.authNumber} · ${auth.requestingDoctorName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _StatusPill(auth.status),
                const SizedBox(height: 4),
                Text(_timeAgo(auth.requestedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ]),
            ]),
          ),

          const Divider(height: 1),

          // Clinical info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: _InfoChip('ICD-10', auth.diagnosisCode, AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(child: _InfoChip('CPT', auth.procedureCode, AppColors.accent)),
              const SizedBox(width: 8),
              Expanded(child: _InfoChip('Plan', auth.insurancePlanName.split(' ').first, AppColors.neutral600)),
            ]),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusLg),
                bottomRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(children: [
              Expanded(child: _ActionBtn('Approve', AppColors.success, PhosphorIconsRegular.checkCircle)),
              const SizedBox(width: 8),
              Expanded(child: _ActionBtn('Reject', AppColors.error, PhosphorIconsRegular.xCircle)),
              const SizedBox(width: 8),
              Expanded(child: _ActionBtn('Escalate', AppColors.escalated, PhosphorIconsRegular.arrowsOut)),
            ]),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusPill extends StatelessWidget {
  final AuthorizationStatus status;
  const _StatusPill(this.status);
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: status.bgColor, borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
    child: Text(status.label, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: status.color, fontWeight: FontWeight.w600)),
  );
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(children: [
      Text(label, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
      Text(value, style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _ActionBtn(this.label, this.color, this.icon);
  @override
  Widget build(BuildContext ctx) => OutlinedButton.icon(
    onPressed: () {},
    icon: Icon(icon, size: 14, color: color),
    label: Text(label, style: TextStyle(color: color, fontSize: 13)),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: color.withOpacity(0.4)),
      padding: const EdgeInsets.symmetric(vertical: 8),
    ),
  );
}
