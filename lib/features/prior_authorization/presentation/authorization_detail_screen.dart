import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/utils/patient_portal_helper.dart';

class AuthorizationDetailScreen extends ConsumerWidget {
  final String id;
  const AuthorizationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auths = MockDataRepository.instance.authorizations;
    final auth  = auths.firstWhere((a) => a.id == id,
        orElse: () => auths.first);
    final aiDecision = auth.aiDecisionId != null
        ? MockDataRepository.instance.aiDecisions
            .firstWhere((d) => d.id == auth.aiDecisionId, orElse: () => MockDataRepository.instance.aiDecisions.first)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(children: [
            TextButton(
              onPressed: () => context.go(RouteNames.authorizations),
              child: const Text('Authorizations'),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiary),
            Text(auth.authNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ]).animate().fadeIn(),

          const SizedBox(height: 16),

          // Header
          _AuthDetailHeader(auth: auth).animate(delay: 100.ms).fadeIn().slideY(begin: -0.05),

          const SizedBox(height: 20),

          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: Column(children: [
                    _PatientInfoCard(auth: auth),
                    const SizedBox(height: 16),
                    _ProcedureCard(auth: auth),
                    const SizedBox(height: 16),
                    _PatientPortalExplanationCard(auth: auth, decision: aiDecision),
                    if (aiDecision != null) ...[
                      const SizedBox(height: 16),
                      _AiDecisionPanel(decision: aiDecision),
                    ],
                  ])),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: Column(children: [
                    _StatusTimelineCard(auth: auth),
                    const SizedBox(height: 16),
                    _ActionsCard(auth: auth),
                  ])),
                ],
              );
            }
            return Column(children: [
              _PatientInfoCard(auth: auth),
              const SizedBox(height: 16),
              _ProcedureCard(auth: auth),
              const SizedBox(height: 16),
              _PatientPortalExplanationCard(auth: auth, decision: aiDecision),
              const SizedBox(height: 16),
              _StatusTimelineCard(auth: auth),
              const SizedBox(height: 16),
              _ActionsCard(auth: auth),
              if (aiDecision != null) ...[
                const SizedBox(height: 16),
                _AiDecisionPanel(decision: aiDecision),
              ],
            ]);
          }),
        ],
      ),
    );
  }
}

class _AuthDetailHeader extends StatelessWidget {
  final AuthorizationRequest auth;
  const _AuthDetailHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: auth.status.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(auth.status.icon, size: 26, color: auth.status.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(auth.authNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        color: AppColors.primary,
                      )),
                  const SizedBox(width: 10),
                  _StatusPill(status: auth.status),
                  if (auth.isUrgent) ...[
                    const SizedBox(width: 6),
                    _UrgentBadge(),
                  ],
                ]),
                const SizedBox(height: 4),
                Text('${auth.patientName} · ${auth.diagnosisCode}: ${auth.diagnosisDescription}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary)),
              ],
            ),
          ),
          // SLA timer
          if (auth.processingTimeMs != null)
            Column(children: [
              Text('${(auth.processingTimeMs! / 1000).toStringAsFixed(1)}s',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: auth.isWithinSla ? AppColors.success : AppColors.error,
                  )),
              Text('Decision Time',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textTertiary)),
              Icon(
                auth.isWithinSla ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: auth.isWithinSla ? AppColors.success : AppColors.error,
                size: 16,
              ),
            ]),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final AuthorizationStatus status;
  const _StatusPill({required this.status});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: status.bgColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
    ),
    child: Text(status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.color, fontWeight: FontWeight.w600)),
  );
}

class _UrgentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text('URGENT',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.5)),
  );
}

class _PatientInfoCard extends StatelessWidget {
  final AuthorizationRequest auth;
  const _PatientInfoCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Patient Information',
      icon: PhosphorIconsRegular.user,
      children: [
        _InfoRow(
          'Patient Name',
          auth.patientName,
          onTap: () => context.go('/patients/${auth.patientId}'),
        ),
        _InfoRow('Date of Birth', auth.patientDob),
        _InfoRow('Insurance ID', auth.patientInsuranceId),
        _InfoRow('Insurance Plan', auth.insurancePlanName),
        _InfoRow('Requesting Physician', auth.requestingDoctorName),
        _InfoRow('Facility', auth.facilityName),
        _InfoRow('Facility NPI', auth.facilityNpi),
      ],
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  final AuthorizationRequest auth;
  const _ProcedureCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Clinical Information',
      icon: PhosphorIconsRegular.stethoscope,
      children: [
        _InfoRow('Diagnosis Code', auth.diagnosisCode, isCode: true),
        _InfoRow('Diagnosis', auth.diagnosisDescription),
        _InfoRow('Procedure Code', auth.procedureCode, isCode: true),
        _InfoRow('Procedure', auth.procedureDescription),
        if (auth.drugName != null) ...[
          _InfoRow('Medication', auth.drugName!),
          _InfoRow('NDC Code', auth.drugNdc!, isCode: true),
        ],
        if (auth.dataSource != null) _InfoRow('Data Source', auth.dataSource!),
        if (auth.rejectionReason != null)
          _InfoRow('Rejection Reason', auth.rejectionReason!, isHighlight: true),
        if (auth.policyClauseCited != null)
          _InfoRow('Policy Cited', auth.policyClauseCited!, isHighlight: true),
      ],
    );
  }
}

class _StatusTimelineCard extends StatelessWidget {
  final AuthorizationRequest auth;
  const _StatusTimelineCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    final events = [
      ('Submitted', auth.requestedAt, AppColors.primary),
      if (auth.reviewedAt != null) ('Under Review', auth.reviewedAt!, AppColors.info),
      if (auth.decidedAt != null) (auth.status.label, auth.decidedAt!, auth.status.color),
    ];

    return _InfoCard(
      title: 'Authorization Timeline',
      icon: PhosphorIconsRegular.timer,
      children: events.asMap().entries.map((e) {
        final (label, time, color) = e.value;
        final isLast = e.key == events.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Container(width: 12, height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              if (!isLast) Container(width: 2, height: 32, color: AppColors.neutral200),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: color)),
                Text(_formatDate(time),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
              ]),
            )),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.month}/${d.day}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _ActionsCard extends ConsumerWidget {
  final AuthorizationRequest auth;
  const _ActionsCard({required this.auth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAct = auth.status == AuthorizationStatus.pending ||
        auth.status == AuthorizationStatus.underReview;
    final isRejected = auth.status == AuthorizationStatus.rejected;

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
          Text('Actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          if (canAct) ...[
            _ActionButton(
              label: 'Approve', icon: PhosphorIconsRegular.checkCircle,
              color: AppColors.success, onTap: () => _showApproveDialog(context),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: 'Reject', icon: PhosphorIconsRegular.xCircle,
              color: AppColors.error, onTap: () => _showRejectDialog(context),
            ),
            const SizedBox(height: 8),
            _ActionButton(
              label: 'Escalate to Human', icon: PhosphorIconsRegular.arrowsOut,
              color: AppColors.escalated, onTap: () {},
            ),
            const SizedBox(height: 8),
          ],
          if (isRejected)
            _ActionButton(
              label: 'File Appeal', icon: PhosphorIconsRegular.gavel,
              color: AppColors.warning,
              onTap: () => context.go(RouteNames.appeals),
            ),
          _ActionButton(
            label: 'View AI Decision', icon: PhosphorIconsRegular.brain,
            color: AppColors.accent, onTap: () => context.go(RouteNames.aiDecisionCenter),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            label: 'Generate PDF', icon: PhosphorIconsRegular.filePdf,
            color: AppColors.neutral600, onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext ctx) => showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('Approve Authorization'),
      content: const Text('This will approve the authorization request and notify the provider.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Approve')),
      ],
    ),
  );

  void _showRejectDialog(BuildContext ctx) => showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('Reject Authorization'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Please provide the reason for rejection:'),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(hintText: 'Rejection reason...'), maxLines: 3),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Reject'),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}

class _AiDecisionPanel extends StatefulWidget {
  final AiDecision decision;
  const _AiDecisionPanel({required this.decision});

  @override
  State<_AiDecisionPanel> createState() => _AiDecisionPanelState();
}

class _AiDecisionPanelState extends State<_AiDecisionPanel> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final d = widget.decision;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.aiGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg),
                topRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsRegular.brain, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('AI Decision Reasoning',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                  Text(d.modelVersion,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.7))),
                ])),
                // Recommendation badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: d.recommendationColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(d.recommendation.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ),
              ],
            ),
          ),

          // Scores row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _ScoreWidget('Confidence', d.confidenceScore, AppColors.primary),
                _ScoreWidget('Medical Necessity', d.medicalNecessityScore, AppColors.success),
                _ScoreWidget('Risk Score', d.riskScore, AppColors.error),
                _ScoreWidget('Appeal Likelihood', d.appealLikelihood, AppColors.warning),
              ].map((w) => Expanded(child: w)).toList(),
            ),
          ),

          if (d.autoEscalated)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.escalatedLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.escalated.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Icon(PhosphorIconsRegular.warningOctagon, size: 16, color: AppColors.escalated),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Auto-escalated: AI confidence (${(d.confidenceScore * 100).toStringAsFixed(0)}%) is below the 75% threshold. A human reviewer must decide.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.escalated),
                  )),
                ]),
              ),
            ),

          const Divider(height: 1),

          // Reasoning chain
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explainable AI Reasoning Chain',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...d.reasoningChain.map((step) => _ReasoningStepCard(
                  step: step,
                  isExpanded: _expanded.contains(step.stepNumber),
                  onToggle: () => setState(() {
                    if (_expanded.contains(step.stepNumber)) {
                      _expanded.remove(step.stepNumber);
                    } else {
                      _expanded.add(step.stepNumber);
                    }
                  }),
                )),
              ],
            ),
          ),

          // Final justification
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Final AI Justification',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(d.finalJustification,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary, height: 1.6)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ScoreWidget(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('${(value * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800, color: color)),
      Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary),
          textAlign: TextAlign.center),
    ]);
  }
}

class _ReasoningStepCard extends StatelessWidget {
  final AiReasoningStep step;
  final bool isExpanded;
  final VoidCallback onToggle;
  const _ReasoningStepCard({required this.step, required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: step.passed ? AppColors.successLight.withOpacity(0.5) : AppColors.errorLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: step.passed ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: step.passed ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: step.passed
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Step ${step.stepNumber}: ${step.title}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (step.citedValue != null)
                          Text(step.citedValue!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary, fontFamily: 'monospace')),
                      ]),
                    ),
                    // Data source badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(step.dataSource.split(' ').first,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Divider(height: 12),
                  Text(step.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary, height: 1.6)),
                  if (step.details.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...step.details.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        const Icon(Icons.circle, size: 5, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(d,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary))),
                      ]),
                    )).toList(),
                  ],
                  if (step.policyRef != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(PhosphorIconsRegular.book, size: 12, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(step.policyRef!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCode;
  final bool isHighlight;
  final VoidCallback? onTap;
  const _InfoRow(this.label, this.value, {this.isCode = false, this.isHighlight = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget valueWidget = Text(
      value,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontFamily: isCode ? 'monospace' : null,
        color: onTap != null
            ? AppColors.primary
            : (isHighlight
                ? AppColors.errorDark
                : (isCode ? AppColors.primary : AppColors.textPrimary)),
        decoration: onTap != null ? TextDecoration.underline : null,
      ),
    );

    if (onTap != null) {
      valueWidget = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: valueWidget,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: valueWidget,
          ),
        ],
      ),
    );
  }
}

class _PatientPortalExplanationCard extends StatelessWidget {
  final AuthorizationRequest auth;
  final AiDecision? decision;
  const _PatientPortalExplanationCard({required this.auth, this.decision});

  @override
  Widget build(BuildContext context) {
    final explanation = PatientPortalExplanation.generate(auth, decision);
    
    // Status-specific color
    Color statusColor;
    IconData statusIcon;
    switch (auth.status) {
      case AuthorizationStatus.approved:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case AuthorizationStatus.rejected:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      case AuthorizationStatus.pending:
      case AuthorizationStatus.underReview:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule_rounded;
        break;
      case AuthorizationStatus.escalated:
        statusColor = AppColors.escalated;
        statusIcon = Icons.priority_high_rounded;
        break;
      default:
        statusColor = AppColors.neutral500;
        statusIcon = Icons.info_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg),
                topRight: Radius.circular(AppTheme.radiusLg),
              ),
              border: Border(bottom: BorderSide(color: statusColor.withOpacity(0.15))),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.user, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Patient Portal View',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    'LAYPERSON TRANSLATION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral700,
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big Status Title
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        explanation.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                
                // Jargon-free Explanation
                Text(
                  explanation.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Next Steps
                Text(
                  'What you should do next:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...explanation.nextSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const Divider(height: 32),

                // Glossary
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.bookOpen, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Understand Your Treatment & Codes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Healthcare terms can be confusing. Here is what they mean in plain language:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Glossary List
                ...explanation.glossary.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: AppColors.neutral50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

