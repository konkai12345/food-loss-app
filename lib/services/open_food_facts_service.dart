import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product_info.dart';
import '../utils/error_handler.dart';
import 'mock_data_service.dart';

class OpenFoodFactsService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const Duration timeout = Duration(seconds: 10); // 30秒→10秒に短縮

  // リトライ戦略付きバーコード検索
  static Future<ProductInfo?> getProductByBarcode(String barcode, {int retryCount = 3}) async {
    if (kIsWeb) {
      return await MockDataService.getProductByBarcode(barcode);
    }

    for (int i = 0; i < retryCount; i++) {
      try {
        final uri = Uri.parse('$baseUrl/product/$barcode.json');
        final response = await http.get(uri).timeout(timeout);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final product = json['product'];

          if (product != null) {
            return ProductInfo(
              barcode: barcode,
              productName: product['product_name'] ?? 'Unknown Product',
              brand: product['brands'],
              categories: List<String>.from(product['categories_tags'] ?? []),
              imageUrl: product['image_front_url'],
              nutriments: product['nutriments'],
              cachedDate: DateTime.now(),
            );
          }
        }
        
        return null;
      } catch (e) {
        if (i == retryCount - 1) {
          AppErrorHandler.handleError(e, StackTrace.current, context: 'OpenFoodFactsService.getProductByBarcode');
          return null;
        }
        // 指数バックオフでリトライ
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
    
    return null;
  }

  // 商品名で検索（リトライ戦略付き）
  static Future<List<ProductInfo>> searchProductsByName(String name, {int retryCount = 2}) async {
    if (kIsWeb) {
      return await MockDataService.searchProductsByName(name);
    }

    for (int i = 0; i < retryCount; i++) {
      try {
        final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {
          'search_terms': name,
          'page_size': '20',
          'fields': 'product_name,brands,categories_tags,image_front_url,nutriments',
          'json': '1',
        });

        final response = await http.get(uri).timeout(timeout);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final products = json['products'] as List<dynamic>;

          return products.map((product) {
            return ProductInfo(
              barcode: product['code'] ?? '',
              productName: product['product_name'] ?? 'Unknown Product',
              brand: product['brands'],
              categories: List<String>.from(product['categories_tags'] ?? []),
              imageUrl: product['image_front_url'],
              nutriments: product['nutriments'],
              cachedDate: DateTime.now(),
            );
          }).toList();
        }
        
        return [];
      } catch (e) {
        if (i == retryCount - 1) {
          AppErrorHandler.handleError(e, StackTrace.current, context: 'OpenFoodFactsService.searchProductsByName');
          return [];
        }
        await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
      }
    }
    
    return [];
  }
}
