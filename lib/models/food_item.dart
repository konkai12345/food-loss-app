class FoodItem {
  final String id;
  final String name;
  final DateTime expiryDate;
  final DateTime registrationDate;
  final int quantity;
  final String storageLocation; // 冷蔵庫, 冷凍室, 常温
  final String category;
  final String? memo;
  final String? imagePath;
  final double? price;
  final String? purchaseStore;
  final DateTime? consumptionDate;
  final bool isConsumed;

  FoodItem({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.registrationDate,
    required this.quantity,
    required this.storageLocation,
    required this.category,
    this.memo,
    this.imagePath,
    this.price,
    this.purchaseStore,
    this.consumptionDate,
    this.isConsumed = false,
  });

  // 日数計算
  int get daysUntilExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  // 期限切れチェック
  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  // 期限状態判定
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days < 0) return ExpiryStatus.expired;
    if (days <= 1) return ExpiryStatus.urgent;
    if (days <= 3) return ExpiryStatus.soon;
    return ExpiryStatus.fresh;
  }

  // コピーして更新
  FoodItem copyWith({
    String? id,
    String? name,
    DateTime? expiryDate,
    DateTime? registrationDate,
    int? quantity,
    String? storageLocation,
    String? category,
    String? memo,
    String? imagePath,
    double? price,
    String? purchaseStore,
    DateTime? consumptionDate,
    bool? isConsumed,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      registrationDate: registrationDate ?? this.registrationDate,
      quantity: quantity ?? this.quantity,
      storageLocation: storageLocation ?? this.storageLocation,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      purchaseStore: purchaseStore ?? this.purchaseStore,
      consumptionDate: consumptionDate ?? this.consumptionDate,
      isConsumed: isConsumed ?? this.isConsumed,
    );
  }

  // JSON変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expiryDate': expiryDate.toIso8601String(),
      'registrationDate': registrationDate.toIso8601String(),
      'quantity': quantity,
      'storageLocation': storageLocation,
      'category': category,
      'memo': memo,
      'imagePath': imagePath,
      'price': price,
      'purchaseStore': purchaseStore,
      'consumptionDate': consumptionDate?.toIso8601String(),
      'isConsumed': isConsumed ? 1 : 0,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      expiryDate: DateTime.parse(json['expiryDate']),
      registrationDate: DateTime.parse(json['registrationDate']),
      quantity: json['quantity'],
      storageLocation: json['storageLocation'],
      category: json['category'],
      memo: json['memo'],
      imagePath: json['imagePath'],
      price: json['price']?.toDouble(),
      purchaseStore: json['purchaseStore'],
      consumptionDate: json['consumptionDate'] != null 
          ? DateTime.parse(json['consumptionDate']) 
          : null,
      isConsumed: json['isConsumed'] == 1,
    );
  }

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.id == id &&
        other.name == name &&
        other.expiryDate == expiryDate &&
        other.registrationDate == registrationDate &&
        other.quantity == quantity &&
        other.storageLocation == storageLocation &&
        other.category == category &&
        other.isConsumed == isConsumed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      expiryDate,
      registrationDate,
      quantity,
      storageLocation,
      category,
      isConsumed,
    );
  }
}

enum ExpiryStatus {
  fresh,    // 期限に余裕（緑）
  soon,     // 期限が近い（黄）
  urgent,   // 期限が非常に近い（橙）
  expired,  // 期限切れ（赤）
}
