class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final List<String> familyIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.familyIds,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    List<String>? familyIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyIds: familyIds ?? this.familyIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'familyIds': familyIds,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatarUrl: json['avatarUrl'],
        familyIds: List<String>.from(json['familyIds'] ?? []),
      );

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl, familyIds: $familyIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatarUrl == avatarUrl &&
        other.familyIds == familyIds;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, avatarUrl, familyIds);
  }
}
