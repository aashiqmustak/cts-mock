import 'user_role.dart';

/// Represents an authenticated user in MediAuth AI.
class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final String? facility;       // Hospital/payer org name
  final String? specialization; // For doctors
  final String? licenseNumber;  // NPI for doctors
  final bool   isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.facility,
    this.specialization,
    this.licenseNumber,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  bool hasPermission(Permission permission) => role.hasPermission(permission);

  bool hasAnyPermission(List<Permission> permissions) => role.hasAnyPermission(permissions);

  bool hasAllPermissions(List<Permission> permissions) => role.hasAllPermissions(permissions);

  AppUser copyWith({
    String? name,
    String? avatarUrl,
    String? facility,
    String? specialization,
    bool? isActive,
    DateTime? lastLoginAt,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      facility: facility ?? this.facility,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'facility': facility,
    'specialization': specialization,
    'licenseNumber': licenseNumber,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere((r) => r.name == json['role']),
      avatarUrl: json['avatarUrl'] as String?,
      facility: json['facility'] as String?,
      specialization: json['specialization'] as String?,
      licenseNumber: json['licenseNumber'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }
}
