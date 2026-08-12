import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
};

const _demoPasswords = <String, String>{
  'admin@mediauth.ai':    'Admin@123',
  'dr.johnson@mediauth.ai': 'Doctor@123',
  'reviewer@mediauth.ai': 'Review@123',
  'staff@mediauth.ai':    'Staff@123',
  'patient@mediauth.ai':  'Patient@123',
};

const _kSessionEmailKey = 'mediauth_session_email';

// ─── Auth Notifier ────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.initial)) {
    _restoreSession();
  }

  /// Restore session from local storage on app start.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_kSessionEmailKey);
      if (email != null && _demoUsers.containsKey(email)) {
        final user = _demoUsers[email]!.copyWith(
          lastLoginAt: DateTime.now(),
        );
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Sign in with email + password (mock validation).
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1200));

    final normalizedEmail = email.trim().toLowerCase();
    if (_demoUsers.containsKey(normalizedEmail) &&
        _demoPasswords[normalizedEmail] == password) {
      final user = _demoUsers[normalizedEmail]!.copyWith(
        lastLoginAt: DateTime.now(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSessionEmailKey, normalizedEmail);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    }

    state = AuthState(
      status: AuthStatus.error,
      errorMessage: 'Invalid email or password. Use a demo account to sign in.',
    );
    return false;
  }

  /// Sign out and clear session.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionEmailKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear any displayed error.
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Update current user's profile details.
  void updateProfile({
    required String name,
    required String email,
    String? facility,
    String? specialization,
    String? licenseNumber,
  }) {
    if (state.user != null) {
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
