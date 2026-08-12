/// MediAuth AI — Application Constants
/// Central hub for all app-wide configuration values.
class AppConstants {
  AppConstants._();

  // ─── App Identity ─────────────────────────────────────────────────────────
  static const String appName = 'MediAuth AI';
  static const String appTagline = 'AI-Powered Prior Authorization Platform';
  static const String appVersion = '1.0.0';
  static const String companyName = 'MediAuth Systems, Inc.';

  // ─── SLA & Performance Targets ────────────────────────────────────────────
  /// Decision must complete within 5 seconds
  static const int slaThresholdMs = 5000;
  /// Target: 90% of requests decided instantly
  static const double instantDecisionTarget = 0.90;
  /// AI accuracy target: 95%+
  static const double aiAccuracyTarget = 0.95;
  /// Appeals prediction accuracy target: 80%
  static const double appealAccuracyTarget = 0.80;
  /// Auto-escalate to human review below this confidence
  static const double confidenceEscalationThreshold = 0.75;

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int tableDensePageSize = 50;

  // ─── Animation Durations ──────────────────────────────────────────────────
  static const int animShort   = 200;   // ms
  static const int animMedium  = 350;   // ms
  static const int animLong    = 600;   // ms
  static const int animCounter = 1500;  // ms — counter roll-up
  static const int animSla     = 500;   // ms — SLA ring update

  // ─── Dashboard Refresh ────────────────────────────────────────────────────
  /// How often mock stats refresh (ms)
  static const int dashboardRefreshMs = 8000;

  // ─── Sidebar ──────────────────────────────────────────────────────────────
  static const double sidebarExpandedWidth  = 260.0;
  static const double sidebarCollapsedWidth = 72.0;
  static const double sidebarBreakpoint    = 1100.0;

  // ─── Data Sources (for AI decision citations) ─────────────────────────────
  static const String dataSrcCms     = 'CMS Provider Utilization Data';
  static const String dataSrcMeps    = 'MEPS — Medical Expenditure Panel Survey';
  static const String dataSrcDailyMed = 'FDA DailyMed Drug Database';
  static const String dataSrcFhir    = 'HL7 FHIR R4';
  static const String dataSrcInternal = 'Internal Policy Engine';

  // ─── FHIR Resource Types ──────────────────────────────────────────────────
  static const List<String> fhirResourceTypes = [
    'Patient',
    'Coverage',
    'Claim',
    'ServiceRequest',
    'Observation',
    'Condition',
    'MedicationRequest',
    'Practitioner',
  ];

  // ─── Status Labels ────────────────────────────────────────────────────────
  static const String statusApproved  = 'Approved';
  static const String statusPending   = 'Pending';
  static const String statusRejected  = 'Rejected';
  static const String statusEscalated = 'Escalated';
  static const String statusUnderReview = 'Under Review';
  static const String statusDraft     = 'Draft';
  static const String statusWithdrawn = 'Withdrawn';

  // ─── Demo Credentials ─────────────────────────────────────────────────────
  static const List<Map<String, String>> demoCredentials = [
    {'email': 'admin@mediauth.ai',    'password': 'Admin@123',   'role': 'administrator',     'name': 'Alexandra Chen'},
    {'email': 'dr.johnson@mediauth.ai','password': 'Doctor@123', 'role': 'doctor',            'name': 'Dr. Michael Johnson'},
    {'email': 'reviewer@mediauth.ai', 'password': 'Review@123',  'role': 'insuranceReviewer', 'name': 'Sarah Williams'},
    {'email': 'staff@mediauth.ai',    'password': 'Staff@123',   'role': 'hospitalStaff',     'name': 'James Rodriguez'},
    {'email': 'patient@mediauth.ai',  'password': 'Patient@123', 'role': 'patient',           'name': 'Emily Thompson'},
  ];

  // ─── Fraud Anomaly Thresholds ─────────────────────────────────────────────
  static const double fraudHighRiskScore    = 0.75;
  static const double fraudMediumRiskScore  = 0.45;

  // ─── Chart Config ─────────────────────────────────────────────────────────
  static const int chartDays30  = 30;
  static const int chartDays60  = 60;
  static const int chartDays90  = 90;
}
