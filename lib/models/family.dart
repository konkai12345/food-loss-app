class Family {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final List<String> memberIds;

  Family({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.memberIds,
  });

  Family copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<String>? memberIds,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdBy': createdBy,
        'memberIds': memberIds,
      };

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdBy: json['createdBy'],
        memberIds: List<String>.from(json['memberIds'] ?? []),
      );

  @override
  String toString() {
    return 'Family(id: $id, name: $name, description: $description, createdBy: $createdBy, memberIds: $memberIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Family &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.createdBy == createdBy &&
        other.memberIds == memberIds;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, createdBy, memberIds);
  }
}
