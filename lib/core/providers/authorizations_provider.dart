import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../models/user_role.dart';
import '../../repositories/mock/mock_data_repository.dart';
import 'auth_provider.dart';

/// The central filtered authorizations provider.
/// Automatically filters the list based on the active session user's role and name.
final authorizationsProvider = Provider<List<AuthorizationRequest>>((ref) {
  final user = ref.watch(currentUserProvider);
  final all = MockDataRepository.instance.authorizations;
  if (user == null) return [];
  
  if (user.role == UserRole.patient) {
    return all.where((a) => a.patientName.toLowerCase() == user.name.toLowerCase()).toList();
  } else if (user.role == UserRole.doctor) {
    return all.where((a) => a.requestingDoctorName.toLowerCase() == user.name.toLowerCase()).toList();
  }
  return all;
});

/// Dynamically calculates dashboard stats based on the filtered authorizations.
final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final auths = ref.watch(authorizationsProvider);
  
  final total = auths.length;
  final approved = auths.where((a) => a.status == AuthorizationStatus.approved).length;
  final pending = auths.where((a) => a.status == AuthorizationStatus.pending || a.status == AuthorizationStatus.underReview).length;
  final rejected = auths.where((a) => a.status == AuthorizationStatus.rejected).length;

  // Average processing time
  final decidedCases = auths.where((a) => a.processingTimeMs != null).toList();
  final avgTime = decidedCases.isEmpty
      ? 0.0
      : decidedCases.map((a) => a.processingTimeMs!).reduce((a, b) => a + b) / decidedCases.length;

  // SLA percentage
  final withinSla = decidedCases.where((a) => a.isWithinSla).length;
  final slaRate = decidedCases.isEmpty ? 1.0 : withinSla / decidedCases.length;

  // Instant decision rate (decided in < 3 seconds)
  final instant = decidedCases.where((a) => a.processingTimeMs! <= 3000).length;
  final instantRate = decidedCases.isEmpty ? 1.0 : instant / decidedCases.length;

  // Appeals count
  final appeals = auths.where((a) => a.status == AuthorizationStatus.escalated || a.status == AuthorizationStatus.rejected).length;
  
  return DashboardStats(
    totalRequests: total,
    approvedToday: approved,
    pendingCount: pending,
    rejectedToday: rejected,
    aiAccuracy: 0.962, // system accuracy baseline
    avgProcessingTimeMs: avgTime.roundToDouble(),
    percentWithinSla: slaRate,
    percentInstantDecision: instantRate,
    appealsfield: appeals,
    appealSuccessRate: 0.783,
    revenueSavedUsd: (approved * 15000.0), // Estimate $15k per approved treatment
    fraudFlagged: auths.where((a) => a.status == AuthorizationStatus.escalated).length,
  );
});
