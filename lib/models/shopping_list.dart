import 'package:json_annotation/json_annotation.dart';

class ShoppingList {
  final String id;
  final String name;
  final DateTime createdDate;
  final bool isCompleted;
  final DateTime? plannedPurchaseDate;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdDate,
    this.isCompleted = false,
    this.plannedPurchaseDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdDate': createdDate.toIso8601String(),
        'isCompleted': isCompleted,
        'plannedPurchaseDate': plannedPurchaseDate?.toIso8601String(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: json['id'],
        name: json['name'],
        createdDate: DateTime.parse(json['createdDate']),
        isCompleted: (json['isCompleted'] as int?) == 1,
        plannedPurchaseDate: json['plannedPurchaseDate'] != null 
            ? DateTime.parse(json['plannedPurchaseDate']) 
            : null,
      );

  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? createdDate,
    bool? isCompleted,
    DateTime? plannedPurchaseDate,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdDate: createdDate ?? this.createdDate,
      isCompleted: isCompleted ?? this.isCompleted,
      plannedPurchaseDate: plannedPurchaseDate ?? this.plannedPurchaseDate,
    );
  }

  @override
  String toString() {
    return 'ShoppingList(id: $id, name: $name, createdDate: $createdDate, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingList &&
        other.id == id &&
        other.name == name &&
        other.createdDate == createdDate &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, createdDate, isCompleted);
  }
}
