import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)).animate().fadeIn(),
        const SizedBox(height: 20),
        Expanded(child: ListView(children: [
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
  const _SettingsTile(this.title, this.subtitle, this.icon, this.onTap);
  @override
  Widget build(BuildContext ctx) => ListTile(leading: Icon(icon, size: 20, color: AppColors.primary), title: Text(title, style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)), trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary), onTap: onTap);
}
