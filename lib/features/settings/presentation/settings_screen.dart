import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../models/user_role.dart';
import '../../../repositories/data_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.role == UserRole.administrator;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(),
        const SizedBox(height: 20),
        Expanded(child: ListView(children: [
          if (isAdmin)
            _SettingsSection('Admin Controls (Administrator Only)', [
              _SettingsTile(
                'Purge All Supabase Data',
                'Permanently wipe all records from Supabase tables (preserves schemas)',
                PhosphorIconsRegular.trash,
                () => showAdminPurgeDialog(context),
                iconColor: AppColors.error,
                titleColor: AppColors.error,
              ),
            ]),
          _SettingsSection('Integrations', [
            _SettingsTile('FHIR / EMR Integration', 'Configure HL7 FHIR R4 endpoint and sync settings', PhosphorIconsRegular.plugsConnected, () => context.go(RouteNames.integrations)),
          ]),
          _SettingsSection('AI Configuration', [
            _SettingsTile('Confidence Threshold', 'Auto-escalation threshold (currently 75%)', PhosphorIconsRegular.brain, () {}),
            _SettingsTile('SLA Targets', 'Configure decision time targets', PhosphorIconsRegular.timer, () {}),
          ]),
          _SettingsSection('Notifications', [
            _SettingsTile('Email Notifications', 'Configure email alert preferences', PhosphorIconsRegular.envelope, () {}),
            _SettingsTile('Webhook Endpoints', 'Real-time event push configuration', PhosphorIconsRegular.cloudArrowUp, () {}),
          ]),
          _SettingsSection('Security', [
            _SettingsTile('Audit Log Retention', 'Configure hash-chain audit log retention policy', PhosphorIconsRegular.shieldCheck, () {}),
            _SettingsTile('Session Management', 'Active sessions and token settings', PhosphorIconsRegular.lock, () {}),
          ]),
        ])),
      ]),
    );
  }
}

/// Helper function to show the confirmation dialog and purge all Supabase data.
Future<void> showAdminPurgeDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(PhosphorIconsRegular.warning, color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Text('Purge All Supabase Data?'),
        ],
      ),
      content: const Text(
        'Warning: This action will permanently delete all stored data records across all Supabase tables '
        '(patients, doctors, authorizations, appeals, ai decisions, audit logs, notifications, and priorx_store).\n\n'
        'Table structures and database schemas will be preserved.\n'
        'This operation CANNOT be undone.',
        style: TextStyle(height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          icon: const Icon(PhosphorIconsRegular.trash, size: 18),
          label: const Text('Purge All Data'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purging all Supabase table data...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      await DataRepository.instance.purgeAllSupabaseData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Successfully purged all Supabase data records.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Error purging Supabase data: $e'),
          ),
        );
      }
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection(this.title, this.children);
  @override
  Widget build(BuildContext ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
    Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: AppColors.border)), margin: const EdgeInsets.only(bottom: 20),
      child: Column(children: children.asMap().entries.map((e) => Column(children: [e.value, if (e.key < children.length - 1) const Divider(height: 1)])).toList())),
  ]);
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile(
    this.title,
    this.subtitle,
    this.icon,
    this.onTap, {
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext ctx) => ListTile(
        leading: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
        title: Text(
          title,
          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        onTap: onTap,
      );
}
