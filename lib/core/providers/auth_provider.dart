import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ─── Seeded Demo Users ────────────────────────────────────────────────────────
final _demoUsers = <String, AppUser>{
  'admin@mediauth.ai': AppUser(
    id: 'usr-001',
    name: 'Alexandra Chen',
    email: 'admin@mediauth.ai',
    role: UserRole.administrator,
    facility: 'MediAuth Systems HQ',
    createdAt: DateTime(2024, 1, 15),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  'dr.johnson@mediauth.ai': AppUser(
    id: 'usr-002',
    name: 'Dr. Michael Johnson',
    email: 'dr.johnson@mediauth.ai',
    role: UserRole.doctor,
    facility: 'Metropolitan General Hospital',
    specialization: 'Cardiology',
    licenseNumber: 'NPI-1234567890',
    createdAt: DateTime(2024, 2, 10),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  'reviewer@mediauth.ai': AppUser(
    id: 'usr-003',
    name: 'Sarah Williams',
    email: 'reviewer@mediauth.ai',
    role: UserRole.insuranceReviewer,
    facility: 'BlueCross BlueShield — Northeast',
    createdAt: DateTime(2024, 3, 5),
    lastLoginAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  'staff@mediauth.ai': AppUser(
    id: 'usr-004',
    name: 'James Rodriguez',
    email: 'staff@mediauth.ai',
    role: UserRole.hospitalStaff,
    facility: 'Metropolitan General Hospital',
    createdAt: DateTime(2024, 4, 20),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  'patient@mediauth.ai': AppUser(
    id: 'usr-005',
    name: 'Emily Thompson',
    email: 'patient@mediauth.ai',
    role: UserRole.patient,
    createdAt: DateTime(2024, 5, 8),
    lastLoginAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  'hospital_admin@mediauth.ai': AppUser(
    id: 'usr-006',
    name: 'Sarah Jenkins',
    email: 'hospital_admin@mediauth.ai',
    role: UserRole.adminHospital,
    facility: 'Metropolitan General Hospital',
    createdAt: DateTime(2024, 6, 12),
    lastLoginAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
};

const _demoPasswords = <String, String>{
  'admin@mediauth.ai':    'Admin@123',
  'dr.johnson@mediauth.ai': 'Doctor@123',
  'reviewer@mediauth.ai': 'Review@123',
  'staff@mediauth.ai':    'Staff@123',
  'patient@mediauth.ai':  'Patient@123',
  'hospital_admin@mediauth.ai': 'Admin@123',
};

const _kSessionEmailKey = 'mediauth_session_email';

// ─── Auth Notifier ────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final _supabase = Supabase.instance.client;

  AuthNotifier() : super(const AuthState(status: AuthStatus.initial)) {
    _restoreSession();
  }

  AppUser _mapSupabaseUserToAppUser(User sbUser) {
    final email = sbUser.email ?? '';
    final meta = sbUser.userMetadata ?? {};
    
    // Check if there is demo data for this email first (useful for testing with seeded accounts)
    final demo = _demoUsers[email.trim().toLowerCase()];
    
    // Extract metadata values
    final name = meta['name'] as String? ?? demo?.name ?? email.split('@').first;
    
    // Map role
    UserRole role = UserRole.patient; // Default role
    if (meta['role'] != null) {
      final roleStr = meta['role'] as String;
      try {
        role = UserRole.values.firstWhere((r) => r.name == roleStr);
      } catch (_) {}
    } else if (demo != null) {
      role = demo.role;
    }
    
    final facility = meta['facility'] as String? ?? demo?.facility;
    final specialization = meta['specialization'] as String? ?? demo?.specialization;
    final licenseNumber = meta['licenseNumber'] as String? ?? demo?.licenseNumber;
    
    return AppUser(
      id: sbUser.id,
      name: name,
      email: email,
      role: role,
      facility: facility,
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
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
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
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('AuthException: ', ''),
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
        },
      );

      final user = response.user;
      if (user != null) {
        final userId = user.id;

        // 1. Create / Update Profiles row
        try {
          await _supabase.from('profiles').upsert({
            'id': userId,
            'name': name,
            'email': email.trim(),
            'role': role.name,
            if (facility != null) 'facility': facility,
            if (specialization != null) 'specialization': specialization,
            if (licenseNumber != null) 'license_number': licenseNumber,
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
                'facility_id': facility ?? 'FAC-001',
                'date_of_birth': '1990-01-01',
                'gender': 'Unspecified',
                'insurance_id': 'INS-PENDING',
                'insurance_plan': 'Standard Health Plan',
                'payer': 'PriorX Health',
                'contact_phone': 'N/A',
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
                'phone': 'N/A',
                'is_active': true,
              });
              break;

            case UserRole.insuranceReviewer:
              await _supabase.from('insurance_reviewers').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'PriorX Insurance',
              });
              break;

            case UserRole.hospitalStaff:
              await _supabase.from('hospital_staff').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'Metropolitan General Hospital',
              });
              break;

            case UserRole.adminHospital:
              await _supabase.from('hospital_admins').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'Metropolitan General Hospital',
              });
              break;

            case UserRole.administrator:
              await _supabase.from('administrators').upsert({
                'id': userId,
                'name': name,
                'email': email.trim(),
                'facility': facility ?? 'MediAuth Systems HQ',
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
        final response = await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'name': name,
              'facility': facility,
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
        final fullUser = AppUser(
          id: state.user!.id,
          name: name,
          email: email,
          role: state.user!.role,
          avatarUrl: state.user!.avatarUrl,
          facility: facility,
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
