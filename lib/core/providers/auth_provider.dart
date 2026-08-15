import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:priorx/models/models.dart';
import 'package:priorx/repositories/data_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}
// ─── Auth Notifier ────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final _supabase = Supabase.instance.client;

  AuthNotifier() : super(const AuthState(status: AuthStatus.initial)) {
    _restoreSession();
  }

  AppUser _mapSupabaseUserToAppUser(User sbUser) {
    final email = sbUser.email ?? '';
    final meta = sbUser.userMetadata ?? {};
    
    // Extract metadata values
    final name = meta['name'] as String? ?? email.split('@').first;
    
    // Map role
    UserRole role = UserRole.patient; // Default role
    if (meta['role'] != null) {
      final roleStr = meta['role'] as String;
      try {
        role = UserRole.values.firstWhere((r) => r.name == roleStr);
      } catch (_) {}
    }
    
    final facility = meta['facility'] as String?;
    final hospitalId = (meta['hospitalId'] ?? meta['hospital_id']) as String?;
    final specialization = meta['specialization'] as String?;
    final licenseNumber = meta['licenseNumber'] as String?;
    
    return AppUser(
      id: sbUser.id,
      name: name,
      email: email,
      role: role,
      facility: facility,
      hospitalId: hospitalId,
      specialization: specialization,
      licenseNumber: licenseNumber,
      isActive: true,
      createdAt: DateTime.tryParse(sbUser.createdAt) ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Restore session from Supabase on app start.
  Future<void> _restoreSession() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;
      if (session != null && user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: _mapSupabaseUserToAppUser(user),
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Sign in with email + password using Supabase.
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    final trimmedEmail = email.trim();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      if (response.user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: _mapSupabaseUserToAppUser(response.user!),
        );
        return true;
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      // If it's a specific credentials error, don't fall back to local mock
      if (errorStr.contains('invalid login credentials') || 
          errorStr.contains('invalid email') ||
          errorStr.contains('invalid password') ||
          errorStr.contains('user not found')) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Invalid email or password. Please check your credentials.',
        );
        return false;
      }

      // For network/configuration errors, fall back to checking our local mock database
      final emailLower = trimmedEmail.toLowerCase();
      
      // 1. Check Hardcoded Mock Accounts (admin, reviewer, staff)
      if (emailLower == 'admin@mediauth.ai') {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser(
            id: 'usr-admin',
            name: 'System Admin',
            email: 'admin@mediauth.ai',
            role: UserRole.administrator,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        return true;
      } else if (emailLower == 'reviewer@mediauth.ai') {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser(
            id: 'usr-reviewer',
            name: 'John Reviewer',
            email: 'reviewer@mediauth.ai',
            role: UserRole.insuranceReviewer,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        return true;
      } else if (emailLower == 'staff@mediauth.ai') {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser(
            id: 'usr-staff',
            name: 'Sarah Jenkins',
            email: 'staff@mediauth.ai',
            role: UserRole.adminHospital,
            facility: 'Metropolitan General Hospital',
            hospitalId: 'fac-001',
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        return true;
      }

      // 2. Check Mock Doctor Database
      Doctor? foundDoctor;
      for (final d in DataRepository.instance.doctors) {
        if (d.email.toLowerCase() == emailLower) {
          foundDoctor = d;
          break;
        }
      }
      if (foundDoctor != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser(
            id: foundDoctor.id,
            name: foundDoctor.name,
            email: foundDoctor.email,
            role: UserRole.doctor,
            facility: foundDoctor.facility,
            hospitalId: foundDoctor.hospitalId,
            specialization: foundDoctor.specialization,
            licenseNumber: foundDoctor.npi,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        return true;
      }

      // 3. Check Mock Patient Database
      Patient? foundPatient;
      for (final p in DataRepository.instance.patients) {
        if (p.contactEmail?.toLowerCase() == emailLower) {
          foundPatient = p;
          break;
        }
      }
      if (foundPatient != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: AppUser(
            id: foundPatient.id,
            name: foundPatient.name,
            email: foundPatient.contactEmail ?? trimmedEmail,
            role: UserRole.patient,
            facility: 'Metropolitan General Hospital',
            hospitalId: foundPatient.facilityId,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        );
        return true;
      }

      // 4. Default Connection Error message if credentials don't match any mock user either
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Network error or invalid credentials. To test offline, please use a mock account like dr.johnson@mediauth.ai or admin@mediauth.ai.',
      );
    }
    return false;
  }

  /// Sign up a new user with Supabase.
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? facility,
    String? specialization,
    String? licenseNumber,
    String? phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'role': role.name,
          if (facility != null) 'facility': facility,
          if (specialization != null) 'specialization': specialization,
          if (licenseNumber != null) 'licenseNumber': licenseNumber,
          if (phone != null) 'phone': phone,
        },
      );

      final user = response.user;
      if (user != null) {
        final userId = user.id;

        // Map facility name to facility ID (hospitals mapping helper)
        String? hospitalId;
        if (facility != null) {
          if (facility.toLowerCase().contains('metro')) {
            hospitalId = 'fac-001';
          } else if (facility.toLowerCase().contains('city')) {
            hospitalId = 'fac-002';
          } else if (facility.toLowerCase().contains('sunrise')) {
            hospitalId = 'fac-003';
          } else {
            hospitalId = facility;
          }
        }

        // 1. Create / Update Profiles row
        try {
          await _supabase.from('profiles').upsert({
            'id': userId,
            'name': name,
            'email': email.trim(),
            'role': role.name,
            if (facility != null) 'facility': facility,
            if (hospitalId != null) 'hospital_id': hospitalId,
            if (specialization != null) 'specialization': specialization,
            if (licenseNumber != null) 'license_number': licenseNumber,
            if (phone != null) 'phone': phone,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {}

        // 2. Create / Update Role-Specific Table Record
        try {
          switch (role) {
            case UserRole.patient:
              await _supabase.from('patients').upsert({
                'id': userId,
                'name': name,
                'contact_email': email.trim(),
                'facility_id': hospitalId ?? 'fac-001',
                'date_of_birth': '1990-01-01',
                'gender': 'Unspecified',
                'insurance_id': 'INS-PENDING',
                'insurance_plan': 'Standard Health Plan',
                'payer': 'PriorX Health',
                'contact_phone': phone ?? 'N/A',
              });
              break;

            case UserRole.doctor:
              await _supabase.from('doctors').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'npi': licenseNumber ?? 'NPI-PENDING',
                'specialization': specialization ?? 'General Medicine',
                'facility': facility ?? 'Metropolitan General Hospital',
                'hospital_id': hospitalId ?? 'fac-001',
                'phone': phone ?? 'N/A',
                'is_active': true,
              });
              break;

            case UserRole.insuranceReviewer:
              await _supabase.from('insurance_reviewers').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'PriorX Insurance',
                'phone': phone,
              });
              break;

            case UserRole.hospitalStaff:
              await _supabase.from('hospital_staff').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'Metropolitan General Hospital',
                'hospital_id': hospitalId ?? 'fac-001',
                'phone': phone,
              });
              break;

            case UserRole.adminHospital:
              await _supabase.from('hospital_admins').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'Metropolitan General Hospital',
                'hospital_id': hospitalId ?? 'fac-001',
                'phone': phone,
              });
              break;

            case UserRole.administrator:
              await _supabase.from('administrators').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'MediAuth Systems HQ',
                'phone': phone,
              });
              break;
          }
        } catch (e) {
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: 'Failed to create ${role.displayName} record: $e',
          );
          return false;
        }

        state = AuthState(
          status: AuthStatus.authenticated,
          user: _mapSupabaseUserToAppUser(user),
        );
        return true;
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('AuthException: ', ''),
      );
    }
    return false;
  }

  /// Sign out and clear Supabase session.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear any displayed error.
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Update current user's profile details.
  Future<void> updateProfile({
    required String name,
    required String email,
    String? facility,
    String? specialization,
    String? licenseNumber,
  }) async {
    if (state.user != null) {
      try {
        String? localHospId;
        if (facility != null) {
          if (facility.toLowerCase().contains('metro')) {
            localHospId = 'fac-001';
          } else if (facility.toLowerCase().contains('city')) {
            localHospId = 'fac-002';
          } else if (facility.toLowerCase().contains('sunrise')) {
            localHospId = 'fac-003';
          } else {
            localHospId = facility;
          }
        }

        final response = await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'name': name,
              'facility': facility,
              'hospitalId': localHospId,
              'specialization': specialization,
              'licenseNumber': licenseNumber,
            },
          ),
        );
        if (response.user != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: _mapSupabaseUserToAppUser(response.user!),
          );
        }
      } catch (e) {
        // Fallback to local update if Supabase fails or isn't fully configured
        String? localHospId;
        if (facility != null) {
          if (facility.toLowerCase().contains('metro')) {
            localHospId = 'fac-001';
          } else if (facility.toLowerCase().contains('city')) {
            localHospId = 'fac-002';
          } else if (facility.toLowerCase().contains('sunrise')) {
            localHospId = 'fac-003';
          } else {
            localHospId = facility;
          }
        }

        final fullUser = AppUser(
          id: state.user!.id,
          name: name,
          email: email,
          role: state.user!.role,
          avatarUrl: state.user!.avatarUrl,
          facility: facility,
          hospitalId: localHospId,
          specialization: specialization,
          licenseNumber: licenseNumber,
          isActive: state.user!.isActive,
          createdAt: state.user!.createdAt,
          lastLoginAt: state.user!.lastLoginAt,
        );
        state = AuthState(status: AuthStatus.authenticated, user: fullUser);
      }
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

/// Convenience selector: current user (nullable).
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authProvider).user;
});

/// Convenience selector: current role (nullable).
final currentRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).user?.role;
});

/// Permission check provider factory.
/// Usage: `ref.watch(hasPermissionProvider(Permission.approveRequest))`
final hasPermissionProvider = Provider.family<bool, Permission>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  return user?.hasPermission(permission) ?? false;
});

/// Check if current user has any of the given permissions.
final hasAnyPermissionProvider = Provider.family<bool, List<Permission>>((ref, permissions) {
  final role = ref.watch(currentRoleProvider);
  return role?.hasAnyPermission(permissions) ?? false;
});
