import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/mock/mock_data_repository.dart';

class AppealsScreen extends ConsumerWidget {
  const AppealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appeals = MockDataRepository.instance.appeals;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Appeals Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('Track, file, and manage authorization appeals with AI-predicted success rates',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              ]),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(PhosphorIconsRegular.plusCircle, size: 16),
                label: const Text('File Appeal'),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Summary row
          Row(children: [
            _AppealStat('Total Filed', '12', AppColors.primary),
            const SizedBox(width: 12),
            _AppealStat('Overturned', '7', AppColors.success),
            const SizedBox(width: 12),
            _AppealStat('Under Review', '3', AppColors.warning),
            const SizedBox(width: 12),
            _AppealStat('AI Prediction', '78.3%', AppColors.accent),
          ]).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: appeals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _AppealCard(appeal: appeals[i])
                  .animate(delay: Duration(milliseconds: 150 + i * 80)).fadeIn().slideY(begin: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppealStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AppealStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800, color: color)),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _AppealCard extends StatelessWidget {
  final AppealCase appeal;
  const _AppealCard({required this.appeal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(appeal.appealNumber,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AppColors.primary,
                    )),
                const SizedBox(width: 10),
                _AppealStatusBadge(status: appeal.status),
              ]),
              Text('${appeal.patientName} · Auth: ${appeal.authNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Filed by ${appeal.filedByName}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
            ])),
            // AI Success Probability
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${(appeal.aiSuccessProbability * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: appeal.aiSuccessProbability >= 0.6 ? AppColors.success : AppColors.warning,
                  )),
              Text('Appeal Success',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              if (appeal.aiProbabilityLow != null)
                Text(
                  '${(appeal.aiProbabilityLow! * 100).toStringAsFixed(0)}–${(appeal.aiProbabilityHigh! * 100).toStringAsFixed(0)}% CI',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary, fontSize: 10),
                ),
            ]),
          ]),
        ),

        const Divider(height: 1),

        // Grounds for appeal
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Grounds for Appeal',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(appeal.groundsForAppeal,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ]),
        ),

        // Draft appeal letter button
        if (appeal.draftAppealLetter != null)
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
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _showAppealLetter(context, appeal),
                icon: const Icon(PhosphorIconsRegular.filePdf, size: 16, color: AppColors.primary),
                label: const Text('View AI-Drafted Appeal Letter'),
              )),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(PhosphorIconsRegular.download, size: 14),
                label: const Text('PDF'),
              ),
            ]),
          ),
      ]),
    );
  }

  void _showAppealLetter(BuildContext context, AppealCase appeal) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusXl),
                    topRight: Radius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Row(children: [
                  const Icon(PhosphorIconsRegular.filePdf, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text('AI-Generated Appeal Letter',
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700))),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('78.3% success probability',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ]),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    appeal.draftAppealLetter ?? '',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(PhosphorIconsRegular.x, size: 14),
                    label: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(PhosphorIconsRegular.download, size: 14),
                    label: const Text('Download PDF'),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppealStatusBadge extends StatelessWidget {
  final AppealStatus status;
  const _AppealStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(status.statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: status.statusColor, fontWeight: FontWeight.w600)),
    );
  }
}
