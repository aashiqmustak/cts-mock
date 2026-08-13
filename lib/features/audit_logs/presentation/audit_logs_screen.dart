import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../repositories/mock/mock_data_repository.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../models/user_role.dart';
import '../../../models/models.dart';

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  int _selectedTab = 0; // 0 = Hospital Operations, 1 = Prior Auth History

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final allLogs = MockDataRepository.instance.auditLogs;
    
    // Sort logs descending by timestamp
    final sortedLogs = List<AuditLogEntry>.from(allLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filter logs based on role and tab selection
    final filteredLogs = sortedLogs.where((log) {
      final isHospitalOp = log.action.startsWith('patient.') ||
          log.action.startsWith('doctor.') ||
          log.action.startsWith('surgery.') ||
          log.action.startsWith('appointment.') ||
          log.action.startsWith('guardian.') ||
          log.action.startsWith('insurance.') ||
          log.action.startsWith('fhir.') ||
          (log.action.startsWith('user.') && log.actorRole != 'Insurance Reviewer');

      final isPriorAuth = log.action.startsWith('authorization.') ||
          log.action.startsWith('appeal.');

      if (user?.role == UserRole.adminHospital || user?.role == UserRole.administrator) {
        if (_selectedTab == 0) {
          return isHospitalOp;
        } else {
          return isPriorAuth;
        }
      }
      
      // Default: show everything for other roles
      return true;
    }).toList();

    final showTabs = user?.role == UserRole.adminHospital || user?.role == UserRole.administrator;

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

        if (showTabs) ...[
          const SizedBox(height: 16),
          // Custom Tab Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabButton(0, 'Hospital Operations', PhosphorIconsRegular.hospital),
                _buildTabButton(1, 'Prior Auth History', PhosphorIconsRegular.clipboardText),
              ],
            ),
          ).animate(delay: 150.ms).fadeIn(),
        ],

        const SizedBox(height: 20),

        Expanded(
          child: filteredLogs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsRegular.listChecks, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text('No logs found for this filter',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, i) => Column(children: [
                    // Hash link connector
                    Center(
                      child: Container(
                        width: 2, height: 16,
                        color: AppColors.neutral200,
                      ),
                    ),
                  ]),
                  itemBuilder: (ctx, i) => _AuditLogRow(entry: filteredLogs[i], index: i)
                      .animate(key: ValueKey(filteredLogs[i].id), delay: Duration(milliseconds: 50 + i * 40))
                      .fadeIn()
                      .slideY(begin: 0.05),
                ),
        ),
      ]),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: isSelected ? AppTheme.shadowSm : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
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
    if (action.contains('patient.')) return Icons.person_add_rounded;
    if (action.contains('doctor.')) return Icons.medical_services_rounded;
    if (action.contains('surgery.')) return Icons.personal_injury_rounded;
    if (action.contains('appointment.')) return Icons.event_rounded;
    if (action.contains('guardian.')) return Icons.family_restroom_rounded;
    if (action.contains('insurance.')) return Icons.verified_user_rounded;
    return Icons.info_rounded;
  }

  String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.month}/${d.day}/${d.year}';
  }
}
