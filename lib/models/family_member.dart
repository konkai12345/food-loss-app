class FamilyMember {
  final String id;
  final String familyId;
  final String userId;
  final String userName;
  final String userEmail;
  final String role;

  FamilyMember({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
  });

  FamilyMember copyWith({
    String? id,
    String? familyId,
    String? userId,
    String? userName,
    String? userEmail,
    String? role,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'familyId': familyId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'role': role,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'],
        familyId: json['familyId'],
        userId: json['userId'],
        userName: json['userName'],
        userEmail: json['userEmail'],
        role: json['role'],
      );

  @override
  String toString() {
    return 'FamilyMember(id: $id, familyId: $familyId, userId: $userId, userName: $userName, userEmail: $userEmail, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyMember &&
        other.id == id &&
        other.familyId == familyId &&
        other.userId == userId &&
        other.userName == userName &&
        other.userEmail == userEmail &&
        other.role == role;
  }

  @override
  int get hashCode {
    return Object.hash(id, familyId, userId, userName, userEmail, role);
  }
}
