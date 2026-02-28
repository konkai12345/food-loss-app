import 'package:json_annotation/json_annotation.dart';

class ShoppingItem {
  final String id;
  final String listId;
  final String productName;
  final int quantity;
  final String? barcode;
  final bool isPurchased;
  final DateTime createdDate;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.productName,
    this.quantity = 1,
    this.barcode,
    this.isPurchased = false,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'listId': listId,
        'productName': productName,
        'quantity': quantity,
        'barcode': barcode,
        'isPurchased': isPurchased,
        'createdDate': createdDate.toIso8601String(),
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'],
        listId: json['listId'],
        productName: json['productName'],
        quantity: json['quantity'] ?? 1,
        barcode: json['barcode'],
        isPurchased: (json['isPurchased'] as int?) == 1,
        createdDate: DateTime.parse(json['createdDate']),
      );

  ShoppingItem copyWith({
    String? id,
    String? listId,
    String? productName,
    int? quantity,
    String? barcode,
    bool? isPurchased,
    DateTime? createdDate,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
      isPurchased: isPurchased ?? this.isPurchased,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem(id: $id, listId: $listId, productName: $productName, quantity: $quantity, barcode: $barcode, isPurchased: $isPurchased, createdDate: $createdDate)';
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
