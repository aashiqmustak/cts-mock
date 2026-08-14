import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/models.dart';
import '../../../../repositories/data_repository.dart';

class IntegrationsScreen extends ConsumerStatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  ConsumerState<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends ConsumerState<IntegrationsScreen> {
  bool _testing = false;

  @override
  Widget build(BuildContext context) {
    final syncs = MockDataRepository.instance.fhirSyncs;
    final healthy = syncs.where((s) => s.status == FhirSyncStatus.healthy).length;
    final total   = syncs.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('FHIR EMR Integrations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('HL7 FHIR R4 connectivity and resource synchronization status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _testing ? null : () async {
                setState(() => _testing = true);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => _testing = false);
              },
              icon: _testing
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(PhosphorIconsRegular.arrowsClockwise, size: 16),
              label: Text(_testing ? 'Testing...' : 'Test Connection'),
            ),
          ]).animate().fadeIn(),

          const SizedBox(height: 20),

          // Endpoint status card
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FHIR R4 Endpoint', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
                Text('https://fhir.mediauth.ai/R4', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                  ).animate(onPlay: (c) => c.repeat()).custom(
                    duration: 1200.ms,
                    builder: (ctx, v, child) => Opacity(opacity: 0.4 + v * 0.6, child: child),
                  ),
                  const SizedBox(width: 6),
                  Text('Connected · R4 Compliant', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white)),
                ]),
              ])),
              Column(children: [
                Text('$healthy/$total', style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w900)),
                Text('Resources Healthy', style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.7))),
              ]),
            ]),
          ).animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 20),

          // Resource sync grid
          Text('Resource Synchronization Status',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 12),

          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 700 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: syncs.asMap().entries.map((e) =>
                _ResourceSyncCard(sync: e.value)
                    .animate(delay: Duration(milliseconds: 200 + (e.key * 50).toInt())).fadeIn().scale(begin: const Offset(0.95, 0.95))
              ).toList(),
            );
          }),

          const SizedBox(height: 20),

          // Webhook event stream
          Text('Simulated Webhook Events',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: AppColors.neutral900,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              ..._webhookEvents.asMap().entries.map((e) =>
                  _WebhookEventRow(event: e.value, index: e.key)
                      .animate(delay: Duration(milliseconds: 400 + e.key * 80)).fadeIn(),
              ).toList(),
            ]),
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }
}

final _webhookEvents = [
  {'time': '10:32:14', 'type': 'patient.updated', 'resource': 'Patient/pat-001', 'status': 'success'},
  {'time': '10:31:57', 'type': 'coverage.verified', 'resource': 'Coverage/cov-849', 'status': 'success'},
  {'time': '10:31:22', 'type': 'claim.submitted', 'resource': 'Claim/clm-5021', 'status': 'success'},
  {'time': '10:30:45', 'type': 'service_request.created', 'resource': 'ServiceRequest/sr-012', 'status': 'success'},
  {'time': '10:29:11', 'type': 'condition.sync', 'resource': 'Condition/cond-203', 'status': 'error'},
  {'time': '10:28:53', 'type': 'medication.updated', 'resource': 'MedicationRequest/med-771', 'status': 'success'},
];

class _WebhookEventRow extends StatelessWidget {
  final Map<String, String> event;
  final int index;
  const _WebhookEventRow({required this.event, required this.index});

  @override
  Widget build(BuildContext context) {
    final isError = event['status'] == 'error';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(event['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
        const SizedBox(width: 12),
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: isError ? AppColors.error : Colors.greenAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('[${event['type']}]', style: TextStyle(
          color: isError ? AppColors.error : AppColors.primaryLight,
          fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(child: Text(event['resource']!, style: const TextStyle(
          color: Colors.white70, fontSize: 11, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
        Text(event['status']!, style: TextStyle(
          color: isError ? AppColors.error : Colors.greenAccent,
          fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _ResourceSyncCard extends StatelessWidget {
  final FhirResourceSync sync;
  const _ResourceSyncCard({required this.sync});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: sync.statusColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: sync.statusColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(sync.resourceType,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_formatCount(sync.syncedCount)} synced',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            if (sync.pendingCount != null && sync.pendingCount! > 0)
              Text('${sync.pendingCount} pending',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: sync.statusColor, fontWeight: FontWeight.w600)),
            if (sync.errorMessage != null)
              Text(sync.errorMessage!, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.error, fontSize: 10),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            if (sync.lastSyncAt != null)
              Text(_formatSyncTime(sync.lastSyncAt!),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
          ]),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  String _formatSyncTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

