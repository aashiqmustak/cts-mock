/// MediAuth AI — Route Name Constants
/// Single source of truth for all named routes (used by GoRouter + navigation).
class RouteNames {
  RouteNames._();

  static const String splash         = '/';
  static const String login          = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String register       = '/register';

  // ─── Shell routes (require auth) ──────────────────────────────────────────
  static const String dashboard      = '/dashboard';

  // Patients
  static const String patients       = '/patients';
  static const String patientDetail  = '/patients/:id';

  // Doctors
  static const String doctors        = '/doctors';
  static const String doctorDetail   = '/doctors/:id';

  // Prior Authorization
  static const String authorizations        = '/authorizations';
  static const String createAuthorization   = '/authorizations/new';
  static const String authorizationDetail   = '/authorizations/:id';

  // Insurance Review
  static const String insuranceReview       = '/insurance-review';
  static const String insuranceReviewDetail = '/insurance-review/:id';

  // AI Decision Center
  static const String aiDecisionCenter      = '/ai-decisions';
  static const String aiDecisionDetail      = '/ai-decisions/:id';

  // Appeals
  static const String appeals               = '/appeals';
  static const String appealDetail          = '/appeals/:id';

  // Analytics
  static const String analytics             = '/analytics';

  // Medical Records
  static const String medicalRecords        = '/medical-records';

  // Insurance Claims
  static const String insuranceClaims       = '/insurance-claims';

  // Notifications
  static const String notifications         = '/notifications';

  // Audit Logs
  static const String auditLogs             = '/audit-logs';

  // Access Control
  static const String accessControl         = '/access-control';

  // Settings
  static const String settings              = '/settings';
  static const String integrations          = '/settings/integrations';

  // Profile
  static const String profile               = '/profile';

  // Task Flow Preview
  static const String taskFlow              = '/task-flow';

  // Error pages
  static const String error403              = '/403';
  static const String error404              = '/404';
}
