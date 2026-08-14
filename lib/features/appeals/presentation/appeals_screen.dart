import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../repositories/data_repository.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppealsScreen extends ConsumerStatefulWidget {
  const AppealsScreen({super.key});

  @override
  ConsumerState<AppealsScreen> createState() => _AppealsScreenState();
}

class _AppealsScreenState extends ConsumerState<AppealsScreen> {
  @override
  Widget build(BuildContext context) {
    final appeals = MockDataRepository.instance.appeals;

    // Dynamically calculate statistics from the appeals list
    final totalFiled = appeals.length;
    final overturnedCount = appeals.where((a) => a.status == AppealStatus.overturned).length;
    final underReviewCount = appeals.where((a) => a.status == AppealStatus.underReview || a.status == AppealStatus.submitted).length;
    final avgSuccessProb = appeals.isEmpty 
        ? 0.0 
        : (appeals.map((a) => a.aiSuccessProbability).reduce((a, b) => a + b) / appeals.length);

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
                onPressed: _showFileAppealDialog,
                icon: const Icon(PhosphorIconsRegular.plusCircle, size: 16),
                label: const Text('File Appeal'),
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Summary row
          Row(children: [
            _AppealStat('Total Filed', '$totalFiled', AppColors.primary),
            const SizedBox(width: 12),
            _AppealStat('Overturned', '$overturnedCount', AppColors.success),
            const SizedBox(width: 12),
            _AppealStat('Under Review', '$underReviewCount', AppColors.warning),
            const SizedBox(width: 12),
            _AppealStat('AI Prediction', '${(avgSuccessProb * 100).toStringAsFixed(1)}%', AppColors.accent),
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

  void _showFileAppealDialog() {
    final formKey = GlobalKey<FormState>();
    final rejectedRequests = MockDataRepository.instance.authorizations
        .where((a) => a.status == AuthorizationStatus.rejected)
        .toList();
        
    // In case there are no rejected requests in mock data, show all requests for demo robustness
    final requestsToDisplay = rejectedRequests.isNotEmpty 
        ? rejectedRequests 
        : MockDataRepository.instance.authorizations;

    AuthorizationRequest? selectedRequest = requestsToDisplay.isNotEmpty ? requestsToDisplay.first : null;
    final groundsController = TextEditingController();
    final treatmentController = TextEditingController();
    final List<String> mockDocuments = [];
    bool isAnalyzing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (isAnalyzing) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowLg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'AI Analyzing Denial & Justification...',
                      style: Theme.of(ctx).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Retrieving clinical guidelines, matching policy clauses, and drafting appeal letter...',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXl)),
            child: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 750),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
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
                        Text(
                          'File New Clinical Appeal',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(dialogCtx),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Denied Prior Authorization',
                              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<AuthorizationRequest>(
                              value: selectedRequest,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(PhosphorIconsRegular.clipboardText, size: 20),
                              ),
                              items: requestsToDisplay.map((req) {
                                return DropdownMenuItem(
                                  value: req,
                                  child: Text('${req.patientName} — ${req.authNumber} (${req.procedureCode})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedRequest = val;
                                });
                              },
                              validator: (v) => v == null ? 'Please select an authorization' : null,
                            ),
                            if (selectedRequest != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorLight.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Denial Reason: ${selectedRequest!.rejectionReason ?? "No reason specified"}',
                                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                                    ),
                                    if (selectedRequest!.policyClauseCited != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Policy Clause: ${selectedRequest!.policyClauseCited!}',
                                        style: Theme.of(ctx).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),
                            Text(
                              'Grounds for Appeal / Clinical Justification',
                              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: groundsController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'State why the denial should be overturned. Reference clinical indicators, symptoms progression, and why the procedure is medically necessary.',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter the appeal justification grounds' : null,
                            ),

                            const SizedBox(height: 20),
                            Text(
                              'Previous Treatments & Outcomes',
                              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: treatmentController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 6 weeks physical therapy, NSAIDs trial (Naproxen 500mg BID) completed with no improvement.',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter details of previous treatments' : null,
                            ),

                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Supporting Medical Documents',
                                  style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    final docNameController = TextEditingController();
                                    showDialog(
                                      context: ctx,
                                      builder: (fileCtx) => AlertDialog(
                                        title: const Text('Add Document Reference', style: TextStyle(fontWeight: FontWeight.w700)),
                                        content: TextFormField(
                                          controller: docNameController,
                                          decoration: const InputDecoration(
                                            labelText: 'File Name',
                                            hintText: 'e.g., physical_therapy_report.pdf',
                                          ),
                                          autofocus: true,
                                        ),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(fileCtx), child: const Text('Cancel')),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (docNameController.text.trim().isNotEmpty) {
                                                setDialogState(() {
                                                  mockDocuments.add(docNameController.text.trim());
                                                });
                                              }
                                              Navigator.pop(fileCtx);
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text('Add File'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (mockDocuments.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral50,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                                ),
                                child: Center(
                                  child: Text(
                                    'No supporting documents attached.',
                                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: mockDocuments.length,
                                itemBuilder: (fCtx, fIdx) => Card(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  elevation: 0,
                                  color: AppColors.primarySurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    side: BorderSide(color: AppColors.primary.withOpacity(0.12)),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: const Icon(PhosphorIconsRegular.filePdf, color: AppColors.primary),
                                    title: Text(mockDocuments[fIdx], style: const TextStyle(fontWeight: FontWeight.w600)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                                      onPressed: () {
                                        setDialogState(() {
                                          mockDocuments.removeAt(fIdx);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Actions footer
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate() && selectedRequest != null) {
                              setDialogState(() {
                                isAnalyzing = true;
                              });

                              // 1. Gather feature values for ML inference
                              int patientAge = 45;
                              try {
                                if (selectedRequest!.patientDob.isNotEmpty) {
                                  final dob = DateTime.parse(selectedRequest!.patientDob);
                                  patientAge = DateTime.now().year - dob.year;
                                }
                              } catch (_) {}

                              final decisions = MockDataRepository.instance.aiDecisions;
                              final decision = selectedRequest!.aiDecisionId != null &&
                                      decisions.any((d) => d.id == selectedRequest!.aiDecisionId)
                                  ? decisions.firstWhere((d) => d.id == selectedRequest!.aiDecisionId)
                                  : null;
                              final medicalNecessity = ((decision?.medicalNecessityScore ?? 0.75) * 100).toInt();

                              final Map<String, dynamic> mlPayload = {
                                "patient_age": patientAge,
                                "procedure": selectedRequest!.procedureDescription,
                                "denial_reason": selectedRequest!.rejectionReason ?? 'Not Medically Necessary',
                                "medical_necessity_score": medicalNecessity,
                                "documentation_completeness_pct": 85,
                                "patient_severity": "Medium",
                                "previous_treatment_failed": "Yes",
                                "clinical_guideline_match": (decision?.medicalNecessityScore ?? 0.7) >= 0.7 ? 'Yes' : 'No',
                                "previous_authorization_history": "No Prior Request",
                              };

                              double prob = 0.71;
                              double low = 0.58;
                              double high = 0.96;

                              // 2. Query the ML microservice on AWS / Localhost
                              try {
                                final dio = Dio(BaseOptions(
                                  connectTimeout: const Duration(seconds: 4),
                                  receiveTimeout: const Duration(seconds: 4),
                                ));
                                final response = await dio.post(
                                  AppConstants.appealMlEndpoint,
                                  data: mlPayload,
                                  options: Options(
                                    headers: {
                                      'Authorization': 'Bearer dev-key-12345',
                                    },
                                  ),
                                );
                                if (response.statusCode == 200 && response.data != null) {
                                  final data = response.data as Map<String, dynamic>;
                                  if (data['success'] == true) {
                                    final pred = data['prediction'] as Map<String, dynamic>;
                                    prob = (pred['success_probability'] as num).toDouble();
                                    low = (pred['confidence_low'] as num).toDouble();
                                    high = (pred['confidence_high'] as num).toDouble();
                                  }
                                }
                              } catch (e) {
                                debugPrint("ML prediction failed, using fallback: $e");
                                // Fallback to offline / deterministic mock
                                prob = 0.65 + (DateTime.now().millisecond % 30) / 100.0;
                                low = prob - 0.1;
                                high = prob + 0.15;
                              }

                              if (!dialogCtx.mounted) return;

                              // 3. Add appeal case to repository
                              final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                              final appealNum = 'APL-2024-0${randomId}';
                              
                              final newAppeal = AppealCase(
                                id: 'appeal-$randomId',
                                appealNumber: appealNum,
                                authorizationId: selectedRequest!.id,
                                authNumber: selectedRequest!.authNumber,
                                patientName: selectedRequest!.patientName,
                                filedById: 'usr-006', // Mock Current Hospital Admin
                                filedByName: 'Sarah Jenkins',
                                status: AppealStatus.submitted,
                                filedAt: DateTime.now(),
                                groundsForAppeal: groundsController.text.trim(),
                                supportingEvidence: treatmentController.text.trim(),
                                aiSuccessProbability: prob,
                                aiProbabilityLow: low,
                                aiProbabilityHigh: high,
                                documentIds: mockDocuments,
                                draftAppealLetter: _generateMockAppealLetter(
                                  selectedRequest!,
                                  groundsController.text.trim(),
                                  treatmentController.text.trim(),
                                  mockDocuments,
                                ),
                              );

                              MockDataRepository.instance.appeals.insert(0, newAppeal);

                               // Persist to typed Supabase appeals table
                               final appealMap = {
                                 'id': 'appeal-$randomId',
                                 'appeal_number': appealNum,
                                 'authorization_id': selectedRequest!.id,
                                 'auth_number': selectedRequest!.authNumber,
                                 'patient_name': selectedRequest!.patientName,
                                 'filed_by_id': 'usr-006', // Mock Current Hospital Admin ID
                                 'filed_by_name': 'Sarah Jenkins',
                                 'status': 'submitted',
                                 'filed_at': DateTime.now().toIso8601String(),
                                 'decided_at': null,
                                 'grounds_for_appeal': groundsController.text.trim(),
                                 'supporting_evidence': treatmentController.text.trim(),
                                 'ai_success_probability': prob,
                                 'ai_probability_low': low,
                                 'ai_probability_high': high,
                                 'draft_appeal_letter': newAppeal.draftAppealLetter,
                                 'rejection_reason': null,
                                 'document_ids': mockDocuments,
                               };

                               try {
                                 final client = Supabase.instance.client;
                                 await client.from('appeals').insert(appealMap);
                                 debugPrint("Successfully inserted appeal into Supabase typed table.");
                               } catch (dbErr) {
                                 debugPrint("Error writing appeal to Supabase typed table: $dbErr");
                               }

                              // 4. Update authorization status to underReview
                              final idx = MockDataRepository.instance.authorizations
                                  .indexWhere((a) => a.id == selectedRequest!.id);
                              if (idx != -1) {
                                final req = MockDataRepository.instance.authorizations[idx];
                                MockDataRepository.instance.authorizations[idx] = AuthorizationRequest(
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
                                  status: AuthorizationStatus.underReview,
                                  priority: req.priority,
                                  requestedAt: req.requestedAt,
                                  reviewedAt: DateTime.now(),
                                  decidedAt: req.decidedAt,
                                  processingTimeMs: req.processingTimeMs,
                                  reviewerNotes: 'Appeal submitted. Re-evaluating decision.',
                                  rejectionReason: req.rejectionReason,
                                  policyClauseCited: req.policyClauseCited,
                                  documentIds: [...req.documentIds, ...mockDocuments],
                                  aiDecisionId: req.aiDecisionId,
                                  isUrgent: req.isUrgent,
                                  slaStatus: req.slaStatus,
                                  dataSource: req.dataSource,
                                  cmsNpiNumber: req.cmsNpiNumber,
                                  cmsSpecialty: req.cmsSpecialty,
                                );
                              }

                              // 5. Log Audit Trail
                              final prevHash = MockDataRepository.instance.auditLogs.isNotEmpty 
                                  ? MockDataRepository.instance.auditLogs.last.entryHash 
                                  : 'f9e2d1c6b3a8';
                              MockDataRepository.instance.auditLogs.add(
                                AuditLogEntry(
                                  id: 'log-$randomId',
                                  action: 'appeal.filed',
                                  actorId: 'usr-006',
                                  actorName: 'Sarah Jenkins',
                                  actorRole: 'Hospital Admin',
                                  resourceId: 'appeal-$randomId',
                                  resourceType: 'AppealCase',
                                  description: 'Appeal $appealNum filed for auth ${selectedRequest!.authNumber} (Patient: ${selectedRequest!.patientName})',
                                  timestamp: DateTime.now(),
                                  entryHash: 'e${randomId}h',
                                  previousHash: prevHash,
                                  ipAddress: '192.168.1.100',
                                  metadata: {
                                    'appeal_number': appealNum,
                                    'auth_number': selectedRequest!.authNumber,
                                    'grounds': groundsController.text.trim(),
                                  },
                                ),
                              );

                              // Close dialog, update parent widget state
                              Navigator.pop(dialogCtx);
                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Appeal case $appealNum has been filed and submitted to AI review.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                          icon: const Icon(PhosphorIconsRegular.paperPlaneRight, size: 16),
                          label: const Text('File Appeal'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _generateMockAppealLetter(
    AuthorizationRequest request,
    String grounds,
    String treatments,
    List<String> documents,
  ) {
    final dateStr = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final docList = documents.isEmpty 
        ? '- Clinical documentation of failed therapy (Exhibit A)'
        : documents.asMap().entries.map((e) => '- Exhibit ${String.fromCharCode(65 + e.key)}: ${e.value}').join('\n');

    return '''
$dateStr

${request.insurancePlanName}
Appeals Department
P.O. Box 10000

RE: APPEAL OF PRIOR AUTHORIZATION DENIAL
Patient: ${request.patientName} | DOB: ${request.patientDob}
Claim/Auth Number: ${request.authNumber}
Insurance ID: ${request.patientInsuranceId}
Treating Physician: ${request.requestingDoctorName} (NPI: ${request.facilityNpi})

Dear Appeals Committee,

I am writing to formally appeal the denial of prior authorization ${request.authNumber} for ${request.procedureDescription} (CPT: ${request.procedureCode}) for the above-referenced patient.

REASON FOR DENIAL (as stated in denial notice):
"${request.rejectionReason ?? "Medical necessity criteria not met."}" ${request.policyClauseCited != null ? '[Policy ' + request.policyClauseCited! + ']' : ''}

GROUNDS FOR APPEAL:
1. Medical Necessity & Grounds:
$grounds

2. Conservative Treatments Completed:
$treatments

3. Guideline Alignment:
The requested procedure is strongly indicated for the patient\'s diagnosis of ${request.diagnosisDescription} (ICD-10: ${request.diagnosisCode}) and matches standard peer-reviewed clinical guidelines.

SUPPORTING DOCUMENTATION (Attached):
$docList

We respectfully request an expedited review of this case to ensure the patient receives the necessary standard of care.

Sincerely,

Sarah Jenkins
Hospital Admin (on behalf of ${request.requestingDoctorName})
${request.facilityName}
''';
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

