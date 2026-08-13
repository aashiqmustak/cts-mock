import '../../models/models.dart';
import '../../core/constants/app_constants.dart';

/// Comprehensive mock data repository for MediAuth AI demo.
/// Structured to match real FHIR R4 / CMS / MEPS / DailyMed schemas.
class MockDataRepository {
  MockDataRepository._();
  static final MockDataRepository instance = MockDataRepository._();

  // ─── Patients ─────────────────────────────────────────────────────────────
  final List<Patient> patients = [
    const Patient(
      id: 'pat-001', name: 'Robert Martinez', dateOfBirth: '1968-03-15',
      gender: 'Male', insuranceId: 'BCBS-789012', insurancePlan: 'BlueCross PPO Premium',
      payer: 'BlueCross BlueShield', primaryDiagnosis: 'Coronary Artery Disease',
      chronicConditions: ['Hypertension', 'Type 2 Diabetes', 'Hyperlipidemia'],
      primaryPhysicianName: 'Dr. Michael Johnson', contactPhone: '(555) 234-5678',
      contactEmail: 'r.martinez@email.com', facilityId: 'fac-001',
      totalAuthorizations: 8, approvedAuthorizations: 6, pendingAuthorizations: 1,
      mrn: 'MRN-0045231',
      guardianName: 'Maria Martinez', guardianPhone: '(555) 901-2384', guardianRelationship: 'Spouse',
    ),
    const Patient(
      id: 'pat-002', name: 'Jennifer Walsh', dateOfBirth: '1975-07-22',
      gender: 'Female', insuranceId: 'AETNA-456789', insurancePlan: 'Aetna Choice POS II',
      payer: 'Aetna', primaryDiagnosis: 'Breast Cancer Stage II',
      chronicConditions: ['Anxiety Disorder'],
      primaryPhysicianName: 'Dr. Priya Sharma', contactPhone: '(555) 345-6789',
      facilityId: 'fac-001',
      totalAuthorizations: 12, approvedAuthorizations: 10, pendingAuthorizations: 2,
      mrn: 'MRN-0067892',
      guardianName: 'David Walsh', guardianPhone: '(555) 019-9283', guardianRelationship: 'Spouse',
    ),
    const Patient(
      id: 'pat-003', name: 'David Kim', dateOfBirth: '1952-11-30',
      gender: 'Male', insuranceId: 'UHC-123456', insurancePlan: 'UnitedHealthcare Choice Plus',
      payer: 'UnitedHealthcare', primaryDiagnosis: 'Chronic Kidney Disease Stage 3',
      chronicConditions: ['Hypertension', 'Anemia', 'Type 2 Diabetes'],
      primaryPhysicianName: 'Dr. James Wilson', contactPhone: '(555) 456-7890',
      facilityId: 'fac-002',
      totalAuthorizations: 15, approvedAuthorizations: 11, pendingAuthorizations: 3,
      mrn: 'MRN-0089123',
    ),
    const Patient(
      id: 'pat-004', name: 'Angela Foster', dateOfBirth: '1988-05-14',
      gender: 'Female', insuranceId: 'CIG-234567', insurancePlan: 'Cigna OAP',
      payer: 'Cigna', primaryDiagnosis: 'Multiple Sclerosis',
      chronicConditions: ['Depression', 'Fatigue Syndrome'],
      primaryPhysicianName: 'Dr. Michael Johnson', contactPhone: '(555) 567-8901',
      contactEmail: 'a.foster@email.com', facilityId: 'fac-001',
      totalAuthorizations: 6, approvedAuthorizations: 5, pendingAuthorizations: 1,
      mrn: 'MRN-0034567',
    ),
    const Patient(
      id: 'pat-005', name: 'Thomas Greene', dateOfBirth: '1960-09-08',
      gender: 'Male', insuranceId: 'HUM-345678', insurancePlan: 'Humana Gold Plus HMO',
      payer: 'Humana', primaryDiagnosis: 'Atrial Fibrillation',
      chronicConditions: ['Heart Failure', 'Hypertension'],
      primaryPhysicianName: 'Dr. Lisa Chen', contactPhone: '(555) 678-9012',
      facilityId: 'fac-002',
      totalAuthorizations: 9, approvedAuthorizations: 7, pendingAuthorizations: 0,
      mrn: 'MRN-0056789',
    ),
    const Patient(
      id: 'pat-006', name: 'Maria Santos', dateOfBirth: '1982-02-28',
      gender: 'Female', insuranceId: 'BCBS-890123', insurancePlan: 'BlueCross HMO Select',
      payer: 'BlueCross BlueShield', primaryDiagnosis: 'Rheumatoid Arthritis',
      chronicConditions: ['Osteoporosis'],
      primaryPhysicianName: 'Dr. Michael Johnson', contactPhone: '(555) 789-0123',
      facilityId: 'fac-001',
      totalAuthorizations: 4, approvedAuthorizations: 3, pendingAuthorizations: 1,
      mrn: 'MRN-0023456',
    ),
    const Patient(
      id: 'pat-007', name: 'William Turner', dateOfBirth: '1945-12-03',
      gender: 'Male', insuranceId: 'CMS-001234', insurancePlan: 'Medicare Part B',
      payer: 'CMS Medicare', primaryDiagnosis: 'Parkinson\'s Disease',
      chronicConditions: ['Dementia', 'Hypertension', 'Osteoarthritis'],
      primaryPhysicianName: 'Dr. Karen Patel', contactPhone: '(555) 890-1234',
      facilityId: 'fac-003',
      totalAuthorizations: 20, approvedAuthorizations: 17, pendingAuthorizations: 2,
      mrn: 'MRN-0078901',
    ),
    const Patient(
      id: 'pat-008', name: 'Rachel Chen', dateOfBirth: '1995-04-19',
      gender: 'Female', insuranceId: 'AETNA-567890', insurancePlan: 'Aetna Student Health',
      payer: 'Aetna', primaryDiagnosis: 'Crohn\'s Disease',
      chronicConditions: ['Iron Deficiency Anemia'],
      primaryPhysicianName: 'Dr. Priya Sharma', contactPhone: '(555) 901-2345',
      facilityId: 'fac-001',
      totalAuthorizations: 3, approvedAuthorizations: 2, pendingAuthorizations: 1,
      mrn: 'MRN-0012345',
    ),
    const Patient(
      id: 'pat-009', name: 'Emily Thompson', dateOfBirth: '1990-08-24',
      gender: 'Female', insuranceId: 'UHC-998877', insurancePlan: 'UnitedHealthcare PPO Plus',
      payer: 'UnitedHealthcare', primaryDiagnosis: 'Migraine Headaches',
      chronicConditions: ['Asthma', 'Allergic Rhinitis'],
      primaryPhysicianName: 'Dr. Michael Johnson', contactPhone: '(555) 987-6543',
      contactEmail: 'patient@mediauth.ai', facilityId: 'fac-001',
      totalAuthorizations: 3, approvedAuthorizations: 2, pendingAuthorizations: 1,
      mrn: 'MRN-0099112',
    ),
  ];

  // ─── Doctors ──────────────────────────────────────────────────────────────
  final List<Doctor> doctors = [
    const Doctor(
      id: 'doc-001', name: 'Dr. Michael Johnson', npi: '1234567890',
      specialization: 'Cardiology', facility: 'Metropolitan General Hospital',
      email: 'dr.johnson@mediauth.ai', phone: '(555) 100-2001',
      totalRequests: 142, approvedRequests: 128, rejectedRequests: 9,
      approvalRate: 0.901, avgProcessingTimeMs: 3200,
      cmsSpecialtyCode: '06', isActive: true,
      availability: 'Mon, Wed, Fri 09:00 - 17:00',
    ),
    const Doctor(
      id: 'doc-002', name: 'Dr. Priya Sharma', npi: '2345678901',
      specialization: 'Oncology', facility: 'Metropolitan General Hospital',
      email: 'p.sharma@hospital.org', phone: '(555) 100-2002',
      totalRequests: 89, approvedRequests: 79, rejectedRequests: 7,
      approvalRate: 0.888, avgProcessingTimeMs: 4100,
      cmsSpecialtyCode: '90', isActive: true,
      availability: 'Tue, Thu 08:30 - 16:30',
    ),
    const Doctor(
      id: 'doc-003', name: 'Dr. James Wilson', npi: '3456789012',
      specialization: 'Nephrology', facility: 'City Medical Center',
      email: 'j.wilson@citymed.org', phone: '(555) 100-2003',
      totalRequests: 67, approvedRequests: 54, rejectedRequests: 10,
      approvalRate: 0.806, avgProcessingTimeMs: 2800,
      cmsSpecialtyCode: '39', isActive: true,
      availability: 'Mon, Tue, Thu 09:00 - 15:00',
    ),
    const Doctor(
      id: 'doc-004', name: 'Dr. Lisa Chen', npi: '4567890123',
      specialization: 'Cardiology', facility: 'City Medical Center',
      email: 'l.chen@citymed.org', phone: '(555) 100-2004',
      totalRequests: 98, approvedRequests: 91, rejectedRequests: 5,
      approvalRate: 0.929, avgProcessingTimeMs: 2400,
      cmsSpecialtyCode: '06', isActive: true,
      availability: 'Wed, Thu 10:00 - 18:00',
    ),
    const Doctor(
      id: 'doc-005', name: 'Dr. Karen Patel', npi: '5678901234',
      specialization: 'Neurology', facility: 'Sunrise Health System',
      email: 'k.patel@sunrise.org', phone: '(555) 100-2005',
      totalRequests: 113, approvedRequests: 99, rejectedRequests: 11,
      approvalRate: 0.876, avgProcessingTimeMs: 3600,
      cmsSpecialtyCode: '13', isActive: true,
      availability: 'Tue, Fri 09:00 - 17:00',
    ),
    const Doctor(
      id: 'doc-006', name: 'Dr. Robert Hayes', npi: '6789012345',
      specialization: 'Orthopedic Surgery', facility: 'Metropolitan General Hospital',
      email: 'r.hayes@hospital.org', phone: '(555) 100-2006',
      totalRequests: 205, approvedRequests: 187, rejectedRequests: 14,
      approvalRate: 0.912, avgProcessingTimeMs: 2100,
      cmsSpecialtyCode: '20', isActive: true,
      availability: 'Mon-Thu 07:00 - 15:00',
    ),
  ];

  // ─── AI Decisions ─────────────────────────────────────────────────────────
  List<AiDecision> get aiDecisions => [
    AiDecision(
      id: 'ai-001',
      authorizationId: 'auth-001',
      recommendation: 'approve',
      confidenceScore: 0.94,
      medicalNecessityScore: 0.91,
      riskScore: 0.12,
      appealLikelihood: 0.08,
      appealConfidenceLow: 0.05,
      appealConfidenceHigh: 0.14,
      autoEscalated: false,
      processedAt: DateTime.now().subtract(const Duration(hours: 2)),
      processingTimeMs: 2840,
      finalJustification:
          'Authorization approved. Patient presents with documented Coronary Artery Disease (ICD-10: I25.10) supported by recent cardiac catheterization findings. Cardiac stress testing (CPT: 93015) is medically necessary per AHA/ACC guidelines. CMS benchmark data indicates 94.2% approval rate for this procedure-diagnosis combination in the Northeast region. No contraindications identified.',
      fraudSignals: {
        'Billing Frequency Outlier': 0.08,
        'Provider Utilization vs CMS Benchmark': 0.11,
        'Duplicate Request Indicator': 0.03,
        'Geographic Anomaly': 0.05,
      },
      reasoningChain: [
        const AiReasoningStep(
          stepNumber: 1,
          title: 'Diagnosis Validation',
          description: 'ICD-10 code verified against CMS accepted diagnosis codes. Patient history confirms chronic condition.',
          citedValue: 'ICD-10: I25.10 — Atherosclerotic Heart Disease',
          policyRef: 'Policy §2.1.3 — Cardiac Conditions',
          dataSource: AppConstants.dataSrcCms,
          passed: true,
          score: 0.98,
          details: [
            'ICD-10 I25.10 confirmed valid for CPT 93015',
            'Chronic condition with documented 3+ year history',
            'CMS acceptance rate for this code pair: 94.2%',
            'No exclusion criteria triggered',
          ],
        ),
        const AiReasoningStep(
          stepNumber: 2,
          title: 'Procedure Eligibility',
          description: 'CPT code cross-referenced against plan formulary and CMS coverage database.',
          citedValue: 'CPT: 93015 — Cardiovascular Stress Test',
          policyRef: 'Policy §3.4.1 — Covered Procedures',
          dataSource: AppConstants.dataSrcCms,
          passed: true,
          score: 0.96,
          details: [
            'CPT 93015 is covered under plan BlueCross PPO Premium',
            'No prior authorization limit exceeded (4/year allowed)',
            'Last procedure: 14 months ago — within recurrence window',
            'National Medicare reimbursement: \$387.40',
          ],
        ),
        const AiReasoningStep(
          stepNumber: 3,
          title: 'Medical Necessity Assessment',
          description: 'Clinical necessity evaluated against evidence-based criteria and MEPS utilization benchmarks.',
          citedValue: 'Necessity Score: 91%',
          policyRef: 'Policy §4.2.1 — Medical Necessity Standards',
          dataSource: AppConstants.dataSrcMeps,
          passed: true,
          score: 0.91,
          details: [
            'MEPS benchmark: 87% of similar patients receive this procedure',
            'Risk factor score: Hypertension + Diabetes + CAD = High risk',
            'AHA/ACC Class I indication confirmed',
            'Step therapy requirements: N/A for diagnostic procedure',
          ],
        ),
        const AiReasoningStep(
          stepNumber: 4,
          title: 'Risk Score Calculation',
          description: 'Multi-factor risk assessment including fraud signals, utilization patterns, and clinical risk.',
          citedValue: 'Risk Score: 12%',
          policyRef: 'Policy §6.1 — Risk Assessment Protocol',
          dataSource: AppConstants.dataSrcInternal,
          passed: true,
          score: 0.88,
          details: [
            'Clinical risk: Moderate (managed with medication)',
            'Provider utilization: Within normal CMS benchmark range',
            'No fraud signals detected above threshold',
            'Patient claim history: Clean (no duplicate claims)',
          ],
        ),
        const AiReasoningStep(
          stepNumber: 5,
          title: 'Policy Clause Matching',
          description: 'Request matched against 847 active policy clauses. No exclusion criteria triggered.',
          citedValue: 'Matched: §3.4.1, §4.2.1, §2.1.3',
          policyRef: 'BlueCross PPO Premium Policy v2024.3',
          dataSource: AppConstants.dataSrcInternal,
          passed: true,
          score: 1.0,
          details: [
            '847 policy clauses evaluated',
            '3 directly applicable clauses matched',
            '0 exclusion clauses triggered',
            'Plan deductible status: Met (\$2,400/\$2,400)',
          ],
        ),
        const AiReasoningStep(
          stepNumber: 6,
          title: 'Final Recommendation',
          description: 'All criteria met. High-confidence approval with no human review required.',
          citedValue: 'Confidence: 94%',
          policyRef: null,
          dataSource: AppConstants.dataSrcInternal,
          passed: true,
          score: 0.94,
          details: [
            'All 5 criteria passed',
            'Confidence above escalation threshold (75%)',
            'Auto-approval triggered',
            'Processing time: 2.84 seconds',
          ],
        ),
      ],
    ),
    AiDecision(
      id: 'ai-002',
      authorizationId: 'auth-003',
      recommendation: 'reject',
      confidenceScore: 0.88,
      medicalNecessityScore: 0.42,
      riskScore: 0.34,
      appealLikelihood: 0.61,
      appealConfidenceLow: 0.52,
      appealConfidenceHigh: 0.71,
      autoEscalated: false,
      processedAt: DateTime.now().subtract(const Duration(hours: 5)),
      processingTimeMs: 3120,
      finalJustification:
          'Authorization denied. MRI Brain without contrast (CPT: 70553) does not meet medical necessity criteria for the submitted diagnosis of Tension Headache (ICD-10: G44.209). Per CMS guidelines and plan policy §4.3.2, advanced neuroimaging requires documented failure of conservative treatment for minimum 6 weeks. No such documentation was provided. Step therapy: Patient should first complete 6-week conservative treatment protocol.',
      fraudSignals: {
        'Billing Frequency Outlier': 0.22,
        'Provider Utilization vs CMS Benchmark': 0.18,
        'Duplicate Request Indicator': 0.05,
        'Geographic Anomaly': 0.03,
      },
      reasoningChain: [
        const AiReasoningStep(
          stepNumber: 1, title: 'Diagnosis Validation',
          description: 'ICD-10 code valid but low specificity for requested procedure.',
          citedValue: 'ICD-10: G44.209 — Tension Headache, Unspecified',
          policyRef: 'Policy §2.1.7 — Neurological Conditions',
          dataSource: AppConstants.dataSrcCms, passed: true, score: 0.72,
          details: ['ICD-10 G44.209 is valid', 'Low specificity for advanced imaging', 'CMS approval rate for this pair: 31.4%'],
        ),
        const AiReasoningStep(
          stepNumber: 2, title: 'Procedure Eligibility',
          description: 'CPT 70553 covered, but with strict step therapy requirements.',
          citedValue: 'CPT: 70553 — MRI Brain w/o & with contrast',
          policyRef: 'Policy §3.6.2 — Advanced Neuroimaging',
          dataSource: AppConstants.dataSrcCms, passed: false, score: 0.38,
          details: ['CPT 70553 covered under plan', 'Step therapy: 6-week conservative treatment required', 'No documentation of failed conservative treatment submitted'],
        ),
        const AiReasoningStep(
          stepNumber: 3, title: 'Medical Necessity Assessment',
          description: 'Medical necessity criteria NOT met. Conservative treatment documentation missing.',
          citedValue: 'Necessity Score: 42%',
          policyRef: 'Policy §4.3.2 — Neuroimaging Necessity',
          dataSource: AppConstants.dataSrcMeps, passed: false, score: 0.42,
          details: ['MEPS: Only 28% of similar cases approved without step therapy', 'Missing: Conservative treatment failure documentation', 'Missing: Neurological examination findings'],
        ),
        const AiReasoningStep(
          stepNumber: 4, title: 'Policy Clause Matching',
          description: 'Exclusion clause §4.3.2 triggered. Step therapy not completed.',
          citedValue: 'Exclusion: §4.3.2 — Step Therapy Required',
          policyRef: 'BlueCross HMO Select Policy v2024.3',
          dataSource: AppConstants.dataSrcInternal, passed: false, score: 0.0,
          details: ['Exclusion clause §4.3.2 triggered', 'Step therapy: 6 weeks conservative treatment', 'Resubmit with: Treatment failure documentation + neurological exam'],
        ),
        const AiReasoningStep(
          stepNumber: 5, title: 'Final Recommendation',
          description: 'Denial: Step therapy not met. Appeal likelihood 61% if documentation provided.',
          citedValue: 'Confidence: 88%',
          policyRef: null,
          dataSource: AppConstants.dataSrcInternal, passed: false, score: 0.88,
          details: ['2 criteria failed', 'Step therapy documentation required', 'Appeal likelihood: 61% with proper documentation'],
        ),
      ],
    ),
    AiDecision(
      id: 'ai-003',
      authorizationId: 'auth-005',
      recommendation: 'escalate',
      confidenceScore: 0.62,
      medicalNecessityScore: 0.71,
      riskScore: 0.45,
      appealLikelihood: 0.44,
      appealConfidenceLow: 0.35,
      appealConfidenceHigh: 0.55,
      autoEscalated: true,
      processedAt: DateTime.now().subtract(const Duration(hours: 1)),
      processingTimeMs: 4580,
      finalJustification:
          'Escalated to human review. AI confidence (62%) is below the auto-decision threshold (75%). Conflicting signals detected: Medical necessity criteria partially met, but unusual billing frequency pattern detected against CMS benchmark (1.8x standard deviation). Request requires senior reviewer evaluation before decision.',
      fraudSignals: {
        'Billing Frequency Outlier': 0.51,
        'Provider Utilization vs CMS Benchmark': 0.43,
        'Duplicate Request Indicator': 0.09,
        'Geographic Anomaly': 0.12,
      },
      reasoningChain: [
        const AiReasoningStep(
          stepNumber: 1, title: 'Diagnosis Validation',
          description: 'Diagnosis valid but flagged for unusual specificity pattern.',
          citedValue: 'ICD-10: M54.5 — Low Back Pain',
          policyRef: 'Policy §2.1.9 — Musculoskeletal', dataSource: AppConstants.dataSrcCms,
          passed: true, score: 0.79, details: ['ICD-10 M54.5 is valid', 'High volume code — elevated fraud screening', 'CMS frequency: 2.3M claims/year'],
        ),
        const AiReasoningStep(
          stepNumber: 2, title: 'Fraud Signal Detection',
          description: 'Billing frequency 1.8 standard deviations above CMS benchmark. Manual review recommended.',
          citedValue: 'Fraud Risk: Medium (45%)',
          policyRef: 'Policy §7.2 — Fraud Prevention', dataSource: AppConstants.dataSrcCms,
          passed: false, score: 0.45, details: ['Billing frequency: 1.8σ above benchmark', 'Provider submitted 3 similar requests this month', 'CMS benchmark: 0.6 requests/month for this procedure'],
        ),
        const AiReasoningStep(
          stepNumber: 3, title: 'Auto-Escalation Triggered',
          description: 'Confidence below 75% threshold. Routing to human reviewer.',
          citedValue: 'Confidence: 62%',
          policyRef: 'Policy §8.1 — AI Governance', dataSource: AppConstants.dataSrcInternal,
          passed: false, score: 0.62, details: ['Confidence 62% < 75% threshold', 'Auto-escalation triggered', 'Assigned to senior reviewer queue'],
        ),
      ],
    ),
    AiDecision(
      id: 'ai-011',
      authorizationId: 'auth-011',
      recommendation: 'approve',
      confidenceScore: 0.98,
      medicalNecessityScore: 0.95,
      riskScore: 0.05,
      appealLikelihood: 0.02,
      autoEscalated: false,
      processedAt: DateTime.now().subtract(const Duration(days: 10)),
      processingTimeMs: 1240,
      finalJustification: 'Office outpatient visit approved. Standard CPT 99214 code matches diagnostic guidelines for routine chronic migraine follow-up care.',
      reasoningChain: [
        const AiReasoningStep(
          stepNumber: 1, title: 'Diagnosis Spec Validation',
          description: 'Migraine diagnosis (ICD-10 G43.909) is valid.',
          dataSource: AppConstants.dataSrcCms, passed: true, score: 1.0,
          details: ['ICD-10 G43.909 is a valid code', 'Supports routine outpatient care'],
        ),
        const AiReasoningStep(
          stepNumber: 2, title: 'Eligibility Verification',
          description: 'Patient plan (UnitedHealthcare PPO Plus) covers routine evaluation and management.',
          dataSource: AppConstants.dataSrcInternal, passed: true, score: 1.0,
          details: ['CPT 99214 is a covered benefit', 'No prior authorization restriction triggered'],
        ),
      ],
    ),
    AiDecision(
      id: 'ai-012',
      authorizationId: 'auth-012',
      recommendation: 'approve',
      confidenceScore: 0.91,
      medicalNecessityScore: 0.88,
      riskScore: 0.15,
      appealLikelihood: 0.05,
      autoEscalated: false,
      processedAt: DateTime.now().subtract(const Duration(days: 6)),
      processingTimeMs: 2450,
      finalJustification: 'Aimovig (Erenumab-aooe) approved for prophylactic treatment of chronic migraine. Patient has documented history of 15+ headache days per month and failed first-line therapies.',
      reasoningChain: [
        const AiReasoningStep(
          stepNumber: 1, title: 'Prior Therapy Check',
          description: 'Patient has documented failure of standard first-line preventative medication.',
          dataSource: AppConstants.dataSrcInternal, passed: true, score: 0.92,
          details: ['Failed: Amitriptyline (antidepressant preventative)', 'Failed: Propranolol (beta blocker preventative)', 'Step therapy requirement fully satisfied'],
        ),
        const AiReasoningStep(
          stepNumber: 2, title: 'Frequency Validation',
          description: 'Clinical documentation confirms chronic migraine frequency.',
          dataSource: AppConstants.dataSrcMeps, passed: true, score: 0.95,
          details: ['Headache days: 17 days/month recorded', 'Satisfies FDA criteria for prophylactic CGRP inhibitors'],
        ),
      ],
    ),
  ];

  // ─── Authorization Requests ────────────────────────────────────────────────
  late final List<AuthorizationRequest> authorizations = [
    AuthorizationRequest(
      id: 'auth-001', authNumber: 'PA-2024-08847',
      patientId: 'pat-001', patientName: 'Robert Martinez',
      patientDob: '1968-03-15', patientInsuranceId: 'BCBS-789012',
      requestingDoctorId: 'doc-001', requestingDoctorName: 'Dr. Michael Johnson',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'I25.10', diagnosisDescription: 'Atherosclerotic Heart Disease of Native Coronary Artery',
      procedureCode: '93015', procedureDescription: 'Cardiovascular Stress Test with ECG Monitoring',
      insurancePlanId: 'plan-001', insurancePlanName: 'BlueCross PPO Premium',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(hours: 4)),
      decidedAt: DateTime.now().subtract(const Duration(hours: 2)),
      processingTimeMs: 2840, aiDecisionId: 'ai-001',
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
      cmsNpiNumber: '1234567890', cmsSpecialty: 'Cardiology',
      reviewerNotes: 'Auto-approved by AI. All criteria met.',
    ),
    AuthorizationRequest(
      id: 'auth-002', authNumber: 'PA-2024-08848',
      patientId: 'pat-002', patientName: 'Jennifer Walsh',
      patientDob: '1975-07-22', patientInsuranceId: 'AETNA-456789',
      requestingDoctorId: 'doc-002', requestingDoctorName: 'Dr. Priya Sharma',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'C50.912', diagnosisDescription: 'Malignant Neoplasm of Breast, Unspecified',
      procedureCode: '96413', procedureDescription: 'Chemotherapy Administration, IV Push',
      insurancePlanId: 'plan-002', insurancePlanName: 'Aetna Choice POS II',
      status: AuthorizationStatus.underReview, priority: AuthorizationPriority.urgent,
      requestedAt: DateTime.now().subtract(const Duration(hours: 6)),
      processingTimeMs: null, aiDecisionId: null,
      isUrgent: true, slaStatus: 'at_risk', dataSource: AppConstants.dataSrcCms,
      cmsNpiNumber: '2345678901', cmsSpecialty: 'Oncology',
    ),
    AuthorizationRequest(
      id: 'auth-003', authNumber: 'PA-2024-08849',
      patientId: 'pat-006', patientName: 'Maria Santos',
      patientDob: '1982-02-28', patientInsuranceId: 'BCBS-890123',
      requestingDoctorId: 'doc-001', requestingDoctorName: 'Dr. Michael Johnson',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'G44.209', diagnosisDescription: 'Tension-Type Headache, Unspecified',
      procedureCode: '70553', procedureDescription: 'MRI Brain without and with Contrast',
      insurancePlanId: 'plan-003', insurancePlanName: 'BlueCross HMO Select',
      status: AuthorizationStatus.rejected, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(hours: 8)),
      decidedAt: DateTime.now().subtract(const Duration(hours: 5)),
      processingTimeMs: 3120, aiDecisionId: 'ai-002',
      rejectionReason: 'Step therapy requirements not met. Conservative treatment documentation missing.',
      policyClauseCited: 'Policy §4.3.2 — Advanced Neuroimaging Step Therapy',
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
    ),
    AuthorizationRequest(
      id: 'auth-004', authNumber: 'PA-2024-08850',
      patientId: 'pat-004', patientName: 'Angela Foster',
      patientDob: '1988-05-14', patientInsuranceId: 'CIG-234567',
      requestingDoctorId: 'doc-005', requestingDoctorName: 'Dr. Karen Patel',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'G35', diagnosisDescription: 'Multiple Sclerosis',
      procedureCode: 'J0202', procedureDescription: 'Natalizumab Injection (Tysabri) 1mg',
      drugName: 'Natalizumab (Tysabri)', drugNdc: '64406-007-01',
      insurancePlanId: 'plan-004', insurancePlanName: 'Cigna OAP',
      status: AuthorizationStatus.pending, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
      processingTimeMs: null, aiDecisionId: null,
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcDailyMed,
    ),
    AuthorizationRequest(
      id: 'auth-005', authNumber: 'PA-2024-08851',
      patientId: 'pat-003', patientName: 'David Kim',
      patientDob: '1952-11-30', patientInsuranceId: 'UHC-123456',
      requestingDoctorId: 'doc-003', requestingDoctorName: 'Dr. James Wilson',
      facilityName: 'City Medical Center', facilityNpi: '2233445566',
      diagnosisCode: 'M54.5', diagnosisDescription: 'Low Back Pain',
      procedureCode: '22612', procedureDescription: 'Lumbar Spine Fusion, Posterior',
      insurancePlanId: 'plan-005', insurancePlanName: 'UnitedHealthcare Choice Plus',
      status: AuthorizationStatus.escalated, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(hours: 3)),
      processingTimeMs: 4580, aiDecisionId: 'ai-003',
      isUrgent: false, slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
      reviewerNotes: 'AI escalated due to low confidence (62%). Fraud signals detected. Requires senior reviewer.',
    ),
    AuthorizationRequest(
      id: 'auth-006', authNumber: 'PA-2024-08852',
      patientId: 'pat-005', patientName: 'Thomas Greene',
      patientDob: '1960-09-08', patientInsuranceId: 'HUM-345678',
      requestingDoctorId: 'doc-004', requestingDoctorName: 'Dr. Lisa Chen',
      facilityName: 'City Medical Center', facilityNpi: '2233445566',
      diagnosisCode: 'I48.0', diagnosisDescription: 'Paroxysmal Atrial Fibrillation',
      procedureCode: '93655', procedureDescription: 'Intracardiac Catheter Ablation',
      insurancePlanId: 'plan-006', insurancePlanName: 'Humana Gold Plus HMO',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.urgent,
      requestedAt: DateTime.now().subtract(const Duration(days: 1)),
      decidedAt: DateTime.now().subtract(const Duration(hours: 22)),
      processingTimeMs: 1980, isUrgent: true,
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
      cmsNpiNumber: '4567890123', cmsSpecialty: 'Cardiology',
    ),
    AuthorizationRequest(
      id: 'auth-007', authNumber: 'PA-2024-08853',
      patientId: 'pat-007', patientName: 'William Turner',
      patientDob: '1945-12-03', patientInsuranceId: 'CMS-001234',
      requestingDoctorId: 'doc-005', requestingDoctorName: 'Dr. Karen Patel',
      facilityName: 'Sunrise Health System', facilityNpi: '3344556677',
      diagnosisCode: 'G20', diagnosisDescription: 'Parkinson\'s Disease',
      procedureCode: '95999', procedureDescription: 'Deep Brain Stimulation Programming',
      insurancePlanId: 'plan-007', insurancePlanName: 'Medicare Part B',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(days: 2)),
      decidedAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
      processingTimeMs: 3340, slaStatus: 'within_sla',
      dataSource: AppConstants.dataSrcCms, cmsNpiNumber: '5678901234',
    ),
    AuthorizationRequest(
      id: 'auth-008', authNumber: 'PA-2024-08854',
      patientId: 'pat-008', patientName: 'Rachel Chen',
      patientDob: '1995-04-19', patientInsuranceId: 'AETNA-567890',
      requestingDoctorId: 'doc-002', requestingDoctorName: 'Dr. Priya Sharma',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'K50.90', diagnosisDescription: 'Crohn\'s Disease of Small Intestine',
      procedureCode: 'J0515', procedureDescription: 'Adalimumab Injection (Humira) 20mg',
      drugName: 'Adalimumab (Humira)', drugNdc: '00074-9374-02',
      insurancePlanId: 'plan-002', insurancePlanName: 'Aetna Student Health',
      status: AuthorizationStatus.pending, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      processingTimeMs: null, slaStatus: 'within_sla',
      dataSource: AppConstants.dataSrcDailyMed,
    ),
    AuthorizationRequest(
      id: 'auth-009', authNumber: 'PA-2024-08839',
      patientId: 'pat-001', patientName: 'Robert Martinez',
      patientDob: '1968-03-15', patientInsuranceId: 'BCBS-789012',
      requestingDoctorId: 'doc-001', requestingDoctorName: 'Dr. Michael Johnson',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'I25.110', diagnosisDescription: 'Atherosclerotic Heart Disease with Unstable Angina',
      procedureCode: '92920', procedureDescription: 'Percutaneous Transluminal Coronary Angioplasty',
      insurancePlanId: 'plan-001', insurancePlanName: 'BlueCross PPO Premium',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.stat,
      requestedAt: DateTime.now().subtract(const Duration(days: 3)),
      decidedAt: DateTime.now().subtract(const Duration(days: 3)),
      processingTimeMs: 1540, isUrgent: true,
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
    ),
    AuthorizationRequest(
      id: 'auth-010', authNumber: 'PA-2024-08831',
      patientId: 'pat-003', patientName: 'David Kim',
      patientDob: '1952-11-30', patientInsuranceId: 'UHC-123456',
      requestingDoctorId: 'doc-003', requestingDoctorName: 'Dr. James Wilson',
      facilityName: 'City Medical Center', facilityNpi: '2233445566',
      diagnosisCode: 'N18.3', diagnosisDescription: 'Chronic Kidney Disease, Stage 3',
      procedureCode: '90935', procedureDescription: 'Hemodialysis with Evaluation and Management',
      insurancePlanId: 'plan-005', insurancePlanName: 'UnitedHealthcare Choice Plus',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(days: 5)),
      decidedAt: DateTime.now().subtract(const Duration(days: 5)),
      processingTimeMs: 2280, slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
    ),
    AuthorizationRequest(
      id: 'auth-011', authNumber: 'PA-2024-08861',
      patientId: 'pat-009', patientName: 'Emily Thompson',
      patientDob: '1990-08-24', patientInsuranceId: 'UHC-998877',
      requestingDoctorId: 'doc-001', requestingDoctorName: 'Dr. Michael Johnson',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'G43.909', diagnosisDescription: 'Migraine, Unspecified, Not Intractable',
      procedureCode: '99214', procedureDescription: 'Office Outpatient Visit 30-39 Minutes',
      insurancePlanId: 'plan-005', insurancePlanName: 'UnitedHealthcare PPO Plus',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(days: 10)),
      decidedAt: DateTime.now().subtract(const Duration(days: 10)),
      processingTimeMs: 1240, aiDecisionId: 'ai-011',
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
    ),
    AuthorizationRequest(
      id: 'auth-012', authNumber: 'PA-2024-08862',
      patientId: 'pat-009', patientName: 'Emily Thompson',
      patientDob: '1990-08-24', patientInsuranceId: 'UHC-998877',
      requestingDoctorId: 'doc-001', requestingDoctorName: 'Dr. Michael Johnson',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'G43.909', diagnosisDescription: 'Migraine, Unspecified, Not Intractable',
      procedureCode: 'J3035', procedureDescription: 'Erenumab-aooe Injection (Aimovig) 1mg',
      drugName: 'Erenumab-aooe (Aimovig)', drugNdc: '55513-841-01',
      insurancePlanId: 'plan-005', insurancePlanName: 'UnitedHealthcare PPO Plus',
      status: AuthorizationStatus.approved, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(days: 6)),
      decidedAt: DateTime.now().subtract(const Duration(days: 6)),
      processingTimeMs: 2450, aiDecisionId: 'ai-012',
      slaStatus: 'within_sla', dataSource: AppConstants.dataSrcDailyMed,
    ),
    AuthorizationRequest(
      id: 'auth-013', authNumber: 'PA-2024-08863',
      patientId: 'pat-009', patientName: 'Emily Thompson',
      patientDob: '1990-08-24', patientInsuranceId: 'UHC-998877',
      requestingDoctorId: 'doc-001', requestingDoctorName: 'Dr. Michael Johnson',
      facilityName: 'Metropolitan General Hospital', facilityNpi: '1122334455',
      diagnosisCode: 'G43.909', diagnosisDescription: 'Migraine, Unspecified, Not Intractable',
      procedureCode: '70544', procedureDescription: 'MRA Head without Contrast',
      insurancePlanId: 'plan-005', insurancePlanName: 'UnitedHealthcare PPO Plus',
      status: AuthorizationStatus.pending, priority: AuthorizationPriority.routine,
      requestedAt: DateTime.now().subtract(const Duration(hours: 4)),
      processingTimeMs: null, slaStatus: 'within_sla', dataSource: AppConstants.dataSrcCms,
    ),
  ];

  // ─── Appeals ──────────────────────────────────────────────────────────────
  late final List<AppealCase> appeals = [
    AppealCase(
      id: 'appeal-001', appealNumber: 'APL-2024-0442',
      authorizationId: 'auth-003', authNumber: 'PA-2024-08849',
      patientName: 'Maria Santos',
      filedById: 'doc-001', filedByName: 'Dr. Michael Johnson',
      status: AppealStatus.submitted,
      filedAt: DateTime.now().subtract(const Duration(hours: 3)),
      groundsForAppeal: 'Conservative treatment was attempted but documentation was inadvertently omitted from initial submission. Patient has completed 8 weeks of physical therapy and over-the-counter analgesics with no improvement. Neurological symptoms have progressed.',
      aiSuccessProbability: 0.61,
      aiProbabilityLow: 0.52,
      aiProbabilityHigh: 0.71,
      draftAppealLetter: _appealLetterTemplate,
    ),
    AppealCase(
      id: 'appeal-002', appealNumber: 'APL-2024-0436',
      authorizationId: 'auth-011', authNumber: 'PA-2024-08821',
      patientName: 'Thomas Greene',
      filedById: 'usr-003', filedByName: 'Sarah Williams (Reviewer)',
      status: AppealStatus.overturned,
      filedAt: DateTime.now().subtract(const Duration(days: 4)),
      decidedAt: DateTime.now().subtract(const Duration(days: 1)),
      groundsForAppeal: 'Clinical guidelines updated. New evidence supports medically necessary classification.',
      aiSuccessProbability: 0.74,
      aiProbabilityLow: 0.64,
      aiProbabilityHigh: 0.84,
      rejectionReason: null,
    ),
    AppealCase(
      id: 'appeal-003', appealNumber: 'APL-2024-0421',
      authorizationId: 'auth-012', authNumber: 'PA-2024-08801',
      patientName: 'Angela Foster',
      filedById: 'usr-005', filedByName: 'Emily Thompson (Patient)',
      status: AppealStatus.underReview,
      filedAt: DateTime.now().subtract(const Duration(days: 7)),
      groundsForAppeal: 'Medication is the only FDA-approved treatment for my condition per specialist recommendation.',
      aiSuccessProbability: 0.48,
      aiProbabilityLow: 0.37,
      aiProbabilityHigh: 0.59,
    ),
  ];

  static const String _appealLetterTemplate = '''
[DATE]

BlueCross BlueShield — Northeast
Appeals Department
P.O. Box 10000
Buffalo, NY 14240

RE: APPEAL OF PRIOR AUTHORIZATION DENIAL
Patient: Maria Santos | DOB: 02/28/1982
Claim/Auth Number: PA-2024-08849
Insurance ID: BCBS-890123
Treating Physician: Dr. Michael Johnson, MD (NPI: 1234567890)

Dear Appeals Committee,

I am writing to formally appeal the denial of prior authorization PA-2024-08849 for MRI Brain Without and With Contrast (CPT: 70553) for the above-referenced patient.

REASON FOR DENIAL (as stated in denial notice):
"Step therapy requirements not met. Conservative treatment documentation missing." [Policy §4.3.2]

GROUNDS FOR APPEAL:
1. Conservative Treatment Was Completed: Ms. Santos completed 8 weeks of conservative treatment including physical therapy (3x/week), NSAIDs (Naproxen 500mg BID), and lifestyle modification. Clinical documentation is attached (Exhibit A).

2. Treatment Failure Documented: Patient reported no meaningful improvement in headache frequency (average 18 headache-days/month) or severity (average NRS 7/10) following conservative treatment course.

3. Progressive Neurological Symptoms: Over the past 4 weeks, patient has developed new associated symptoms including visual disturbances and left-sided paresthesias, warranting urgent neuroimaging evaluation to rule out intracranial pathology.

4. Clinical Urgency: Per American Headache Society guidelines, neuroimaging is indicated when "new or different headache pattern emerges" and/or "associated neurological symptoms are present."

SUPPORTING DOCUMENTATION (Attached):
- Exhibit A: Physical therapy progress notes (8 weeks)
- Exhibit B: Pharmacy records confirming NSAID trial
- Exhibit C: Neurological examination findings dated [DATE]
- Exhibit D: AHS Clinical Practice Guideline reference

We respectfully request expedited review given the patient's progressive neurological symptoms.

Sincerely,

Dr. Michael Johnson, MD
Cardiology | NPI: 1234567890
Metropolitan General Hospital
(555) 100-2001
''';

  // ─── Audit Log Entries ────────────────────────────────────────────────────
  late final List<AuditLogEntry> auditLogs = [
    AuditLogEntry(
      id: 'log-001', action: 'authorization.approved',
      actorId: 'usr-001', actorName: 'Alexandra Chen', actorRole: 'Administrator',
      resourceId: 'auth-001', resourceType: 'AuthorizationRequest',
      description: 'Authorization PA-2024-08847 auto-approved by AI system (confidence: 94%)',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      entryHash: 'a3f7b2e1c8d4', previousHash: 'f9e2d1c6b3a8',
      ipAddress: '10.0.1.45',
      metadata: {'auth_number': 'PA-2024-08847', 'confidence': 0.94, 'processing_ms': 2840},
    ),
    AuditLogEntry(
      id: 'log-002', action: 'authorization.escalated',
      actorId: 'SYSTEM', actorName: 'MediAuth AI Engine', actorRole: 'System',
      resourceId: 'auth-005', resourceType: 'AuthorizationRequest',
      description: 'Authorization PA-2024-08851 escalated to human review (AI confidence: 62% < 75% threshold)',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      entryHash: 'b4e8c3f2a1d7', previousHash: 'a3f7b2e1c8d4',
      ipAddress: '10.0.0.1',
      metadata: {'auth_number': 'PA-2024-08851', 'confidence': 0.62, 'threshold': 0.75},
    ),
    AuditLogEntry(
      id: 'log-003', action: 'authorization.rejected',
      actorId: 'SYSTEM', actorName: 'MediAuth AI Engine', actorRole: 'System',
      resourceId: 'auth-003', resourceType: 'AuthorizationRequest',
      description: 'Authorization PA-2024-08849 rejected by AI system. Policy §4.3.2 cited.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      entryHash: 'c5d9e4g3b2f1', previousHash: 'b4e8c3f2a1d7',
      ipAddress: '10.0.0.1',
      metadata: {'auth_number': 'PA-2024-08849', 'policy_clause': '§4.3.2', 'confidence': 0.88},
    ),
    AuditLogEntry(
      id: 'log-004', action: 'appeal.filed',
      actorId: 'usr-002', actorName: 'Dr. Michael Johnson', actorRole: 'Doctor',
      resourceId: 'appeal-001', resourceType: 'AppealCase',
      description: 'Appeal APL-2024-0442 filed for auth PA-2024-08849',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      entryHash: 'd6f0h5i4c3g2', previousHash: 'c5d9e4g3b2f1',
      ipAddress: '192.168.1.102',
      metadata: {'appeal_number': 'APL-2024-0442', 'auth_number': 'PA-2024-08849'},
    ),
    AuditLogEntry(
      id: 'log-005', action: 'user.login',
      actorId: 'usr-003', actorName: 'Sarah Williams', actorRole: 'Insurance Reviewer',
      resourceId: null, resourceType: null,
      description: 'User Sarah Williams logged in from IP 172.16.0.55',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      entryHash: 'e7g1i6j5d4h3', previousHash: 'd6f0h5i4c3g2',
      ipAddress: '172.16.0.55',
      metadata: {'user_agent': 'Chrome/128.0', 'session_id': 'sess-abc123'},
    ),
    AuditLogEntry(
      id: 'log-006', action: 'fhir.sync.completed',
      actorId: 'SYSTEM', actorName: 'FHIR Integration Service', actorRole: 'System',
      resourceId: null, resourceType: 'FhirSync',
      description: 'FHIR R4 sync completed. 847 resources synchronized across 4 resource types.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      entryHash: 'f8h2j7k6e5i4', previousHash: 'e7g1i6j5d4h3',
      ipAddress: '10.0.0.5',
      metadata: {'resources_synced': 847, 'resource_types': ['Patient', 'Coverage', 'Claim', 'ServiceRequest']},
    ),
    AuditLogEntry(
      id: 'log-007', action: 'patient.registered',
      actorId: 'usr-006', actorName: 'Sarah Jenkins', actorRole: 'Hospital Admin',
      resourceId: 'pat-009', resourceType: 'Patient',
      description: 'Registered patient Emily Thompson with MRN-0099112',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      entryHash: 'g9i3k8l7f6j5', previousHash: 'f8h2j7k6e5i4',
      ipAddress: '192.168.1.100',
      metadata: {'mrn': 'MRN-0099112', 'patient_id': 'pat-009'},
    ),
    AuditLogEntry(
      id: 'log-008', action: 'doctor.added',
      actorId: 'usr-006', actorName: 'Sarah Jenkins', actorRole: 'Hospital Admin',
      resourceId: 'doc-006', resourceType: 'Doctor',
      description: 'Added Dr. Robert Hayes to Metropolitan General Hospital roster',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      entryHash: 'h0j4l9m8g7k6', previousHash: 'g9i3k8l7f6j5',
      ipAddress: '192.168.1.100',
      metadata: {'npi': '6789012345', 'doctor_id': 'doc-006'},
    ),
    AuditLogEntry(
      id: 'log-009', action: 'surgery.scheduled',
      actorId: 'usr-006', actorName: 'Sarah Jenkins', actorRole: 'Hospital Admin',
      resourceId: 'pat-003', resourceType: 'Patient',
      description: 'Surgery (Lumbar Spine Fusion) scheduled for David Kim on 2026-08-25',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      entryHash: 'i1k5m0n9h8l7', previousHash: 'h0j4l9m8g7k6',
      ipAddress: '192.168.1.100',
      metadata: {'patient_id': 'pat-003', 'procedure': 'Lumbar Spine Fusion', 'date': '2026-08-25'},
    ),
    AuditLogEntry(
      id: 'log-010', action: 'appointment.scheduled',
      actorId: 'usr-006', actorName: 'Sarah Jenkins', actorRole: 'Hospital Admin',
      resourceId: 'pat-001', resourceType: 'Patient',
      description: 'Appointment scheduled for Robert Martinez with Dr. Michael Johnson on 2026-08-18',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      entryHash: 'j2l6n1o0i9m8', previousHash: 'i1k5m0n9h8l7',
      ipAddress: '192.168.1.100',
      metadata: {'patient_id': 'pat-001', 'doctor_id': 'doc-001', 'date': '2026-08-18'},
    ),
    AuditLogEntry(
      id: 'log-011', action: 'guardian.updated',
      actorId: 'usr-006', actorName: 'Sarah Jenkins', actorRole: 'Hospital Admin',
      resourceId: 'pat-002', resourceType: 'Patient',
      description: 'Guardian details updated for Jennifer Walsh (Relative: David Walsh, Phone: 555-0199)',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      entryHash: 'k3m7o2p1j0n9', previousHash: 'j2l6n1o0i9m8',
      ipAddress: '192.168.1.100',
      metadata: {'patient_id': 'pat-002', 'guardian_name': 'David Walsh', 'relationship': 'Spouse'},
    ),
    AuditLogEntry(
      id: 'log-012', action: 'insurance.verified',
      actorId: 'usr-006', actorName: 'Sarah Jenkins', actorRole: 'Hospital Admin',
      resourceId: 'pat-003', resourceType: 'Patient',
      description: 'Insurance verified for patient David Kim (UnitedHealthcare Choice Plus - Active)',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      entryHash: 'l4n8p3q2k1o0', previousHash: 'k3m7o2p1j0n9',
      ipAddress: '192.168.1.100',
      metadata: {'patient_id': 'pat-003', 'status': 'Active', 'plan': 'UnitedHealthcare Choice Plus'},
    ),
  ];

  // ─── Notifications ────────────────────────────────────────────────────────
  List<AppNotification> get notifications => [
    AppNotification(
      id: 'notif-001', title: 'Authorization Approved',
      message: 'PA-2024-08847 for Robert Martinez has been automatically approved (94% confidence).',
      type: NotificationType.authorization, isRead: false,
      resourceId: 'auth-001', resourceType: 'AuthorizationRequest',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'notif-002', title: 'Escalation Required',
      message: 'PA-2024-08851 requires human review. AI confidence below threshold (62%).',
      type: NotificationType.alert, isRead: false,
      resourceId: 'auth-005', resourceType: 'AuthorizationRequest',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: 'notif-003', title: 'Appeal Filed',
      message: 'Dr. Johnson filed appeal APL-2024-0442 for PA-2024-08849.',
      type: NotificationType.appeal, isRead: false,
      resourceId: 'appeal-001', resourceType: 'AppealCase',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppNotification(
      id: 'notif-004', title: 'FHIR Sync Complete',
      message: '847 FHIR R4 resources synchronized successfully.',
      type: NotificationType.system, isRead: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AppNotification(
      id: 'notif-005', title: 'SLA At Risk',
      message: 'PA-2024-08848 for Jennifer Walsh is approaching SLA threshold.',
      type: NotificationType.reminder, isRead: false,
      resourceId: 'auth-002', resourceType: 'AuthorizationRequest',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  // ─── FHIR Resource Syncs ──────────────────────────────────────────────────
  List<FhirResourceSync> get fhirSyncs => [
    FhirResourceSync(
      resourceType: 'Patient', status: FhirSyncStatus.healthy,
      syncedCount: 1284, lastSyncAt: DateTime.now().subtract(const Duration(minutes: 15)),
      pendingCount: 3,
    ),
    FhirResourceSync(
      resourceType: 'Coverage', status: FhirSyncStatus.healthy,
      syncedCount: 1156, lastSyncAt: DateTime.now().subtract(const Duration(minutes: 15)),
      pendingCount: 0,
    ),
    FhirResourceSync(
      resourceType: 'Claim', status: FhirSyncStatus.degraded,
      syncedCount: 8923, lastSyncAt: DateTime.now().subtract(const Duration(minutes: 47)),
      pendingCount: 142, errorMessage: 'Rate limit: 3 retries pending',
    ),
    FhirResourceSync(
      resourceType: 'ServiceRequest', status: FhirSyncStatus.healthy,
      syncedCount: 347, lastSyncAt: DateTime.now().subtract(const Duration(minutes: 15)),
      pendingCount: 8,
    ),
    FhirResourceSync(
      resourceType: 'Observation', status: FhirSyncStatus.healthy,
      syncedCount: 4521, lastSyncAt: DateTime.now().subtract(const Duration(hours: 1)),
      pendingCount: 0,
    ),
    FhirResourceSync(
      resourceType: 'Condition', status: FhirSyncStatus.error,
      syncedCount: 2187, lastSyncAt: DateTime.now().subtract(const Duration(hours: 3)),
      pendingCount: 0, errorMessage: 'Connection timeout — EMR endpoint unreachable',
    ),
    FhirResourceSync(
      resourceType: 'MedicationRequest', status: FhirSyncStatus.healthy,
      syncedCount: 6782, lastSyncAt: DateTime.now().subtract(const Duration(minutes: 30)),
      pendingCount: 15,
    ),
    FhirResourceSync(
      resourceType: 'Practitioner', status: FhirSyncStatus.healthy,
      syncedCount: 89, lastSyncAt: DateTime.now().subtract(const Duration(hours: 2)),
      pendingCount: 0,
    ),
  ];

  // ─── Dashboard Stats ──────────────────────────────────────────────────────
  DashboardStats get dashboardStats => DashboardStats(
    totalRequests: 1847,
    approvedToday: 134,
    pendingCount: 28,
    rejectedToday: 19,
    aiAccuracy: 0.962,
    avgProcessingTimeMs: 3240,
    percentWithinSla: 0.971,
    percentInstantDecision: 0.914,
    appealsfield: 12,
    appealSuccessRate: 0.783,
    revenueSavedUsd: 2840000,
    fraudFlagged: 7,
  );

  // ─── 30-day Approval Trend ────────────────────────────────────────────────
  List<Map<String, dynamic>> get approvalTrend {
    final now = DateTime.now();
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      final approved = 100 + (i * 1.2 + (i % 7 * 3)).round();
      final rejected = 10 + (i % 5);
      final pending  = 15 + (i % 8);
      return {
        'date': date,
        'approved': approved,
        'rejected': rejected,
        'pending': pending,
        'total': approved + rejected + pending,
      };
    });
  }

  // ─── Disease Statistics ───────────────────────────────────────────────────
  List<Map<String, dynamic>> get diseaseStats => [
    {'diagnosis': 'Cardiovascular', 'icd': 'I00-I99', 'count': 423, 'pct': 0.229},
    {'diagnosis': 'Musculoskeletal', 'icd': 'M00-M99', 'count': 387, 'pct': 0.209},
    {'diagnosis': 'Oncology', 'icd': 'C00-D49',  'count': 312, 'pct': 0.169},
    {'diagnosis': 'Neurological', 'icd': 'G00-G99',  'count': 228, 'pct': 0.123},
    {'diagnosis': 'Respiratory', 'icd': 'J00-J99',  'count': 184, 'pct': 0.100},
    {'diagnosis': 'Endocrine', 'icd': 'E00-E89',  'count': 156, 'pct': 0.084},
    {'diagnosis': 'Other', 'icd': 'Various',  'count': 157, 'pct': 0.085},
  ];

  // ─── Scheduled Appointments ───────────────────────────────────────────────
  late final List<PatientAppointment> appointments = [
    PatientAppointment(
      id: 'apt-001',
      patientId: 'pat-001',
      doctorName: 'Dr. Michael Johnson',
      dateTime: DateTime.now().add(const Duration(days: 5)),
      reason: 'Cardiology Follow-up',
    ),
    PatientAppointment(
      id: 'apt-002',
      patientId: 'pat-002',
      doctorName: 'Dr. Priya Sharma',
      dateTime: DateTime.now().add(const Duration(days: 8)),
      reason: 'Oncology Checkup',
    ),
  ];

  // ─── Scheduled Surgeries ──────────────────────────────────────────────────
  late final List<PatientSurgery> surgeries = [
    PatientSurgery(
      id: 'srg-001',
      patientId: 'pat-003',
      surgeonName: 'Dr. Robert Hayes',
      operationTheatre: 'OR-3',
      dateTime: DateTime.now().add(const Duration(days: 12)),
      procedure: 'Lumbar Spine Fusion',
    ),
  ];
}
