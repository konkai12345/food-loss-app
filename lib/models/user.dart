import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final List<String> familyIds;
  final Map<String, dynamic> preferences;

  User({
    String? id,
    required String name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    List<String>? familyIds,
    Map<String, dynamic>? preferences,
  }) : id = id ?? Uuid().v4(),
       name = name,
       email = email ?? '',
       avatarUrl = avatarUrl ?? '',
       createdAt = createdAt ?? DateTime.now(),
       lastLoginAt = lastLoginAt ?? DateTime.now(),
       isActive = isActive ?? true,
       familyIds = familyIds ?? [],
       preferences = preferences ?? {};

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isActive: json['isActive'],
      familyIds: List<String>.from(json['familyIds'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isActive': isActive,
      'familyIds': familyIds,
      'preferences': preferences,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    List<String>? familyIds,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      familyIds: familyIds ?? this.familyIds,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Family {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<String> memberIds;
  final Map<String, dynamic> settings;

  Family({
    String? id,
    required String name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    Map<String, dynamic>? settings,
  }) : id = id ?? Uuid().v4(),
       name = name,
       description = description ?? '',
       createdBy = createdBy ?? '',
       createdAt = createdAt ?? DateTime.now(),
       memberIds = memberIds ?? [],
       settings = settings ?? {};

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      memberIds: List<String>.from(json['memberIds'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'memberIds': memberIds,
      'settings': settings,
    };
  }

  Family copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    List<String>? memberIds,
    Map<String, dynamic>? settings,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Family && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class FamilyMember {
  final String id;
  final String familyId;
  final String userId;
  final String userName;
  final String userEmail;
  final String role;
  final DateTime joinedAt;
  final bool isActive;
  final Map<String, dynamic> permissions;

  FamilyMember({
    String? id,
    required String familyId,
    required String userId,
    required String userName,
    required String userEmail,
    String? role,
    DateTime? joinedAt,
    bool? isActive,
    Map<String, dynamic>? permissions,
  }) : id = id ?? Uuid().v4(),
       familyId = familyId,
       userId = userId,
       userName = userName,
       userEmail = userEmail,
       role = role ?? 'member',
       joinedAt = joinedAt ?? DateTime.now(),
       isActive = isActive ?? true,
       permissions = permissions ?? {};

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      familyId: json['familyId'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joinedAt']),
      isActive: json['isActive'],
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyId': familyId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
      'permissions': permissions,
    };
  }

  FamilyMember copyWith({
    String? id,
    String? familyId,
    String? userId,
    String? userName,
    String? userEmail,
    String? role,
    DateTime? joinedAt,
    bool? isActive,
    Map<String, dynamic>? permissions,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyMember && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
