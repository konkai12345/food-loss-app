import 'dart:convert';

import 'package:flutter/material.dart';

// ゴミカテゴリ
enum WasteCategory {
  burnable,      // 可燃ゴミ
  unburnable,    // 不燃ゴミ
  recyclable,    // 資源ゴミ
  hazardous,     // 有害ゴミ
  oversized,     // 粗大ゴミ
  food,          // 食品ゴミ
  other,         // その他
}

// ゴミ分別ルール
class WasteSeparationRule {
  final String id;
  final String itemName;
  final List<WasteCategory> categories;
  final String? region;
  final String? description;
  final List<String> keywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  WasteSeparationRule({
    required this.id,
    required this.itemName,
    required this.categories,
    this.region,
    this.description,
    required this.keywords,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WasteSeparationRule.fromJson(Map<String, dynamic> json) {
    return WasteSeparationRule(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      categories: (json['categories'] as List)
          .map((e) => WasteCategory.values.firstWhere(
                (cat) => cat.name == e,
                orElse: () => WasteCategory.other,
              ))
          .toList(),
      region: json['region'] as String?,
      description: json['description'] as String?,
      keywords: List<String>.from(json['keywords'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'categories': categories.map((e) => e.name).toList(),
      'region': region,
      'description': description,
      'keywords': keywords,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WasteSeparationRule copyWith({
    String? id,
    String? itemName,
    List<WasteCategory>? categories,
    String? region,
    String? description,
    List<String>? keywords,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WasteSeparationRule(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      categories: categories ?? this.categories,
      region: region ?? this.region,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WasteSeparationRule &&
        other.id == id &&
        other.itemName == itemName &&
        other.region == region;
  }

  @override
  int get hashCode => id.hashCode ^ itemName.hashCode ^ region.hashCode;
}

// 地域設定
class RegionSettings {
  final String id;
  final String name;
  final String prefecture;
  final String city;
  final Map<WasteCategory, String> categoryNames;
  final Map<WasteCategory, String> collectionDays;
  final Map<WasteCategory, List<String>> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RegionSettings({
    required this.id,
    required this.name,
    required this.prefecture,
    required this.city,
    required this.categoryNames,
    required this.collectionDays,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegionSettings.fromJson(Map<String, dynamic> json) {
    return RegionSettings(
      id: json['id'] as String,
      name: json['name'] as String,
      prefecture: json['prefecture'] as String,
      city: json['city'] as String,
      categoryNames: Map<WasteCategory, String>.from(
        (json['categoryNames'] as Map).map(
          (key, value) => MapEntry(
            WasteCategory.values.firstWhere(
              (cat) => cat.name == key,
              orElse: () => WasteCategory.other,
            ),
            value as String,
          ),
        ),
      ),
      collectionDays: Map<WasteCategory, String>.from(
        (json['collectionDays'] as Map).map(
          (key, value) => MapEntry(
            WasteCategory.values.firstWhere(
              (cat) => cat.name == key,
              orElse: () => WasteCategory.other,
            ),
            value as String,
          ),
        ),
      ),
      notes: Map<WasteCategory, List<String>>.from(
        (json['notes'] as Map).map(
          (key, value) => MapEntry(
            WasteCategory.values.firstWhere(
              (cat) => cat.name == key,
              orElse: () => WasteCategory.other,
            ),
            List<String>.from(value as List),
          ),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'prefecture': prefecture,
      'city': city,
      'categoryNames': categoryNames.map((key, value) => MapEntry(key.name, value)),
      'collectionDays': collectionDays.map((key, value) => MapEntry(key.name, value)),
      'notes': notes.map((key, value) => MapEntry(key.name, value)),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RegionSettings copyWith({
    String? id,
    String? name,
    String? prefecture,
    String? city,
    Map<WasteCategory, String>? categoryNames,
    Map<WasteCategory, String>? collectionDays,
    Map<WasteCategory, List<String>>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegionSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      prefecture: prefecture ?? this.prefecture,
      city: city ?? this.city,
      categoryNames: categoryNames ?? this.categoryNames,
      collectionDays: collectionDays ?? this.collectionDays,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegionSettings &&
        other.id == id &&
        other.name == name &&
        other.prefecture == prefecture &&
        other.city == city;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ prefecture.hashCode ^ city.hashCode;
}

// ゴミ分別結果
class WasteSeparationResult {
  final String itemName;
  final WasteCategory category;
  final String? region;
  final String? description;
  final List<String> collectionDays;
  final List<String> notes;
  final double confidence;
  final DateTime createdAt;

  WasteSeparationResult({
    required this.itemName,
    required this.category,
    this.region,
    this.description,
    required this.collectionDays,
    required this.notes,
    required this.confidence,
    required this.createdAt,
  });

  factory WasteSeparationResult.fromJson(Map<String, dynamic> json) {
    return WasteSeparationResult(
      itemName: json['itemName'] as String,
      category: WasteCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => WasteCategory.other,
      ),
      region: json['region'] as String?,
      description: json['description'] as String?,
      collectionDays: List<String>.from(json['collectionDays'] as List),
      notes: List<String>.from(json['notes'] as List),
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'category': category.name,
      'region': region,
      'description': description,
      'collectionDays': collectionDays,
      'notes': notes,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WasteSeparationResult copyWith({
    String? itemName,
    WasteCategory? category,
    String? region,
    String? description,
    List<String>? collectionDays,
    List<String>? notes,
    double? confidence,
    DateTime? createdAt,
  }) {
    return WasteSeparationResult(
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      region: region ?? this.region,
      description: description ?? this.description,
      collectionDays: collectionDays ?? this.collectionDays,
      notes: notes ?? this.notes,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WasteSeparationResult &&
        other.itemName == itemName &&
        other.category == category &&
        other.region == region;
  }

  @override
  int get hashCode => itemName.hashCode ^ category.hashCode ^ region.hashCode;
}

// ゴミ分別履歴
class WasteSeparationHistory {
  final String id;
  final String itemName;
  final WasteCategory category;
  final String? region;
  final DateTime createdAt;
  final bool isCorrect;
  final String? feedback;

  WasteSeparationHistory({
    required this.id,
    required this.itemName,
    required this.category,
    this.region,
    required this.createdAt,
    required this.isCorrect,
    this.feedback,
  });

  factory WasteSeparationHistory.fromJson(Map<String, dynamic> json) {
    return WasteSeparationHistory(
      id: json['id'] as String,
      itemName: json['itemName'] as String,
      category: WasteCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => WasteCategory.other,
      ),
      region: json['region'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCorrect: json['isCorrect'] as bool,
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category.name,
      'region': region,
      'createdAt': createdAt.toIso8601String(),
      'isCorrect': isCorrect,
      'feedback': feedback,
    };
  }

  WasteSeparationHistory copyWith({
    String? id,
    String? itemName,
    WasteCategory? category,
    String? region,
    DateTime? createdAt,
    bool? isCorrect,
    String? feedback,
  }) {
    return WasteSeparationHistory(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      region: region ?? this.region,
      createdAt: createdAt ?? this.createdAt,
      isCorrect: isCorrect ?? this.isCorrect,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WasteSeparationHistory &&
        other.id == id &&
        other.itemName == itemName &&
        other.category == category;
  }

  @override
  int get hashCode => id.hashCode ^ itemName.hashCode ^ category.hashCode;
}

// 拡張メソッド
extension WasteCategoryExtension on WasteCategory {
  String get displayName {
    switch (this) {
      case WasteCategory.burnable:
        return '可燃ゴミ';
      case WasteCategory.unburnable:
        return '不燃ゴミ';
      case WasteCategory.recyclable:
        return '資源ゴミ';
      case WasteCategory.hazardous:
        return '有害ゴミ';
      case WasteCategory.oversized:
        return '粗大ゴミ';
      case WasteCategory.food:
        return '食品ゴミ';
      case WasteCategory.other:
        return 'その他';
    }
  }

  String get description {
    switch (this) {
      case WasteCategory.burnable:
        return '燃えるゴミ（生ゴミ、紙類など）';
      case WasteCategory.unburnable:
        return '燃えないゴミ（プラスチック、金属など）';
      case WasteCategory.recyclable:
        return 'リサイクル可能なゴミ（缶、瓶、紙など）';
      case WasteCategory.hazardous:
        return '有害なゴミ（電池、蛍光灯など）';
      case WasteCategory.oversized:
        return '大型のゴミ（家具、家電など）';
      case WasteCategory.food:
        return '食品関連のゴミ';
      case WasteCategory.other:
        return 'その他のゴミ';
    }
  }

  Color get color {
    switch (this) {
      case WasteCategory.burnable:
        return Colors.red;
      case WasteCategory.unburnable:
        return Colors.grey;
      case WasteCategory.recyclable:
        return Colors.blue;
      case WasteCategory.hazardous:
        return Colors.orange;
      case WasteCategory.oversized:
        return Colors.purple;
      case WasteCategory.food:
        return Colors.green;
      case WasteCategory.other:
        return Colors.brown;
    }
  }

  IconData get icon {
    switch (this) {
      case WasteCategory.burnable:
        return Icons.local_fire_department;
      case WasteCategory.unburnable:
        return Icons.delete_outline;
      case WasteCategory.recyclable:
        return Icons.recycling;
      case WasteCategory.hazardous:
        return Icons.warning;
      case WasteCategory.oversized:
        return Icons.chair;
      case WasteCategory.food:
        return Icons.restaurant;
      case WasteCategory.other:
        return Icons.more_horiz;
    }
  }
}
