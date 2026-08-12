import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/mock/mock_data_repository.dart';
import '../../../core/utils/patient_portal_helper.dart';

class PatientDetailScreen extends ConsumerWidget {
  final String id;
  const PatientDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = MockDataRepository.instance.patients;
    final patient = patients.firstWhere((p) => p.id == id, orElse: () => patients.first);
    
    final allAuths = MockDataRepository.instance.authorizations;
    final patientAuths = allAuths.where((a) => a.patientId == patient.id).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                TextButton(
                  onPressed: () => context.go(RouteNames.patients),
                  child: const Text('Patients'),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textTertiary),
                Text(
                  patient.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Patient Header Card
            _PatientHeader(patient: patient).animate(delay: 50.ms).fadeIn().slideY(begin: -0.05),

            const SizedBox(height: 20),

            // Responsive Layout
            LayoutBuilder(builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _ClinicalSummaryCard(patient: patient),
                          const SizedBox(height: 16),
                          _AuthorizationHistoryCard(auths: patientAuths),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _ContactInsuranceCard(patient: patient),
                          const SizedBox(height: 16),
                          _QuickActionsCard(patient: patient),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _ClinicalSummaryCard(patient: patient),
                  const SizedBox(height: 16),
                  _ContactInsuranceCard(patient: patient),
                  const SizedBox(height: 16),
                  _AuthorizationHistoryCard(auths: patientAuths),
                  const SizedBox(height: 16),
                  _QuickActionsCard(patient: patient),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  final Patient patient;
  const _PatientHeader({required this.patient});

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
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              patient.name.split(' ').map((w) => w[0]).take(2).join(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: patient.gender == 'Male' ? Colors.blue.withOpacity(0.08) : Colors.pink.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                          color: patient.gender == 'Male' ? Colors.blue.withOpacity(0.3) : Colors.pink.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        patient.gender,
                        style: TextStyle(
                          color: patient.gender == 'Male' ? Colors.blue[700] : Colors.pink[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'MRN: ${patient.mrn ?? "—"} · DOB: ${patient.dateOfBirth}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClinicalSummaryCard extends StatelessWidget {
  final Patient patient;
  const _ClinicalSummaryCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.firstAid, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Clinical Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Primary Diagnosis',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            patient.primaryDiagnosis ?? 'No primary diagnosis recorded',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            'Chronic Conditions',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 8),
          if (patient.chronicConditions.isEmpty)
            Text('No chronic conditions recorded', style: Theme.of(context).textTheme.bodyMedium)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: patient.chronicConditions.map((cond) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    cond,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ContactInsuranceCard extends StatelessWidget {
  final Patient patient;
  const _ContactInsuranceCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.shieldCheck, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Insurance & Demographics',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          _DetailField(label: 'Payer', value: patient.payer),
          _DetailField(label: 'Plan Name', value: patient.insurancePlan),
          _DetailField(label: 'Member/Insurance ID', value: patient.insuranceId, isCode: true),
          _DetailField(label: 'Phone Number', value: patient.contactPhone),
          _DetailField(label: 'Email Address', value: patient.contactEmail ?? '—'),
          _DetailField(label: 'Primary Care Physician', value: patient.primaryPhysicianName ?? '—'),
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final bool isCode;
  const _DetailField({required this.label, required this.value, this.isCode = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: isCode ? 'monospace' : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorizationHistoryCard extends StatelessWidget {
  final List<AuthorizationRequest> auths;
  const _AuthorizationHistoryCard({required this.auths});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIconsRegular.clipboardText, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Prior Authorizations (${auths.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          if (auths.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No authorization history found for this patient.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: auths.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (ctx, i) {
                final auth = auths[i];
                return InkWell(
                  onTap: () => context.go('${RouteNames.authorizations}/${auth.id}'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 36,
                          decoration: BoxDecoration(
                            color: auth.status.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    auth.authNumber,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  _StatusChip(status: auth.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${auth.procedureCode} · ${auth.procedureDescription}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Preview Patient Portal Explanation',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showPatientExplanation(ctx, auth),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(PhosphorIconsRegular.user, color: auth.status.color, size: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showPatientExplanation(BuildContext context, AuthorizationRequest auth) {
    final decisions = MockDataRepository.instance.aiDecisions;
    final decision = auth.aiDecisionId != null
        ? decisions.firstWhere((d) => d.id == auth.aiDecisionId, orElse: () => decisions.first)
        : null;
    final explanation = PatientPortalExplanation.generate(auth, decision);

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Pull handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(PhosphorIconsRegular.user, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Patient Portal Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Status row
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            explanation.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      explanation.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
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
                          Icon(Icons.arrow_forward_rounded, size: 14, color: statusColor),
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
                    
                    ...explanation.glossary.map((entry) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: AppColors.surface,
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
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final Patient patient;
  const _QuickActionsCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.lightning, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const Divider(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.createAuthorization),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New Authorization'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('FHIR XML Summary generated for ${patient.name}'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: Icon(PhosphorIconsRegular.downloadSimple, size: 18),
              label: const Text('Export Health Record (CCD)'),
            ),
          ),
        ],
      ),
    );
  }
}
