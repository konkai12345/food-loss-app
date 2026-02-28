import 'package:json_annotation/json_annotation.dart';

class ProductInfo {
  final String barcode;
  final String productName;
  final String? brand;
  final List<String> categories;
  final String? imageUrl;
  final Map<String, dynamic>? nutriments;
  final DateTime cachedDate;

  ProductInfo({
    required this.barcode,
    required this.productName,
    this.brand,
    this.categories = const [],
    this.imageUrl,
    this.nutriments,
    required this.cachedDate,
  });

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'productName': productName,
        'brand': brand,
        'categories': categories,
        'imageUrl': imageUrl,
        'nutriments': nutriments,
        'cachedDate': cachedDate.toIso8601String(),
      };

  factory ProductInfo.fromJson(Map<String, dynamic> json) => ProductInfo(
        barcode: json['barcode'],
        productName: json['productName'],
        brand: json['brand'],
        categories: List<String>.from(json['categories'] ?? []),
        imageUrl: json['imageUrl'],
        nutriments: json['nutriments'],
        cachedDate: DateTime.parse(json['cachedDate']),
      );

  ProductInfo copyWith({
    String? barcode,
    String? productName,
    String? brand,
    List<String>? categories,
    String? imageUrl,
    Map<String, dynamic>? nutriments,
    DateTime? cachedDate,
  }) {
    return ProductInfo(
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      nutriments: nutriments ?? this.nutriments,
      cachedDate: cachedDate ?? this.cachedDate,
    );
  }

  @override
  String toString() {
    return 'ProductInfo(barcode: $barcode, productName: $productName, brand: $brand, categories: $categories, imageUrl: $imageUrl, cachedDate: $cachedDate)';
  }
}
