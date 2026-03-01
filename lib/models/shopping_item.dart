import 'package:json_annotation/json_annotation.dart';

class ShoppingItem {
  final String id;
  final String listId;
  final String productName;
  final int quantity;
  final String? barcode;
  final bool isPurchased;
  final DateTime createdDate;
  final DateTime? plannedPurchaseDate;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.productName,
    this.quantity = 1,
    this.barcode,
    this.isPurchased = false,
    required this.createdDate,
    this.plannedPurchaseDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'listId': listId,
        'productName': productName,
        'quantity': quantity,
        'barcode': barcode,
        'isPurchased': isPurchased ? 1 : 0,
        'createdDate': createdDate.toIso8601String(),
        'plannedPurchaseDate': plannedPurchaseDate?.toIso8601String(),
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'],
        listId: json['listId'],
        productName: json['productName'],
        quantity: json['quantity'] ?? 1,
        barcode: json['barcode'],
        isPurchased: (json['isPurchased'] as int?) == 1,
        createdDate: DateTime.parse(json['createdDate']),
        plannedPurchaseDate: json['plannedPurchaseDate'] != null 
            ? DateTime.parse(json['plannedPurchaseDate']) 
            : null,
      );

  ShoppingItem copyWith({
    String? id,
    String? listId,
    String? productName,
    int? quantity,
    String? barcode,
    bool? isPurchased,
    DateTime? createdDate,
    DateTime? plannedPurchaseDate,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      isPurchased: isPurchased ?? this.isPurchased,
      createdDate: createdDate ?? this.createdDate,
      plannedPurchaseDate: plannedPurchaseDate ?? this.plannedPurchaseDate,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, listId: $listId, productName: $productName, quantity: $quantity, barcode: $barcode, isPurchased: $isPurchased, createdDate: $createdDate)';
  }

  // 購入予定日までの日数を計算
  int? get daysUntilPurchase {
    if (plannedPurchaseDate == null) return null;
    final now = DateTime.now();
    return plannedPurchaseDate!.difference(now).inDays;
  }

  // 購入予定日を過ぎているか判定
  bool isOverdue() {
    if (plannedPurchaseDate == null) return false;
    return DateTime.now().isAfter(plannedPurchaseDate!);
  }

  // 購入予定日が近いか判定（1日以内）
  bool isUrgent() {
    if (plannedPurchaseDate == null) return false;
    final days = daysUntilPurchase;
    return days != null && days <= 1 && days >= 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingItem &&
        other.id == id &&
        other.listId == listId &&
        other.productName == productName &&
        other.quantity == quantity &&
        other.barcode == barcode &&
        other.isPurchased == isPurchased &&
        other.createdDate == createdDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, listId, productName, quantity, barcode, isPurchased, createdDate);
  }
}
