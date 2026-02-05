class UserModel {
  /// Firebase Auth UID
  final String uid;

  /// Core identity
  final String email;
  final String role; // "lecturer" | "student"

  /// Organization (school)
  final String orgId;

  /// Profile info (editable in Settings)
  final String? fullName;
  final String? avatarUrl;
  final String? department;
  final String? bio;

  /// Status
  final bool profileCompleted;
  final bool isActive;

  /// Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.orgId,
    this.fullName,
    this.avatarUrl,
    this.department,
    this.bio,
    required this.profileCompleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore → Model
  factory UserModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return UserModel(
      uid: json['uid'],
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'student').toString(),
      orgId: (json['orgId'] ?? '').toString(),
      fullName: json['fullName'],
      avatarUrl: json['avatarUrl'],
      department: json['department'],
      bio: json['bio'],
      profileCompleted: json['profileCompleted'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email.toLowerCase(),
      'role': role,
      'orgId': orgId,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'department': department,
      'bio': bio,
      'profileCompleted': profileCompleted,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Helper: copyWith for updates
  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? department,
    String? bio,
    bool? profileCompleted,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      role: role,
      orgId: orgId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      department: department ?? this.department,
      bio: bio ?? this.bio,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convenience helpers
  bool get isLecturer => role == 'lecturer';
  bool get isStudent => role == 'student';

  bool isNewUser(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inMinutes < 10;
  }
}
