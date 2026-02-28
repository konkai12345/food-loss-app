import 'package:json_annotation/json_annotation.dart';

class Recipe {
  final String recipeId;
  final String title;
  final String? category;
  final String? area;
  final String instructions;
  final List<String> ingredients;
  final String? imageUrl;
  final DateTime cachedDate;

  Recipe({
    required this.recipeId,
    required this.title,
    this.category,
    this.area,
    required this.instructions,
    this.ingredients = const [],
    this.imageUrl,
    required this.cachedDate,
  });

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'title': title,
        'category': category,
        'area': area,
        'instructions': instructions,
        'ingredients': ingredients.join(','),
        'imageUrl': imageUrl,
        'cachedDate': cachedDate.toIso8601String(),
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        recipeId: json['recipeId'] ?? '',
        title: json['title'] ?? '',
        category: json['category'],
        area: json['area'],
        instructions: json['instructions'] ?? '',
        ingredients: json['ingredients'] != null && json['ingredients'].toString().isNotEmpty
            ? (json['ingredients'] as String).split(',')
            : [],
        imageUrl: json['imageUrl'],
        cachedDate: DateTime.parse(json['cachedDate']),
      );

  Recipe copyWith({
    String? recipeId,
    String? title,
    String? category,
    String? area,
    String? instructions,
    List<String>? ingredients,
    String? imageUrl,
    DateTime? cachedDate,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      ingredients: ingredients ?? this.ingredients,
      imageUrl: imageUrl ?? this.imageUrl,
      cachedDate: cachedDate ?? this.cachedDate,
    );
  }

  @override
  String toString() {
    return 'Recipe(recipeId: $recipeId, title: $title, category: $category, area: $area, ingredients: $ingredients, imageUrl: $imageUrl, cachedDate: $cachedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.recipeId == recipeId &&
        other.title == title &&
        other.category == category &&
        other.area == area &&
        other.instructions == instructions &&
        other.ingredients == ingredients &&
        other.imageUrl == imageUrl &&
        other.cachedDate == cachedDate;
  }

  @override
  int get hashCode {
    return Object.hash(recipeId, title, category, area, instructions, ingredients, imageUrl, cachedDate);
  }
}
