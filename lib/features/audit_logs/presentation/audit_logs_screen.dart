import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/mock/mock_data_repository.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = MockDataRepository.instance.auditLogs;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Audit Logs',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            Text('Tamper-evident hash-chained activity ledger',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(PhosphorIconsRegular.shieldCheck, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Chain Verified', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.successDark, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]).animate().fadeIn(),

        const SizedBox(height: 8),

        // Chain integrity notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(children: [
            Icon(PhosphorIconsRegular.info, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Each entry includes a SHA-256 hash linked to the previous entry — any tampering would break the chain and be immediately detected.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryDark),
            )),
          ]),
        ).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 20),

        Expanded(
          child: ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, i) => Column(children: [
              // Hash link connector
              Center(
                child: Container(
                  width: 2, height: 20,
                  color: AppColors.neutral200,
                ),
              ),
            ]),
            itemBuilder: (ctx, i) => _AuditLogRow(entry: logs[i], index: i)
                .animate(delay: Duration(milliseconds: 50 + i * 40)).fadeIn().slideY(begin: 0.05),
          ),
        ),
      ]),
    );
  }
}

class _AuditLogRow extends StatefulWidget {
  final dynamic entry;
  final int index;
  const _AuditLogRow({required this.entry, required this.index});

  @override
  State<_AuditLogRow> createState() => _AuditLogRowState();
}

class _AuditLogRowState extends State<_AuditLogRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.entry;
    final isSystem = log.actorId == 'SYSTEM';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(children: [
        // Main row
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Action icon
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isSystem ? AppColors.primarySurface : AppColors.neutral100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getActionIcon(log.action),
                  size: 18,
                  color: isSystem ? AppColors.primary : AppColors.neutral600,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(log.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${log.actorName} · ${log.actorRole} · ${log.ipAddress}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ])),

              const SizedBox(width: 12),

              // Hash + timestamp
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(_formatTime(log.timestamp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                // Hash badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(log.entryHash,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      )),
                ),
              ]),

              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.textTertiary, size: 20),
            ]),
          ),
        ),

        // Expanded hash chain detail
        if (_expanded)
          Container(
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusLg),
                bottomRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hash Chain Detail',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _HashRow('Entry Hash', log.entryHash, context),
              if (log.previousHash != null)
                _HashRow('Previous Hash', log.previousHash!, context),
              _HashRow('Actor ID', log.actorId, context),
              _HashRow('IP Address', log.ipAddress, context),
              _HashRow('Timestamp', log.timestamp.toIso8601String(), context),
            ]),
          ),
      ]),
    );
  }

  Widget _HashRow(String label, String value, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary))),
        Expanded(child: Text(value, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
          fontFamily: 'monospace', color: AppColors.textSecondary, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  IconData _getActionIcon(String action) {
    if (action.contains('approved')) return Icons.check_circle_rounded;
    if (action.contains('rejected')) return Icons.cancel_rounded;
    if (action.contains('escalated')) return Icons.priority_high_rounded;
    if (action.contains('appeal')) return Icons.gavel_rounded;
    if (action.contains('login')) return Icons.login_rounded;
    if (action.contains('fhir')) return Icons.sync_rounded;
    return Icons.info_rounded;
  }

  String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.month}/${d.day}/${d.year}';
  }
}
