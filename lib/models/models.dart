import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

// ─── Authorization Status ─────────────────────────────────────────────────────
enum AuthorizationStatus {
  draft,
  pending,
  underReview,
  approved,
  rejected,
  escalated,
  withdrawn;

  String get label {
    switch (this) {
      case AuthorizationStatus.draft:       return 'Draft';
      case AuthorizationStatus.pending:     return 'Pending';
      case AuthorizationStatus.underReview: return 'Under Review';
      case AuthorizationStatus.approved:    return 'Approved';
      case AuthorizationStatus.rejected:    return 'Rejected';
      case AuthorizationStatus.escalated:   return 'Escalated';
      case AuthorizationStatus.withdrawn:   return 'Withdrawn';
    }
  }

  Color get color {
    switch (this) {
      case AuthorizationStatus.draft:       return AppColors.neutral500;
      case AuthorizationStatus.pending:     return AppColors.warning;
      case AuthorizationStatus.underReview: return AppColors.info;
      case AuthorizationStatus.approved:    return AppColors.success;
      case AuthorizationStatus.rejected:    return AppColors.error;
      case AuthorizationStatus.escalated:   return AppColors.escalated;
      case AuthorizationStatus.withdrawn:   return AppColors.neutral400;
    }
  }

  Color get bgColor {
    switch (this) {
      case AuthorizationStatus.draft:       return AppColors.neutral100;
      case AuthorizationStatus.pending:     return AppColors.warningLight;
      case AuthorizationStatus.underReview: return const Color(0xFFCFFAFE);
      case AuthorizationStatus.approved:    return AppColors.successLight;
      case AuthorizationStatus.rejected:    return AppColors.errorLight;
      case AuthorizationStatus.escalated:   return AppColors.escalatedLight;
      case AuthorizationStatus.withdrawn:   return AppColors.neutral100;
    }
  }

  IconData get icon {
    switch (this) {
      case AuthorizationStatus.draft:       return Icons.edit_rounded;
      case AuthorizationStatus.pending:     return Icons.schedule_rounded;
      case AuthorizationStatus.underReview: return Icons.manage_search_rounded;
      case AuthorizationStatus.approved:    return Icons.check_circle_rounded;
      case AuthorizationStatus.rejected:    return Icons.cancel_rounded;
      case AuthorizationStatus.escalated:   return Icons.priority_high_rounded;
      case AuthorizationStatus.withdrawn:   return Icons.remove_circle_rounded;
    }
  }
}

// ─── Authorization Priority ───────────────────────────────────────────────────
enum AuthorizationPriority { routine, urgent, emergent, stat }

// ─── Authorization Request Model ──────────────────────────────────────────────
class AuthorizationRequest {
  final String id;
  final String authNumber;          // PA-2024-XXXXX
  final String patientId;
  final String patientName;
  final String patientDob;
  final String patientInsuranceId;
  final String requestingDoctorId;
  final String requestingDoctorName;
  final String facilityName;
  final String facilityNpi;
  final String diagnosisCode;       // ICD-10
  final String diagnosisDescription;
  final String procedureCode;       // CPT
  final String procedureDescription;
  final String? drugName;           // if applicable
  final String? drugNdc;            // NDC code from DailyMed
  final String insurancePlanId;
  final String insurancePlanName;
  final AuthorizationStatus status;
  final AuthorizationPriority priority;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final DateTime? decidedAt;
  final int? processingTimeMs;      // actual decision time
  final String? reviewerNotes;
  final String? rejectionReason;
  final String? policyClauseCited;
  final List<String> documentIds;
  final String? aiDecisionId;
  final bool isUrgent;
  final String? slaStatus;          // 'within_sla' | 'at_risk' | 'breached'

  // CMS data citation fields
  final String? dataSource;
  final String? cmsNpiNumber;
  final String? cmsSpecialty;

  const AuthorizationRequest({
    required this.id,
    required this.authNumber,
    required this.patientId,
    required this.patientName,
    required this.patientDob,
    required this.patientInsuranceId,
    required this.requestingDoctorId,
    required this.requestingDoctorName,
    required this.facilityName,
    required this.facilityNpi,
    required this.diagnosisCode,
    required this.diagnosisDescription,
    required this.procedureCode,
    required this.procedureDescription,
    this.drugName,
    this.drugNdc,
    required this.insurancePlanId,
    required this.insurancePlanName,
    required this.status,
    required this.priority,
    required this.requestedAt,
    this.reviewedAt,
    this.decidedAt,
    this.processingTimeMs,
    this.reviewerNotes,
    this.rejectionReason,
    this.policyClauseCited,
    this.documentIds = const [],
    this.aiDecisionId,
    this.isUrgent = false,
    this.slaStatus,
    this.dataSource,
    this.cmsNpiNumber,
    this.cmsSpecialty,
  });

  /// Whether this request was decided within the 5-second SLA.
  bool get isWithinSla =>
      processingTimeMs != null && processingTimeMs! <= AppConstants.slaThresholdMs;

  Duration? get processingDuration =>
      processingTimeMs != null ? Duration(milliseconds: processingTimeMs!) : null;
}

// ─── AI Reasoning Step ────────────────────────────────────────────────────────
class AiReasoningStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? citedValue;     // e.g., "ICD-10: I25.10"
  final String? policyRef;      // e.g., "Policy §4.2.1"
  final String dataSource;      // CMS / MEPS / DailyMed / Internal
  final bool passed;
  final double? score;          // 0.0–1.0 score for this step
  final List<String> details;   // Bullet-point breakdown

  const AiReasoningStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.citedValue,
    this.policyRef,
    required this.dataSource,
    required this.passed,
    this.score,
    this.details = const [],
  });
}

// ─── AI Decision Model ────────────────────────────────────────────────────────
class AiDecision {
  final String id;
  final String authorizationId;
  final String recommendation;    // 'approve' | 'reject' | 'escalate'
  final double confidenceScore;   // 0.0–1.0
  final double medicalNecessityScore;
  final double riskScore;
  final double appealLikelihood;  // probability of successful appeal
  final double? appealConfidenceLow;
  final double? appealConfidenceHigh;
  final bool autoEscalated;       // true if confidence < threshold
  final List<AiReasoningStep> reasoningChain;
  final String finalJustification;
  final DateTime processedAt;
  final int processingTimeMs;
  final String modelVersion;
  final Map<String, double> fraudSignals; // signal → score

  const AiDecision({
    required this.id,
    required this.authorizationId,
    required this.recommendation,
    required this.confidenceScore,
    required this.medicalNecessityScore,
    required this.riskScore,
    required this.appealLikelihood,
    this.appealConfidenceLow,
    this.appealConfidenceHigh,
    required this.autoEscalated,
    required this.reasoningChain,
    required this.finalJustification,
    required this.processedAt,
    required this.processingTimeMs,
    this.modelVersion = 'MediAuth-AI v2.4.1 (Gemini 2.5 Pro)',
    this.fraudSignals = const {},
  });

  bool get isHighConfidence => confidenceScore >= 0.85;
  bool get isLowConfidence  => confidenceScore < 0.75;
  bool get shouldEscalate   => isLowConfidence;

  Color get recommendationColor {
    switch (recommendation) {
      case 'approve':  return AppColors.success;
      case 'reject':   return AppColors.error;
      case 'escalate': return AppColors.escalated;
      default:         return AppColors.neutral500;
    }
  }
}

// ─── Hospital Model ───────────────────────────────────────────────────────────
class Hospital {
  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });
}

// ─── Patient Model ────────────────────────────────────────────────────────────
class Patient {
  final String id;
  final String name;
  final String dateOfBirth;
  final String gender;
  final String insuranceId;
  final String insurancePlan;
  final String payer;
  final String? primaryDiagnosis;
  final List<String> chronicConditions;
  final String? primaryPhysicianId;
  final String? primaryPhysicianName;
  final String contactPhone;
  final String? contactEmail;
  final String facilityId;
  final int totalAuthorizations;
  final int approvedAuthorizations;
  final int pendingAuthorizations;
  final DateTime? lastVisit;
  final String? mrn;            // Medical Record Number
  final String? guardianName;
  final String? guardianPhone;
  final String? guardianRelationship;

  const Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.insuranceId,
    required this.insurancePlan,
    required this.payer,
    this.primaryDiagnosis,
    this.chronicConditions = const [],
    this.primaryPhysicianId,
    this.primaryPhysicianName,
    required this.contactPhone,
    this.contactEmail,
    required this.facilityId,
    this.totalAuthorizations = 0,
    this.approvedAuthorizations = 0,
    this.pendingAuthorizations = 0,
    this.lastVisit,
    this.mrn,
    this.guardianName,
    this.guardianPhone,
    this.guardianRelationship,
  });
}

// ─── Doctor Model ─────────────────────────────────────────────────────────────
class Doctor {
  final String id;
  final String name;
  final String npi;
  final String specialization;
  final String facility;
  final String? hospitalId;
  final String email;
  final String phone;
  final int totalRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final double approvalRate;
  final double avgProcessingTimeMs;
  final String? cmsSpecialtyCode;
  final bool isActive;
  final String? availability;

  const Doctor({
    required this.id,
    required this.name,
    required this.npi,
    required this.specialization,
    required this.facility,
    this.hospitalId,
    required this.email,
    required this.phone,
    this.totalRequests = 0,
    this.approvedRequests = 0,
    this.rejectedRequests = 0,
    this.approvalRate = 0.0,
    this.avgProcessingTimeMs = 0.0,
    this.cmsSpecialtyCode,
    this.isActive = true,
    this.availability,
  });
}

// ─── Appeal Case Model ────────────────────────────────────────────────────────
enum AppealStatus {
  draft, submitted, underReview, upheld, overturned, withdrawn;

  String get statusLabel {
    switch (this) {
      case AppealStatus.draft:       return 'Draft';
      case AppealStatus.submitted:   return 'Submitted';
      case AppealStatus.underReview: return 'Under Review';
      case AppealStatus.upheld:      return 'Upheld';
      case AppealStatus.overturned:  return 'Overturned';
      case AppealStatus.withdrawn:  return 'Withdrawn';
    }
  }

  Color get statusColor {
    switch (this) {
      case AppealStatus.draft:       return AppColors.neutral500;
      case AppealStatus.submitted:   return AppColors.primary;
      case AppealStatus.underReview: return AppColors.info;
      case AppealStatus.upheld:      return AppColors.error;
      case AppealStatus.overturned:  return AppColors.success;
      case AppealStatus.withdrawn:  return AppColors.neutral400;
    }
  }
}

class AppealCase {
  final String id;
  final String appealNumber;
  final String authorizationId;
  final String authNumber;
  final String patientName;
  final String filedById;
  final String filedByName;
  final AppealStatus status;
  final DateTime filedAt;
  final DateTime? decidedAt;
  final String groundsForAppeal;
  final String? supportingEvidence;
  final double aiSuccessProbability;
  final double? aiProbabilityLow;
  final double? aiProbabilityHigh;
  final String? draftAppealLetter;
  final String? rejectionReason;
  final List<String> documentIds;

  const AppealCase({
    required this.id,
    required this.appealNumber,
    required this.authorizationId,
    required this.authNumber,
    required this.patientName,
    required this.filedById,
    required this.filedByName,
    required this.status,
    required this.filedAt,
    this.decidedAt,
    required this.groundsForAppeal,
    this.supportingEvidence,
    required this.aiSuccessProbability,
    this.aiProbabilityLow,
    this.aiProbabilityHigh,
    this.draftAppealLetter,
    this.rejectionReason,
    this.documentIds = const [],
  });

  Color get statusColor {
    switch (status) {
      case AppealStatus.draft:       return AppColors.neutral500;
      case AppealStatus.submitted:   return AppColors.warning;
      case AppealStatus.underReview: return AppColors.info;
      case AppealStatus.upheld:      return AppColors.success;
      case AppealStatus.overturned:  return AppColors.error;
      case AppealStatus.withdrawn:   return AppColors.neutral400;
    }
  }

  String get statusLabel {
    switch (status) {
      case AppealStatus.draft:       return 'Draft';
      case AppealStatus.submitted:   return 'Submitted';
      case AppealStatus.underReview: return 'Under Review';
      case AppealStatus.upheld:      return 'Upheld';
      case AppealStatus.overturned:  return 'Overturned';
      case AppealStatus.withdrawn:   return 'Withdrawn';
    }
  }
}

// ─── Audit Log Entry ──────────────────────────────────────────────────────────
class AuditLogEntry {
  final String id;
  final String action;          // 'authorization.approved', 'appeal.filed', etc.
  final String actorId;
  final String actorName;
  final String actorRole;
  final String? resourceId;
  final String? resourceType;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String entryHash;       // SHA-256-like short hash for tamper evidence
  final String? previousHash;   // chain link to previous entry
  final String ipAddress;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    this.resourceId,
    this.resourceType,
    required this.description,
    this.metadata = const {},
    required this.timestamp,
    required this.entryHash,
    this.previousHash,
    required this.ipAddress,
  });
}

// ─── Notification Model ───────────────────────────────────────────────────────
enum NotificationType { authorization, appeal, system, reminder, alert }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? resourceId;
  final String? resourceType;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.resourceId,
    this.resourceType,
    required this.createdAt,
  });

  Color get typeColor {
    switch (type) {
      case NotificationType.authorization: return AppColors.primary;
      case NotificationType.appeal:        return AppColors.warning;
      case NotificationType.system:        return AppColors.neutral500;
      case NotificationType.reminder:      return AppColors.info;
      case NotificationType.alert:         return AppColors.error;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotificationType.authorization: return Icons.assignment_rounded;
      case NotificationType.appeal:        return Icons.gavel_rounded;
      case NotificationType.system:        return Icons.info_rounded;
      case NotificationType.reminder:      return Icons.alarm_rounded;
      case NotificationType.alert:         return Icons.warning_rounded;
    }
  }
}

// ─── FHIR Resource Sync Status ────────────────────────────────────────────────
enum FhirSyncStatus { healthy, degraded, error, syncing }

class FhirResourceSync {
  final String resourceType;
  final FhirSyncStatus status;
  final int syncedCount;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final int? pendingCount;

  const FhirResourceSync({
    required this.resourceType,
    required this.status,
    required this.syncedCount,
    this.lastSyncAt,
    this.errorMessage,
    this.pendingCount,
  });

  Color get statusColor {
    switch (status) {
      case FhirSyncStatus.healthy:  return AppColors.success;
      case FhirSyncStatus.degraded: return AppColors.warning;
      case FhirSyncStatus.error:    return AppColors.error;
      case FhirSyncStatus.syncing:  return AppColors.info;
    }
  }
}

// ─── Analytics Snapshot ───────────────────────────────────────────────────────
class DashboardStats {
  final int totalRequests;
  final int approvedToday;
  final int pendingCount;
  final int rejectedToday;
  final double aiAccuracy;
  final double avgProcessingTimeMs;
  final double percentWithinSla;
  final double percentInstantDecision;
  final int appealsfield;
  final double appealSuccessRate;
  final double revenueSavedUsd;
  final int fraudFlagged;

  const DashboardStats({
    required this.totalRequests,
    required this.approvedToday,
    required this.pendingCount,
    required this.rejectedToday,
    required this.aiAccuracy,
    required this.avgProcessingTimeMs,
    required this.percentWithinSla,
    required this.percentInstantDecision,
    required this.appealsfield,
    required this.appealSuccessRate,
    required this.revenueSavedUsd,
    required this.fraudFlagged,
  });
}

class PatientAppointment {
  final String id;
  final String patientId;
  final String doctorName;
  final DateTime dateTime;
  final String reason;

  const PatientAppointment({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.dateTime,
    required this.reason,
  });
}

class PatientSurgery {
  final String id;
  final String patientId;
  final String surgeonName;
  final String operationTheatre;
  final DateTime dateTime;
  final String procedure;

  const PatientSurgery({
    required this.id,
    required this.patientId,
    required this.surgeonName,
    required this.operationTheatre,
    required this.dateTime,
    required this.procedure,
  });
}

