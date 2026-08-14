import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/models.dart';
import '../../../repositories/data_repository.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;

class CreateAuthorizationScreen extends ConsumerStatefulWidget {
  const CreateAuthorizationScreen({super.key});

  @override
  ConsumerState<CreateAuthorizationScreen> createState() => _CreateAuthorizationScreenState();
}

class _CreateAuthorizationScreenState extends ConsumerState<CreateAuthorizationScreen> {
  int _step = 0;
  final _steps = ['Patient', 'Diagnosis', 'Procedure', 'Insurance', 'Review'];

  // Patient fields
  final nameCtrl = TextEditingController(text: '');
  final dobCtrl = TextEditingController(text: '');
  final memberIdCtrl = TextEditingController(text: '');
  final mrnCtrl = TextEditingController(text: '');

  // Diagnosis fields
  final icdCodeCtrl = TextEditingController(text: '');
  final diagDescCtrl = TextEditingController(text: '');
  final notesCtrl = TextEditingController(text: '');

  // Procedure fields
  final cptCtrl = TextEditingController(text: '');
  final procDescCtrl = TextEditingController(text: '');
  final dateCtrl = TextEditingController(text: '');
  final facilityNpiCtrl = TextEditingController(text: '');

  // Insurance fields
  final planCtrl = TextEditingController(text: '');
  final groupCtrl = TextEditingController(text: '');
  final docNpiCtrl = TextEditingController(text: '');
  String _priority = 'Routine';

  bool _isAnalyzing = false;
  String? _uploadedFileName;
  List<int>? _uploadedFileBytes;

  @override
  void dispose() {
    nameCtrl.dispose();
    dobCtrl.dispose();
    memberIdCtrl.dispose();
    mrnCtrl.dispose();
    icdCodeCtrl.dispose();
    diagDescCtrl.dispose();
    notesCtrl.dispose();
    cptCtrl.dispose();
    procDescCtrl.dispose();
    dateCtrl.dispose();
    facilityNpiCtrl.dispose();
    planCtrl.dispose();
    groupCtrl.dispose();
    docNpiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyzeClinicalNote() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'txt'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final name = file.name;
        
        List<int> bytes;
        if (kIsWeb) {
          if (file.bytes != null) {
            bytes = file.bytes!;
          } else {
            throw Exception("Could not read file bytes on web.");
          }
        } else {
          if (file.path != null) {
            final ioFile = io.File(file.path!);
            bytes = await ioFile.readAsBytes();
          } else if (file.bytes != null) {
            bytes = file.bytes!;
          } else {
            throw Exception("Could not read file path or bytes.");
          }
        }

        setState(() {
          _isAnalyzing = true;
          _uploadedFileName = name;
          _uploadedFileBytes = bytes;
        });

        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: name),
          'service_type': 'MRI',
        });

        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

        final response = await dio.post(
          AppConstants.priorAuthEndpoint,
          data: formData,
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final extInfo = data['extracted_info'] as Map<String, dynamic>?;
          
          if (extInfo != null) {
            setState(() {
              if (extInfo['diagnosis'] != null && extInfo['diagnosis'] != 'N/A') {
                diagDescCtrl.text = extInfo['diagnosis'].toString();
              }
              if (extInfo['diagnosis_code'] != null && extInfo['diagnosis_code'] != 'N/A') {
                icdCodeCtrl.text = extInfo['diagnosis_code'].toString();
              }
              if (extInfo['procedure_name'] != null && extInfo['procedure_name'] != 'N/A') {
                procDescCtrl.text = extInfo['procedure_name'].toString();
              }
              if (extInfo['procedure_code'] != null && extInfo['procedure_code'] != 'N/A') {
                cptCtrl.text = extInfo['procedure_code'].toString();
              }
              if (extInfo['urgency'] != null && extInfo['urgency'] != 'N/A') {
                final u = extInfo['urgency'].toString().toLowerCase();
                if (u.contains('urg')) _priority = 'Urgent';
                else if (u.contains('emerg')) _priority = 'Emergent';
                else if (u.contains('stat')) _priority = 'STAT';
                else _priority = 'Routine';
              }
              if (extInfo['chronic_condition'] != null && extInfo['chronic_condition'] != 'N/A') {
                notesCtrl.text = 'Clinical Notes: Primary chronic condition - ${extInfo['chronic_condition']}.';
              }
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Document uploaded! AI successfully extracted patient clinical criteria.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          throw Exception("Server returned code ${response.statusCode}");
        }
      }
    } catch (e) {
      debugPrint("AWS Document Analysis failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI Analysis failed, but you can fill fields manually: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  List<int> _getPayloadFileBytes() {
    if (_uploadedFileBytes != null) {
      return _uploadedFileBytes!;
    }
    
    final docText = '''
    Patient Name: ${nameCtrl.text}
    Date of Birth: ${dobCtrl.text}
    Member ID: ${memberIdCtrl.text}
    MRN: ${mrnCtrl.text}
    ICD-10 Code: ${icdCodeCtrl.text}
    Diagnosis Description: ${diagDescCtrl.text}
    CPT Code: ${cptCtrl.text}
    Procedure Description: ${procDescCtrl.text}
    Scheduled Date: ${dateCtrl.text}
    Facility NPI: ${facilityNpiCtrl.text}
    Insurance Plan: ${planCtrl.text}
    Group Number: ${groupCtrl.text}
    Requesting Physician NPI: ${docNpiCtrl.text}
    Priority: $_priority
    Clinical Notes: ${notesCtrl.text}
    ''';
    
    return utf8.encode(docText);
  }

  void _submitRequest() {
    final currentUser = ref.read(currentUserProvider);
    final bytes = _getPayloadFileBytes();
    final filename = _uploadedFileName ?? 'clinical_note.txt';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        bool isLoading = true;
        String progressMsg = 'Submitting request to insurance payer...';
        String? errorMsg;
        AuthorizationRequest? createdAuth;
        AiDecision? createdDecision;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isLoading && errorMsg == null && createdAuth == null) {
              Future.microtask(() async {
                try {
                  setDialogState(() {
                    progressMsg = 'AI is evaluating clinical document against CMS guidelines...';
                  });

                  final formData = FormData.fromMap({
                    'file': MultipartFile.fromBytes(bytes, filename: filename),
                    'service_type': 'MRI',
                  });

                  final dio = Dio(BaseOptions(
                    connectTimeout: const Duration(seconds: 15),
                    receiveTimeout: const Duration(seconds: 15),
                  ));

                  final response = await dio.post(
                    AppConstants.priorAuthEndpoint,
                    data: formData,
                  );

                  if (response.statusCode == 200 && response.data != null) {
                    final data = response.data as Map<String, dynamic>;
                    final extInfo = data['extracted_info'] as Map<String, dynamic>? ?? {};
                    
                    final apiDecision = data['decision']?.toString() ?? 'HUMAN_REVIEW';
                    final apiConfidence = (data['ml_confidence'] as num?)?.toDouble() ?? 0.85;
                    final necessityScore = (extInfo['medical_necessity_score'] as num?)?.toDouble() ?? 75.0;
                    final apiReason = data['reason']?.toString() ?? 'Requires clinical review Coordinator.';
                    final apiProcessingTime = (data['processing_time'] as num?)?.toDouble() ?? 1.25;
                    final ruleEvals = data['rule_evaluations'] as List<dynamic>? ?? [];

                    final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
                    final authNum = 'PA-2024-0$randomId';
                    final authId = 'auth-$randomId';

                    AuthorizationStatus status;
                    if (apiDecision == 'APPROVED' || apiDecision == 'Approved') {
                      status = AuthorizationStatus.approved;
                    } else if (apiDecision == 'DENIED' || apiDecision == 'Rejected' || apiDecision == 'Rejected') {
                      status = AuthorizationStatus.rejected;
                    } else {
                      status = AuthorizationStatus.underReview;
                    }

                    final List<AiReasoningStep> reasoningChain = [];
                    int stepNum = 1;
                    for (var r in ruleEvals) {
                      final rule = r as Map<String, dynamic>;
                      final passed = rule['status'] == 'SATISFIED';
                      reasoningChain.add(
                        AiReasoningStep(
                          stepNumber: stepNum++,
                          title: '${rule['rule_id']}: ${rule['criterion']}',
                          description: rule['evidence'] ?? '',
                          citedValue: rule['service'] ?? 'MRI',
                          policyRef: '${rule['source']} (${rule['source_id']})',
                          dataSource: rule['source'] ?? 'CMS LCD/NCD guidelines',
                          passed: passed,
                          score: passed ? 1.0 : (rule['status'] == 'NEEDS_REVIEW' ? 0.3 : 0.0),
                          details: [rule['evidence'] ?? ''],
                        )
                      );
                    }

                    createdDecision = AiDecision(
                      id: 'decision-$randomId',
                      authorizationId: authId,
                      recommendation: apiDecision.toLowerCase().contains('approve')
                          ? 'approve'
                          : (apiDecision.toLowerCase().contains('deny') || apiDecision.toLowerCase().contains('reject')
                              ? 'reject'
                              : 'escalate'),
                      confidenceScore: apiConfidence,
                      medicalNecessityScore: necessityScore / 100.0,
                      riskScore: 0.12,
                      appealLikelihood: 0.61,
                      reasoningChain: reasoningChain,
                      finalJustification: apiReason,
                      processedAt: DateTime.now(),
                      processingTimeMs: (apiProcessingTime * 1000).toInt(),
                      modelVersion: 'CMS-GPT-v2.1',
                      autoEscalated: apiConfidence < 0.90,
                      fraudSignals: {'billing_anomaly': 0.05, 'unnecessary_duplication': 0.02},
                    );

                    createdAuth = AuthorizationRequest(
                      id: authId,
                      authNumber: authNum,
                      patientId: 'pat-009',
                      patientName: nameCtrl.text.trim(),
                      patientDob: dobCtrl.text.trim(),
                      patientInsuranceId: memberIdCtrl.text.trim(),
                      requestingDoctorId: currentUser?.id ?? 'doc-002',
                      requestingDoctorName: currentUser?.name ?? 'Dr. Michael Johnson',
                      facilityName: 'MediAuth Medical Center',
                      facilityNpi: facilityNpiCtrl.text.trim(),
                      diagnosisCode: icdCodeCtrl.text.trim(),
                      diagnosisDescription: diagDescCtrl.text.trim(),
                      procedureCode: cptCtrl.text.trim(),
                      procedureDescription: procDescCtrl.text.trim(),
                      insurancePlanId: 'plan-001',
                      insurancePlanName: planCtrl.text.trim(),
                      status: status,
                      priority: _priority == 'Urgent'
                          ? AuthorizationPriority.urgent
                          : (_priority == 'Emergent'
                              ? AuthorizationPriority.emergent
                              : (_priority == 'STAT'
                                  ? AuthorizationPriority.stat
                                  : AuthorizationPriority.routine)),
                      requestedAt: DateTime.now(),
                      reviewedAt: DateTime.now(),
                      decidedAt: DateTime.now(),
                      processingTimeMs: (apiProcessingTime * 1000).toInt(),
                      reviewerNotes: apiReason,
                      policyClauseCited: reasoningChain.isNotEmpty ? reasoningChain.first.policyRef : 'General CMS LCD guidelines',
                      aiDecisionId: createdDecision!.id,
                      slaStatus: 'within_sla',
                      dataSource: 'CMS Guidelines',
                    );

                    MockDataRepository.instance.aiDecisions.insert(0, createdDecision!);
                    MockDataRepository.instance.authorizations.insert(0, createdAuth!);

                    // Persist to typed Supabase tables in the background
                    final authMap = {
                      'id': authId,
                      'auth_number': authNum,
                      'patient_id': 'pat-009',
                      'patient_name': nameCtrl.text.trim(),
                      'patient_dob': dobCtrl.text.trim(),
                      'patient_insurance_id': memberIdCtrl.text.trim(),
                      'requesting_doctor_id': currentUser?.id ?? 'doc-002',
                      'requesting_doctor_name': currentUser?.name ?? 'Dr. Michael Johnson',
                      'facility_name': 'MediAuth Medical Center',
                      'facility_npi': facilityNpiCtrl.text.trim(),
                      'diagnosis_code': icdCodeCtrl.text.trim(),
                      'diagnosis_description': diagDescCtrl.text.trim(),
                      'procedure_code': cptCtrl.text.trim(),
                      'procedure_description': procDescCtrl.text.trim(),
                      'insurance_plan_id': 'plan-001',
                      'insurance_plan_name': planCtrl.text.trim(),
                      'status': status.name,
                      'priority': _priority.toLowerCase(),
                      'requested_at': DateTime.now().toIso8601String(),
                      'reviewed_at': DateTime.now().toIso8601String(),
                      'decided_at': DateTime.now().toIso8601String(),
                      'processing_time_ms': (apiProcessingTime * 1000).toInt(),
                      'reviewer_notes': apiReason,
                      'rejection_reason': null,
                      'policy_clause_cited': reasoningChain.isNotEmpty ? reasoningChain.first.policyRef : 'General CMS guidelines',
                      'document_ids': [],
                      'ai_decision_id': createdDecision!.id,
                      'is_urgent': _priority == 'Urgent' || _priority == 'Emergent',
                      'sla_status': 'within_sla',
                      'data_source': 'CMS Guidelines',
                    };

                    final decisionMap = {
                      'id': createdDecision!.id,
                      'authorization_id': authId,
                      'recommendation': createdDecision!.recommendation,
                      'confidence_score': createdDecision!.confidenceScore,
                      'medical_necessity_score': createdDecision!.medicalNecessityScore,
                      'risk_score': createdDecision!.riskScore,
                      'appeal_likelihood': createdDecision!.appealLikelihood,
                      'appeal_confidence_low': createdDecision!.appealConfidenceLow,
                      'appeal_confidence_high': createdDecision!.appealConfidenceHigh,
                      'auto_escalated': createdDecision!.autoEscalated,
                      'reasoning_chain': reasoningChain.map((s) => {
                        'stepNumber': s.stepNumber,
                        'title': s.title,
                        'description': s.description,
                        'citedValue': s.citedValue,
                        'policyRef': s.policyRef,
                        'dataSource': s.dataSource,
                        'passed': s.passed,
                        'score': s.score,
                        'details': s.details,
                      }).toList(),
                      'final_justification': createdDecision!.finalJustification,
                      'processed_at': DateTime.now().toIso8601String(),
                      'processing_time_ms': createdDecision!.processingTimeMs,
                      'model_version': createdDecision!.modelVersion,
                      'fraud_signals': createdDecision!.fraudSignals,
                    };

                    try {
                      final client = Supabase.instance.client;
                      await client.from('authorizations').insert(authMap);
                      await client.from('ai_decisions').insert(decisionMap);
                      debugPrint("Successfully inserted auth and decision into Supabase typed tables.");
                    } catch (dbErr) {
                      debugPrint("Error writing to Supabase typed tables: $dbErr");
                    }

                    setDialogState(() {
                      isLoading = false;
                    });
                  } else {
                    throw Exception("API call returned status ${response.statusCode}");
                  }
                } catch (e) {
                  debugPrint("Prior Auth submission failed: $e");
                  setDialogState(() {
                    isLoading = false;
                    errorMsg = e.toString();
                  });
                }
              });
            }

            if (isLoading) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      progressMsg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            if (errorMsg != null) {
              return AlertDialog(
                title: const Text('Submission Failed'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text('An error occurred during AI clinical analysis:\n\n$errorMsg'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Dismiss'),
                  ),
                ],
              );
            }

            final decisionColor = createdAuth!.status.color;
            final decisionLabel = createdAuth!.status.label;

            return AlertDialog(
              title: const Text('Authorization Processed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: createdAuth!.status.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: decisionColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(createdAuth!.status.icon, color: decisionColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          decisionLabel.toUpperCase(),
                          style: TextStyle(color: decisionColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Auth Number: ${createdAuth!.authNumber}',
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Confidence: ${(createdDecision!.confidenceScore * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Medical Necessity Score: ${(createdDecision!.medicalNecessityScore * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    createdDecision!.finalJustification,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogCtx);
                    setState(() {
                      _step = 0;
                      _uploadedFileBytes = null;
                      _uploadedFileName = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Prior Authorization request ${createdAuth!.authNumber} created successfully.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Prior Authorization Request',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))
              .animate().fadeIn(),

          const SizedBox(height: 8),
          Text('Complete all steps to submit your prior authorization request.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary))
              .animate(delay: 100.ms).fadeIn(),

          const SizedBox(height: 28),

          _StepIndicator(currentStep: _step, steps: _steps)
              .animate(delay: 150.ms).fadeIn().slideY(begin: -0.1),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.border),
              boxShadow: AppTheme.shadowSm,
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_steps[_step],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Step ${_step + 1} of ${_steps.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    if (_step == 0)
                      TextButton.icon(
                        onPressed: _isAnalyzing ? null : _pickAndAnalyzeClinicalNote,
                        icon: _isAnalyzing
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                            : const Icon(PhosphorIconsRegular.uploadSimple, size: 14),
                        label: Text(_isAnalyzing ? 'Analyzing Note...' : 'Auto-fill with AI Note Upload', style: const TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                  ],
                ),
                if (_step == 0 && _uploadedFileName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file_rounded, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Analyzed: $_uploadedFileName',
                          style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildStepContent(_step),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_step > 0)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _step--),
                        icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 16),
                        label: const Text('Back'),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_step < _steps.length - 1) {
                          setState(() => _step++);
                        } else {
                          _submitRequest();
                        }
                      },
                      icon: Icon(
                        _step == _steps.length - 1
                            ? PhosphorIconsRegular.paperPlaneRight
                            : PhosphorIconsRegular.arrowRight,
                        size: 16,
                      ),
                      label: Text(_step == _steps.length - 1 ? 'Submit Request' : 'Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.05),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _PatientStep(
          nameCtrl: nameCtrl,
          dobCtrl: dobCtrl,
          memberIdCtrl: memberIdCtrl,
          mrnCtrl: mrnCtrl,
        );
      case 1:
        return _DiagnosisStep(
          icdCodeCtrl: icdCodeCtrl,
          diagDescCtrl: diagDescCtrl,
          notesCtrl: notesCtrl,
        );
      case 2:
        return _ProcedureStep(
          cptCtrl: cptCtrl,
          procDescCtrl: procDescCtrl,
          dateCtrl: dateCtrl,
          facilityNpiCtrl: facilityNpiCtrl,
        );
      case 3:
        return _InsuranceStep(
          planCtrl: planCtrl,
          groupCtrl: groupCtrl,
          docNpiCtrl: docNpiCtrl,
          priority: _priority,
          onChangedPriority: (val) {
            if (val != null) {
              setState(() => _priority = val);
            }
          },
        );
      case 4:
        return _ReviewStep(
          patient: '${nameCtrl.text} (DOB: ${dobCtrl.text})',
          diagnosis: '${icdCodeCtrl.text} — ${diagDescCtrl.text}',
          procedure: 'CPT ${cptCtrl.text} — ${procDescCtrl.text}',
          insurance: planCtrl.text,
          priority: _priority,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  const _StepIndicator({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final label = e.value;
        final isDone = i < currentStep;
        final isCurrent = i == currentStep;
        final color = isDone || isCurrent ? AppColors.primary : AppColors.neutral300;
        return Expanded(
          child: Row(
            children: [
              Column(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary : (isCurrent ? AppColors.primarySurface : AppColors.neutral100),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : Text('${i + 1}',
                            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 9 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
              if (i < steps.length - 1)
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    height: 2,
                    color: i < currentStep ? AppColors.primary : AppColors.neutral200,
                  ),
                )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PatientStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController dobCtrl;
  final TextEditingController memberIdCtrl;
  final TextEditingController mrnCtrl;

  const _PatientStep({
    required this.nameCtrl,
    required this.dobCtrl,
    required this.memberIdCtrl,
    required this.mrnCtrl,
  });

  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('Patient Name', controller: nameCtrl, hint: 'Full legal name'),
    _Field('Date of Birth', controller: dobCtrl, hint: 'MM/DD/YYYY'),
    _Field('Member ID', controller: memberIdCtrl, hint: 'Insurance member ID'),
    _Field('MRN', controller: mrnCtrl, hint: 'Medical Record Number (optional)'),
  ]);
}

class _DiagnosisStep extends StatelessWidget {
  final TextEditingController icdCodeCtrl;
  final TextEditingController diagDescCtrl;
  final TextEditingController notesCtrl;

  const _DiagnosisStep({
    required this.icdCodeCtrl,
    required this.diagDescCtrl,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('ICD-10 Code', controller: icdCodeCtrl, hint: 'Primary diagnosis code'),
    _Field('Diagnosis Description', controller: diagDescCtrl, hint: 'Atherosclerotic Heart Disease'),
    _Field('Clinical Notes', controller: notesCtrl, hint: 'Additional clinical information', maxLines: 3),
  ]);
}

class _ProcedureStep extends StatelessWidget {
  final TextEditingController cptCtrl;
  final TextEditingController procDescCtrl;
  final TextEditingController dateCtrl;
  final TextEditingController facilityNpiCtrl;

  const _ProcedureStep({
    required this.cptCtrl,
    required this.procDescCtrl,
    required this.dateCtrl,
    required this.facilityNpiCtrl,
  });

  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('CPT Code', controller: cptCtrl, hint: 'Procedure CPT code'),
    _Field('Procedure Description', controller: procDescCtrl, hint: 'Cardiovascular Stress Test'),
    _Field('Scheduled Date', controller: dateCtrl, hint: 'MM/DD/YYYY'),
    _Field('Facility NPI', controller: facilityNpiCtrl, hint: 'NPI number of facility'),
  ]);
}

class _InsuranceStep extends StatelessWidget {
  final TextEditingController planCtrl;
  final TextEditingController groupCtrl;
  final TextEditingController docNpiCtrl;
  final String priority;
  final ValueChanged<String?> onChangedPriority;

  const _InsuranceStep({
    required this.planCtrl,
    required this.groupCtrl,
    required this.docNpiCtrl,
    required this.priority,
    required this.onChangedPriority,
  });

  @override
  Widget build(BuildContext ctx) => Column(children: [
    _Field('Insurance Plan', controller: planCtrl, hint: 'e.g. BlueCross PPO Premium'),
    _Field('Group Number', controller: groupCtrl, hint: 'Insurance group number'),
    _Field('Requesting Physician NPI', controller: docNpiCtrl, hint: '10-digit NPI number'),
    _Field(
      'Priority',
      isDropdown: true,
      items: const ['Routine', 'Urgent', 'Emergent', 'STAT'],
      value: priority,
      onChanged: onChangedPriority,
    ),
  ]);
}

class _ReviewStep extends StatelessWidget {
  final String patient;
  final String diagnosis;
  final String procedure;
  final String insurance;
  final String priority;

  const _ReviewStep({
    required this.patient,
    required this.diagnosis,
    required this.procedure,
    required this.insurance,
    required this.priority,
  });

  @override
  Widget build(BuildContext ctx) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Review Summary', style: Theme.of(ctx).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _ReviewRow('Patient', patient),
          _ReviewRow('Diagnosis', diagnosis),
          _ReviewRow('Procedure', procedure),
          _ReviewRow('Insurance', insurance),
          _ReviewRow('Priority', priority),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(children: [
          const Icon(Icons.info_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'AI will process this request immediately upon submission and aims to provide a decision within 5 seconds.',
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.warningDark),
          )),
        ]),
      ),
    ],
  );
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);
  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      SizedBox(width: 100, child: Text(label, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary))),
      Expanded(child: Text(value, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
    ]),
  );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int maxLines;
  final bool isDropdown;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;

  const _Field(
    this.label, {
    this.controller,
    this.hint,
    this.maxLines = 1,
    this.isDropdown = false,
    this.items = const [],
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: isDropdown
        ? DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(labelText: label),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChanged,
          )
        : TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(labelText: label, hintText: hint),
          ),
  );
}
