import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_role.dart';
import '../constants/route_constants.dart';
import '../providers/auth_provider.dart';

// ─── Feature Screens (imported lazily) ───────────────────────────────────────
import '../../features/authentication/presentation/splash_screen.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/prior_authorization/presentation/authorization_list_screen.dart';
import '../../features/prior_authorization/presentation/authorization_detail_screen.dart';
import '../../features/prior_authorization/presentation/create_authorization_screen.dart';
import '../../features/insurance_review/presentation/insurance_review_screen.dart';
import '../../features/ai_decision_center/presentation/ai_decision_center_screen.dart';
import '../../features/appeals/presentation/appeals_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/patients/presentation/patient_detail_screen.dart';
import '../../features/doctors/presentation/doctors_screen.dart';
import '../../features/medical_records/presentation/medical_records_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/audit_logs/presentation/audit_logs_screen.dart';
import '../../features/access_control/presentation/access_control_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/integrations/presentation/integrations_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/insurance_claims/presentation/insurance_claims_screen.dart';
import '../../features/error/error_403_screen.dart';
import '../../features/error/error_404_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/task_flow/presentation/task_flow_screen.dart';

// ─── Router Provider ──────────────────────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthScreen = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.forgotPassword ||
          state.matchedLocation == RouteNames.splash;

      // Not authenticated → go to login
      if (!isAuthenticated && !isOnAuthScreen) return RouteNames.login;

      // Authenticated → redirect away from auth screens
      if (isAuthenticated && isOnAuthScreen && state.matchedLocation != RouteNames.splash) {
        return RouteNames.dashboard;
      }

      // Permission-gated routes
      if (isAuthenticated) {
        final user = authState.user!;
        final path = state.matchedLocation;

        // Admin-only routes
        if ((path.startsWith(RouteNames.accessControl) ||
             path == RouteNames.integrations) &&
            !user.hasPermission(Permission.manageAccessControl)) {
          return RouteNames.error403;
        }

        // Reviewer-required routes
        if (path.startsWith(RouteNames.insuranceReview) &&
            !user.hasPermission(Permission.approveRequest)) {
          return RouteNames.error403;
        }

        // Patients list (only viewable by clinical staff / reviewers / admins)
        if (path == RouteNames.patients &&
            !user.hasPermission(Permission.createAuthorizationRequest) &&
            !user.hasPermission(Permission.approveRequest)) {
          return RouteNames.error403;
        }

        // Audit logs
        if (path.startsWith(RouteNames.auditLogs) &&
            !user.hasAnyPermission([Permission.viewAllAuditLogs, Permission.viewOwnAuditLogs])) {
          return RouteNames.error403;
        }
      }

      return null;
    },
    routes: [
      // ─── Public routes ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (ctx, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.taskFlow,
        name: 'taskFlow',
        builder: (ctx, state) => const TaskFlowScreen(),
      ),

      // ─── Shell (authenticated) ───────────────────────────────────────────
      ShellRoute(
        builder: (ctx, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            builder: (ctx, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.patients,
            name: 'patients',
            builder: (ctx, state) => const PatientsScreen(),
          ),
          GoRoute(
            path: RouteNames.patientDetail,
            name: 'patientDetail',
            builder: (ctx, state) => PatientDetailScreen(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteNames.doctors,
            name: 'doctors',
            builder: (ctx, state) => const DoctorsScreen(),
          ),
          GoRoute(
            path: RouteNames.authorizations,
            name: 'authorizations',
            builder: (ctx, state) => const AuthorizationListScreen(),
          ),
          GoRoute(
            path: RouteNames.createAuthorization,
            name: 'createAuthorization',
            builder: (ctx, state) => const CreateAuthorizationScreen(),
          ),
          GoRoute(
            path: RouteNames.authorizationDetail,
            name: 'authorizationDetail',
            builder: (ctx, state) => AuthorizationDetailScreen(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteNames.insuranceReview,
            name: 'insuranceReview',
            builder: (ctx, state) => const InsuranceReviewScreen(),
          ),
          GoRoute(
            path: RouteNames.aiDecisionCenter,
            name: 'aiDecisionCenter',
            builder: (ctx, state) => const AiDecisionCenterScreen(),
          ),
          GoRoute(
            path: RouteNames.appeals,
            name: 'appeals',
            builder: (ctx, state) => const AppealsScreen(),
          ),
          GoRoute(
            path: RouteNames.analytics,
            name: 'analytics',
            builder: (ctx, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: RouteNames.medicalRecords,
            name: 'medicalRecords',
            builder: (ctx, state) => const MedicalRecordsScreen(),
          ),
          GoRoute(
            path: RouteNames.insuranceClaims,
            name: 'insuranceClaims',
            builder: (ctx, state) => const InsuranceClaimsScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (ctx, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.auditLogs,
            name: 'auditLogs',
            builder: (ctx, state) => const AuditLogsScreen(),
          ),
          GoRoute(
            path: RouteNames.accessControl,
            name: 'accessControl',
            builder: (ctx, state) => const AccessControlScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            name: 'settings',
            builder: (ctx, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.integrations,
            name: 'integrations',
            builder: (ctx, state) => const IntegrationsScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (ctx, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ─── Error pages ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.error403,
        name: 'error403',
        builder: (ctx, state) => const Error403Screen(),
      ),
      GoRoute(
        path: RouteNames.error404,
        name: 'error404',
        builder: (ctx, state) => const Error404Screen(),
      ),
    ],
    errorBuilder: (ctx, state) => const Error404Screen(),
  );
});
