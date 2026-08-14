import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/providers/auth_provider.dart';

class InsuranceReviewScreen extends ConsumerStatefulWidget {
  const InsuranceReviewScreen({super.key});

  @override
  ConsumerState<InsuranceReviewScreen> createState() => _InsuranceReviewScreenState();
}

class _InsuranceReviewScreenState extends ConsumerState<InsuranceReviewScreen> {
  bool _showAppeals = false;

  @override
  Widget build(BuildContext context) {
    final allAuths = MockDataRepository.instance.authorizations;
    final allAppeals = MockDataRepository.instance.appeals;

    // Filtered lists for the queue
    final paQueue = allAuths.where((a) =>
        a.status == AuthorizationStatus.pending ||
        a.status == AuthorizationStatus.underReview ||
        a.status == AuthorizationStatus.escalated).toList();

    final appealsQueue = allAppeals.where((a) =>
        a.status == AppealStatus.submitted ||
        a.status == AppealStatus.underReview).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Reviewer Workspace',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _showAppeals
                        ? '${appealsQueue.length} clinical appeals awaiting review'
                        : '${paQueue.length} prior authorization requests awaiting decision',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Queue Toggle Tabs
          Row(
            children: [
              FilterChip(
                label: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.clipboardText, size: 16),
                    const SizedBox(width: 6),
                    Text('PA Requests (${paQueue.length})'),
                  ],
                ),
                selected: !_showAppeals,
                selectedColor: AppColors.primarySurface,
                checkmarkColor: AppColors.primary,
                onSelected: (selected) {
                  if (selected) setState(() => _showAppeals = false);
                },
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.gavel, size: 16),
                    const SizedBox(width: 6),
                    Text('Clinical Appeals (${appealsQueue.length})'),
                  ],
                ),
                selected: _showAppeals,
                selectedColor: AppColors.primarySurface,
                checkmarkColor: AppColors.primary,
                onSelected: (selected) {
                  if (selected) setState(() => _showAppeals = true);
                },
              ),
            ],
          ).animate(delay: 50.ms).fadeIn(),

          const SizedBox(height: 20),

          // List Content
          Expanded(
            child: _showAppeals
                ? (appealsQueue.isEmpty
                    ? _buildEmptyQueue('No appeals awaiting review.')
                    : ListView.separated(
                        itemCount: appealsQueue.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _buildAppealReviewCard(appealsQueue[i])
                            .animate(delay: Duration(milliseconds: 100 + i * 60))
                            .fadeIn()
                            .slideY(begin: 0.05),
                      ))
                : (paQueue.isEmpty
                    ? _buildEmptyQueue('No prior authorizations awaiting review.')
                    : ListView.separated(
                        itemCount: paQueue.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _buildPaReviewCard(paQueue[i])
                            .animate(delay: Duration(milliseconds: 100 + i * 60))
                            .fadeIn()
                            .slideY(begin: 0.05),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.neutral50, shape: BoxShape.circle),
            child: const Icon(PhosphorIconsRegular.checkSquare, size: 36, color: AppColors.neutral400),
          ),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('All clear! Catch up on other medical reviews.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        ],
      ),
    );
  }

  // ─── Prior Authorization Card Widget ───
  Widget _buildPaReviewCard(AuthorizationRequest auth) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
            color: auth.status == AuthorizationStatus.escalated
                ? AppColors.escalated.withOpacity(0.4)
                : AppColors.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: auth.status.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(auth.status.icon, size: 22, color: auth.status.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(auth.patientName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          if (auth.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                              child: const Text('URGENT',
                                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      Text('${auth.authNumber} · ${auth.requestingDoctorName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusPill(auth.status),
                    const SizedBox(height: 4),
                    Text(_timeAgo(auth.requestedAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _InfoChip('ICD-10', auth.diagnosisCode, AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(child: _InfoChip('CPT', auth.procedureCode, AppColors.accent)),
                const SizedBox(width: 8),
                Expanded(child: _InfoChip('Plan', auth.insurancePlanName.split(' ').first, AppColors.neutral600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusLg),
                bottomRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updatePaStatus(auth, AuthorizationStatus.approved, 'Approved during reviewer queue audit.'),
                    icon: const Icon(PhosphorIconsRegular.checkCircle, size: 14, color: AppColors.success),
                    label: const Text('Approve', style: TextStyle(color: AppColors.success, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.success.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectPaDialog(auth),
                    icon: const Icon(PhosphorIconsRegular.xCircle, size: 14, color: AppColors.error),
                    label: const Text('Reject', style: TextStyle(color: AppColors.error, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updatePaStatus(auth, AuthorizationStatus.escalated, 'Escalated to specialty clinical panel.'),
                    icon: const Icon(PhosphorIconsRegular.arrowsOut, size: 14, color: AppColors.escalated),
                    label: const Text('Escalate', style: TextStyle(color: AppColors.escalated, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.escalated.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Appeal Card Widget ───
  Widget _buildAppealReviewCard(AppealCase appeal) {
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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(PhosphorIconsRegular.gavel, size: 22, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(appeal.patientName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AI Overturn: ${(appeal.aiSuccessProbability * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Text('Appeal #${appeal.appealNumber} · Auth: ${appeal.authNumber}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusPill(AuthorizationStatus.underReview),
                    const SizedBox(height: 4),
                    Text(_timeAgo(appeal.filedAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grounds for Appeal:', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  appeal.groundsForAppeal,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusLg),
                bottomRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showReviewAppealDetailsDialog(appeal),
                icon: const Icon(PhosphorIconsRegular.fileText, size: 14),
                label: const Text('Review Appeal Case Details', style: TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dialog: Review Appeal Details ───
  void _showReviewAppealDetailsDialog(AppealCase appeal) {
    final originalAuth = MockDataRepository.instance.authorizations.firstWhere(
      (a) => a.id == appeal.authorizationId,
      orElse: () => MockDataRepository.instance.authorizations.first,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
        child: Container(
          width: 700,
          constraints: const BoxConstraints(maxHeight: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusXl),
                    topRight: Radius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.gavel, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Appeal Decision Center — #${appeal.appealNumber}',
                        style: Theme.of(dialogCtx).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
              ),

              // Scrollable Case Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Info Row
                      Row(
                        children: [
                          Expanded(
                            child: _detailField('Patient Name', appeal.patientName),
                          ),
                          Expanded(
                            child: _detailField('Auth ID Number', appeal.authNumber),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _detailField('Diagnosis (ICD-10)', '${originalAuth.diagnosisCode} — ${originalAuth.diagnosisDescription}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _detailField('Requested Procedure (CPT)', '${originalAuth.procedureCode} — ${originalAuth.procedureDescription}'),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Original Denial Reason
                      Text('Original Prior Auth Denial Notice',
                          style: Theme.of(dialogCtx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppColors.error.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              originalAuth.rejectionReason ?? 'Denial reason details not specified in initial review.',
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, height: 1.4),
                            ),
                            if (originalAuth.policyClauseCited != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Cited Policy Clause: ${originalAuth.policyClauseCited!}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Divider(height: 32),

                      // Grounds for appeal
                      Text('Grounds for Appeal & Doctor\'s Clinical Justification',
                          style: Theme.of(dialogCtx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appeal.groundsForAppeal,
                              style: const TextStyle(height: 1.5, color: AppColors.textPrimary),
                            ),
                            if (appeal.supportingEvidence != null && appeal.supportingEvidence!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Previous Treatments Conducted:',
                                style: Theme.of(dialogCtx).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appeal.supportingEvidence!,
                                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Divider(height: 32),

                      // AI Predictor widget
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(PhosphorIconsRegular.brain, color: AppColors.accent, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AI Appeal Success Probability Predictor',
                                          style: Theme.of(dialogCtx).textTheme.labelSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Confidence interval is estimated at ${((appeal.aiProbabilityLow ?? 0.5) * 100).toStringAsFixed(0)}% to ${((appeal.aiProbabilityHigh ?? 0.9) * 100).toStringAsFixed(0)}% success probability.',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(appeal.aiSuccessProbability * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: appeal.aiSuccessProbability >= 0.6 ? AppColors.success : AppColors.warning,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // Uploaded Documents Section
                      Text('Supporting Documents Attached',
                          style: Theme.of(dialogCtx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (appeal.documentIds.isEmpty)
                        Text(
                          'No documents were uploaded with this appeal.',
                          style: TextStyle(color: AppColors.textTertiary, fontStyle: FontStyle.italic, fontSize: 12),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: appeal.documentIds.map((docName) {
                            return InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Simulated Preview for file: $docName'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(PhosphorIconsRegular.filePdf, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      docName,
                                      style: const TextStyle(
                                          color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              // Actions Footer
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Close'),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _decideAppeal(dialogCtx, appeal, AppealStatus.overturned, 'Appeal approved and overturn decision registered.'),
                      icon: const Icon(PhosphorIconsRegular.checkCircle, size: 16),
                      label: const Text('Approve Appeal'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _decideAppeal(dialogCtx, appeal, AppealStatus.upheld, 'Appeal denied and rejection upheld.'),
                      icon: const Icon(PhosphorIconsRegular.xCircle, size: 16),
                      label: const Text('Uphold Denial'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _decideAppeal(dialogCtx, appeal, AppealStatus.underReview, 'Reviewer requested additional clinical notes.', isInfoRequest: true),
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('Request Info'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  // ─── Appeal Decision Action Method ───
  void _decideAppeal(BuildContext dialogCtx, AppealCase appeal, AppealStatus newStatus, String notes, {bool isInfoRequest = false}) {
    final user = ref.read(currentUserProvider);
    final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
        ? MockDataRepository.instance.auditLogs.last.entryHash 
        : 'f9e2d1c6b3a8';

    // 1. Update Appeal Case status
    final appIdx = MockDataRepository.instance.appeals.indexWhere((a) => a.id == appeal.id);
    if (appIdx != -1) {
      final old = MockDataRepository.instance.appeals[appIdx];
      MockDataRepository.instance.appeals[appIdx] = AppealCase(
        id: old.id,
        appealNumber: old.appealNumber,
        authorizationId: old.authorizationId,
        authNumber: old.authNumber,
        patientName: old.patientName,
        filedById: old.filedById,
        filedByName: old.filedByName,
        status: newStatus,
        filedAt: old.filedAt,
        decidedAt: DateTime.now(),
        groundsForAppeal: old.groundsForAppeal,
        supportingEvidence: old.supportingEvidence,
        aiSuccessProbability: old.aiSuccessProbability,
        aiProbabilityLow: old.aiProbabilityLow,
        aiProbabilityHigh: old.aiProbabilityHigh,
        draftAppealLetter: old.draftAppealLetter,
        documentIds: old.documentIds,
        rejectionReason: isInfoRequest ? 'Request Info: ' + notes : notes,
      );
    }

    // 2. Update parent Prior Authorization Request status
    final authIdx = MockDataRepository.instance.authorizations.indexWhere((a) => a.id == appeal.authorizationId);
    if (authIdx != -1) {
      final req = MockDataRepository.instance.authorizations[authIdx];
      
      // Determine what auth status maps to this appeal decision
      AuthorizationStatus finalAuthStatus;
      if (newStatus == AppealStatus.overturned) {
        finalAuthStatus = AuthorizationStatus.approved;
      } else if (newStatus == AppealStatus.upheld) {
        finalAuthStatus = AuthorizationStatus.rejected;
      } else {
        finalAuthStatus = AuthorizationStatus.underReview;
      }

      MockDataRepository.instance.authorizations[authIdx] = AuthorizationRequest(
        id: req.id,
        authNumber: req.authNumber,
        patientId: req.patientId,
        patientName: req.patientName,
        patientDob: req.patientDob,
        patientInsuranceId: req.patientInsuranceId,
        requestingDoctorId: req.requestingDoctorId,
        requestingDoctorName: req.requestingDoctorName,
        facilityName: req.facilityName,
        facilityNpi: req.facilityNpi,
        diagnosisCode: req.diagnosisCode,
        diagnosisDescription: req.diagnosisDescription,
        procedureCode: req.procedureCode,
        procedureDescription: req.procedureDescription,
        drugName: req.drugName,
        drugNdc: req.drugNdc,
        insurancePlanId: req.insurancePlanId,
        insurancePlanName: req.insurancePlanName,
        status: finalAuthStatus,
        priority: req.priority,
        requestedAt: req.requestedAt,
        reviewedAt: DateTime.now(),
        decidedAt: DateTime.now(),
        processingTimeMs: req.processingTimeMs,
        reviewerNotes: notes,
        rejectionReason: req.rejectionReason,
        policyClauseCited: req.policyClauseCited,
        documentIds: req.documentIds,
        aiDecisionId: req.aiDecisionId,
        isUrgent: req.isUrgent,
        slaStatus: req.slaStatus,
        dataSource: req.dataSource,
        cmsNpiNumber: req.cmsNpiNumber,
        cmsSpecialty: req.cmsSpecialty,
      );
    }

    // 3. Log Audit Trail
    MockDataRepository.instance.auditLogs.add(
      AuditLogEntry(
        id: 'log-$randomId',
        action: isInfoRequest ? 'appeal.info_requested' : 'appeal.decided',
        actorId: user?.id ?? 'usr-003',
        actorName: user?.name ?? 'Sarah Williams',
        actorRole: user?.role.displayName ?? 'Insurance Reviewer',
        resourceId: appeal.id,
        resourceType: 'AppealCase',
        description: 'Appeal case #${appeal.appealNumber} decided as: ${newStatus.statusLabel}. Note: $notes',
        timestamp: DateTime.now(),
        entryHash: 'e${randomId}h',
        previousHash: prevHash,
        ipAddress: '172.16.0.55',
        metadata: {
          'appeal_number': appeal.appealNumber,
          'status': newStatus.statusLabel,
          'notes': notes,
        },
      ),
    );

    // 4. Trigger notification
    MockDataRepository.instance.notifications.insert(
      0,
      AppNotification(
        id: 'notif-$randomId',
        title: isInfoRequest ? 'Appeal Info Request' : 'Appeal Case Decided',
        message: isInfoRequest 
            ? 'Additional clinical documents requested for Appeal #${appeal.appealNumber}.'
            : 'Appeal #${appeal.appealNumber} status updated to: ${newStatus.statusLabel}.',
        type: NotificationType.appeal,
        isRead: false,
        resourceId: appeal.id,
        resourceType: 'AppealCase',
        createdAt: DateTime.now(),
      ),
    );

    // Close dialog and rebuild workspace state
    Navigator.pop(dialogCtx);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isInfoRequest
              ? 'Request for additional clinical notes has been sent.'
              : 'Appeal case decision updated successfully to: ${newStatus.statusLabel}.',
        ),
        backgroundColor: isInfoRequest ? AppColors.warning : AppColors.success,
      ),
    );
  }

  // ─── Prior Authorization Status Action Method ───
  void _updatePaStatus(AuthorizationRequest auth, AuthorizationStatus finalStatus, String notes) {
    final user = ref.read(currentUserProvider);
    final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
        ? MockDataRepository.instance.auditLogs.last.entryHash 
        : 'f9e2d1c6b3a8';

    final authIdx = MockDataRepository.instance.authorizations.indexWhere((a) => a.id == auth.id);
    if (authIdx != -1) {
      MockDataRepository.instance.authorizations[authIdx] = AuthorizationRequest(
        id: auth.id,
        authNumber: auth.authNumber,
        patientId: auth.patientId,
        patientName: auth.patientName,
        patientDob: auth.patientDob,
        patientInsuranceId: auth.patientInsuranceId,
        requestingDoctorId: auth.requestingDoctorId,
        requestingDoctorName: auth.requestingDoctorName,
        facilityName: auth.facilityName,
        facilityNpi: auth.facilityNpi,
        diagnosisCode: auth.diagnosisCode,
        diagnosisDescription: auth.diagnosisDescription,
        procedureCode: auth.procedureCode,
        procedureDescription: auth.procedureDescription,
        drugName: auth.drugName,
        drugNdc: auth.drugNdc,
        insurancePlanId: auth.insurancePlanId,
        insurancePlanName: auth.insurancePlanName,
        status: finalStatus,
        priority: auth.priority,
        requestedAt: auth.requestedAt,
        reviewedAt: DateTime.now(),
        decidedAt: DateTime.now(),
        processingTimeMs: auth.processingTimeMs ?? 2000,
        reviewerNotes: notes,
        rejectionReason: auth.rejectionReason,
        policyClauseCited: auth.policyClauseCited,
        documentIds: auth.documentIds,
        aiDecisionId: auth.aiDecisionId,
        isUrgent: auth.isUrgent,
        slaStatus: auth.slaStatus,
        dataSource: auth.dataSource,
        cmsNpiNumber: auth.cmsNpiNumber,
        cmsSpecialty: auth.cmsSpecialty,
      );

      // Audit Log
      MockDataRepository.instance.auditLogs.add(
        AuditLogEntry(
          id: 'log-$randomId',
          action: finalStatus == AuthorizationStatus.approved ? 'authorization.approved' : 'authorization.escalated',
          actorId: user?.id ?? 'usr-003',
          actorName: user?.name ?? 'Sarah Williams',
          actorRole: user?.role.displayName ?? 'Insurance Reviewer',
          resourceId: auth.id,
          resourceType: 'AuthorizationRequest',
          description: 'Authorization Request ${auth.authNumber} changed to ${finalStatus.label}. Note: $notes',
          timestamp: DateTime.now(),
          entryHash: 'e${randomId}h',
          previousHash: prevHash,
          ipAddress: '172.16.0.55',
          metadata: {'auth_number': auth.authNumber, 'status': finalStatus.label},
        ),
      );

      // Notification
      MockDataRepository.instance.notifications.insert(
        0,
        AppNotification(
          id: 'notif-$randomId',
          title: 'Authorization Status Updated',
          message: 'Prior authorization request ${auth.authNumber} has been ${finalStatus.label}.',
          type: NotificationType.authorization,
          isRead: false,
          resourceId: auth.id,
          resourceType: 'AuthorizationRequest',
          createdAt: DateTime.now(),
        ),
      );

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prior authorization request updated successfully to: ${finalStatus.label}.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showRejectPaDialog(AuthorizationRequest auth) {
    final reasonController = TextEditingController();
    final policyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reject Authorization Request', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Rejection Reason',
                  hintText: 'e.g. Clinical indications do not support medical necessity.',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Rejection reason is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: policyController,
                decoration: const InputDecoration(
                  labelText: 'Cited Policy Clause (Optional)',
                  hintText: 'e.g. Policy §3.4.1',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final user = ref.read(currentUserProvider);
                final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                    ? MockDataRepository.instance.auditLogs.last.entryHash 
                    : 'f9e2d1c6b3a8';

                final authIdx = MockDataRepository.instance.authorizations.indexWhere((a) => a.id == auth.id);
                if (authIdx != -1) {
                  MockDataRepository.instance.authorizations[authIdx] = AuthorizationRequest(
                    id: auth.id,
                    authNumber: auth.authNumber,
                    patientId: auth.patientId,
                    patientName: auth.patientName,
                    patientDob: auth.patientDob,
                    patientInsuranceId: auth.patientInsuranceId,
                    requestingDoctorId: auth.requestingDoctorId,
                    requestingDoctorName: auth.requestingDoctorName,
                    facilityName: auth.facilityName,
                    facilityNpi: auth.facilityNpi,
                    diagnosisCode: auth.diagnosisCode,
                    diagnosisDescription: auth.diagnosisDescription,
                    procedureCode: auth.procedureCode,
                    procedureDescription: auth.procedureDescription,
                    drugName: auth.drugName,
                    drugNdc: auth.drugNdc,
                    insurancePlanId: auth.insurancePlanId,
                    insurancePlanName: auth.insurancePlanName,
                    status: AuthorizationStatus.rejected,
                    priority: auth.priority,
                    requestedAt: auth.requestedAt,
                    reviewedAt: DateTime.now(),
                    decidedAt: DateTime.now(),
                    processingTimeMs: auth.processingTimeMs ?? 2500,
                    reviewerNotes: reasonController.text.trim(),
                    rejectionReason: reasonController.text.trim(),
                    policyClauseCited: policyController.text.trim().isEmpty ? null : policyController.text.trim(),
                    documentIds: auth.documentIds,
                    aiDecisionId: auth.aiDecisionId,
                    isUrgent: auth.isUrgent,
                    slaStatus: auth.slaStatus,
                    dataSource: auth.dataSource,
                    cmsNpiNumber: auth.cmsNpiNumber,
                    cmsSpecialty: auth.cmsSpecialty,
                  );

                  // Audit Log
                  MockDataRepository.instance.auditLogs.add(
                    AuditLogEntry(
                      id: 'log-$randomId',
                      action: 'authorization.rejected',
                      actorId: user?.id ?? 'usr-003',
                      actorName: user?.name ?? 'Sarah Williams',
                      actorRole: user?.role.displayName ?? 'Insurance Reviewer',
                      resourceId: auth.id,
                      resourceType: 'AuthorizationRequest',
                      description: 'Authorization Request ${auth.authNumber} rejected. Reason: ${reasonController.text}',
                      timestamp: DateTime.now(),
                      entryHash: 'e${randomId}h',
                      previousHash: prevHash,
                      ipAddress: '172.16.0.55',
                      metadata: {'auth_number': auth.authNumber, 'reason': reasonController.text},
                    ),
                  );

                  // Notification
                  MockDataRepository.instance.notifications.insert(
                    0,
                    AppNotification(
                      id: 'notif-$randomId',
                      title: 'Prior Auth Request Rejected',
                      message: 'Prior authorization request ${auth.authNumber} has been rejected.',
                      type: NotificationType.authorization,
                      isRead: false,
                      resourceId: auth.id,
                      resourceType: 'AuthorizationRequest',
                      createdAt: DateTime.now(),
                    ),
                  );

                  Navigator.pop(dialogCtx);
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prior authorization request rejected successfully.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
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
        child: Text(status.label,
            style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: status.color, fontWeight: FontWeight.w600)),
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
          Text(label, style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

