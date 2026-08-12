import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ─── User Role Enum ──────────────────────────────────────────────────────────
enum UserRole {
  administrator,
  doctor,
  insuranceReviewer,
  hospitalStaff,
  patient;

  String get displayName {
    switch (this) {
      case UserRole.administrator:    return 'Administrator';
      case UserRole.doctor:           return 'Doctor';
      case UserRole.insuranceReviewer:return 'Insurance Reviewer';
      case UserRole.hospitalStaff:    return 'Hospital Staff';
      case UserRole.patient:          return 'Patient';
    }
  }

  String get description {
    switch (this) {
      case UserRole.administrator:    return 'Full system access and administration';
      case UserRole.doctor:           return 'Clinical operations and patient management';
      case UserRole.insuranceReviewer:return 'Authorization review and approval workflow';
      case UserRole.hospitalStaff:    return 'Facility-scoped operations and record management';
      case UserRole.patient:          return 'Own case tracking and document submission';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.administrator:    return AppColors.error;
      case UserRole.doctor:           return AppColors.primary;
      case UserRole.insuranceReviewer:return AppColors.warning;
      case UserRole.hospitalStaff:    return AppColors.success;
      case UserRole.patient:          return AppColors.secondary;
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.administrator:    return Icons.admin_panel_settings_rounded;
      case UserRole.doctor:           return Icons.medical_services_rounded;
      case UserRole.insuranceReviewer:return Icons.policy_rounded;
      case UserRole.hospitalStaff:    return Icons.local_hospital_rounded;
      case UserRole.patient:          return Icons.person_rounded;
    }
  }
}

// ─── Permission Enum ──────────────────────────────────────────────────────────
/// All capability tokens used by the permission system.
/// Permissions are composed into role sets — never check role directly.
enum Permission {
  // Dashboard
  viewOrgWideDashboard,
  viewQueueDashboard,
  viewFacilityDashboard,

  // User management
  manageUsersAndRoles,

  // Authorizations
  createAuthorizationRequest,
  approveRequest,
  rejectRequest,
  escalateRequest,
  viewOwnCases,

  // AI Decision Center
  viewFullAiReasoning,
  viewAiSummaryOnly,

  // Appeals
  fileAppeal,
  trackAppeal,
  reviewAppeals,

  // Analytics
  viewAllAnalytics,
  viewOwnAnalytics,
  viewQueueAnalytics,
  viewFacilityAnalytics,

  // Audit Logs
  viewAllAuditLogs,
  viewOwnAuditLogs,

  // Integrations
  manageFhirIntegrations,

  // Documents
  uploadDocuments,
  viewDocumentsOnly,

  // Settings / Profile
  viewSettings,
  manageSettings,
  viewProfile,

  // Access Control
  manageAccessControl,

  // Notifications
  viewNotifications,

  // Insurance Claims
  viewInsuranceClaims,
}

// ─── Role → Permission Mapping ───────────────────────────────────────────────
/// The canonical RBAC table expressed as a Dart map.
/// Add new roles by extending this map — no scattered role checks needed.
const Map<UserRole, Set<Permission>> rolePermissions = {
  UserRole.administrator: {
    Permission.viewOrgWideDashboard,
    Permission.viewQueueDashboard,
    Permission.viewFacilityDashboard,
    Permission.manageUsersAndRoles,
    Permission.createAuthorizationRequest,
    Permission.approveRequest,
    Permission.rejectRequest,
    Permission.escalateRequest,
    Permission.viewOwnCases,
    Permission.viewFullAiReasoning,
    Permission.fileAppeal,
    Permission.trackAppeal,
    Permission.reviewAppeals,
    Permission.viewAllAnalytics,
    Permission.viewAllAuditLogs,
    Permission.manageFhirIntegrations,
    Permission.uploadDocuments,
    Permission.viewSettings,
    Permission.manageSettings,
    Permission.viewProfile,
    Permission.manageAccessControl,
    Permission.viewNotifications,
    Permission.viewInsuranceClaims,
  },
  UserRole.doctor: {
    Permission.createAuthorizationRequest,
    Permission.viewOwnCases,
    Permission.viewFullAiReasoning,
    Permission.fileAppeal,
    Permission.trackAppeal,
    Permission.viewOwnAnalytics,
    Permission.uploadDocuments,
    Permission.viewSettings,
    Permission.viewProfile,
    Permission.viewNotifications,
    Permission.viewInsuranceClaims,
  },
  UserRole.insuranceReviewer: {
    Permission.viewQueueDashboard,
    Permission.approveRequest,
    Permission.rejectRequest,
    Permission.escalateRequest,
    Permission.viewOwnCases,
    Permission.viewFullAiReasoning,
    Permission.fileAppeal,
    Permission.trackAppeal,
    Permission.reviewAppeals,
    Permission.viewQueueAnalytics,
    Permission.viewOwnAuditLogs,
    Permission.viewDocumentsOnly,
    Permission.viewSettings,
    Permission.viewProfile,
    Permission.viewNotifications,
  },
  UserRole.hospitalStaff: {
    Permission.viewFacilityDashboard,
    Permission.createAuthorizationRequest,
    Permission.viewOwnCases,
    Permission.viewAiSummaryOnly,
    Permission.fileAppeal,
    Permission.trackAppeal,
    Permission.viewFacilityAnalytics,
    Permission.uploadDocuments,
    Permission.viewSettings,
    Permission.viewProfile,
    Permission.viewNotifications,
  },
  UserRole.patient: {
    Permission.viewOwnCases,
    Permission.trackAppeal,
    Permission.uploadDocuments,
    Permission.viewProfile,
    Permission.viewNotifications,
    Permission.viewInsuranceClaims,
  },
};

// ─── Permission Check Helper ─────────────────────────────────────────────────
extension UserRoleExtension on UserRole {
  /// Returns true if this role has the given permission.
  bool hasPermission(Permission permission) {
    return rolePermissions[this]?.contains(permission) ?? false;
  }

  /// Returns true if this role has ALL of the given permissions.
  bool hasAllPermissions(List<Permission> permissions) {
    return permissions.every((p) => hasPermission(p));
  }

  /// Returns true if this role has ANY of the given permissions.
  bool hasAnyPermission(List<Permission> permissions) {
    return permissions.any((p) => hasPermission(p));
  }
}
