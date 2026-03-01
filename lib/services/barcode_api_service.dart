import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_info.dart';
import '../utils/error_handler.dart';

class BarcodeApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const Duration _timeout = Duration(seconds: 10);

  // Open Food Facts APIから商品情報を取得
  static Future<ProductInfo?> fetchProductInfo(String barcode) async {
    try {
      print('API呼び出し: バーコード $barcode の商品情報を取得中...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$barcode.json'),
        headers: {
          'User-Agent': 'FoodLossApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      print('API応答ステータス: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          print('商品情報取得成功: ${product['product_name']}');
          
          return _parseProductInfo(barcode, product);
        } else {
          print('商品が見つかりません: バーコード $barcode');
          return null;
        }
      } else {
        print('APIエラー: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('API呼び出しエラー: $e');
      AppErrorHandler.handleError(e, StackTrace.current, context: 'BarcodeApiService.fetchProductInfo');
      return null;
    }
  }

  // APIレスポンスをProductInfoに変換
  static ProductInfo _parseProductInfo(String barcode, Map<String, dynamic> product) {
    final productName = product['product_name'] ?? '不明な商品';
    final brands = product['brands'] ?? '';
    final categories = _parseCategories(product['categories'] ?? '');
    final nutriments = _parseNutriments(product['nutriments'] ?? {});
    
    // 賞味期限の推定（カテゴリに基づいて）
    final expiryDays = _estimateExpiryDays(categories);
    
    // 数量の推定
    final quantity = _estimateQuantity(product);

    return ProductInfo(
      barcode: barcode,
      productName: productName,
      brand: brands.isNotEmpty ? brands : '不明',
      categories: categories,
      nutriments: {
        'calories': nutriments['energy-kcal_100g']?.toDouble() ?? 0.0,
        'protein': nutriments['proteins_100g']?.toDouble() ?? 0.0,
        'carbs': nutriments['carbohydrates_100g']?.toDouble() ?? 0.0,
        'fat': nutriments['fat_100g']?.toDouble() ?? 0.0,
        'quantity': quantity,
        'expiryDays': expiryDays,
        'price': _estimatePrice(product).round(), // 価格を整数に丸める
        'storageLocation': _estimateStorageLocation(categories), // 保管場所を推定
      },
      cachedDate: DateTime.now(),
    );
  }

  // カテゴリ文字列を配列に変換
  static List<String> _parseCategories(String categoriesStr) {
    if (categoriesStr.isEmpty) return ['その他'];
    
    final categories = categoriesStr.split(',').map((cat) => cat.trim()).toList();
    
    // 日本語のカテゴリに変換（より詳細な分類）
    final japaneseCategories = categories.map((cat) {
      final lowerCat = cat.toLowerCase();
      
      // 野菜類
      if (lowerCat.contains('vegetable') || lowerCat.contains('野菜') || 
          lowerCat.contains('キャベツ') || lowerCat.contains('レタス') ||
          lowerCat.contains('トマト') || lowerCat.contains('きゅうり') ||
          lowerCat.contains('にんじん') || lowerCat.contains('たまねぎ')) {
        return '野菜';
      }
      
      // 果物類
      if (lowerCat.contains('fruit') || lowerCat.contains('果物') ||
          lowerCat.contains('りんご') || lowerCat.contains('みかん') ||
          lowerCat.contains('バナナ') || lowerCat.contains('いちご')) {
        return '果物';
      }
      
      // 肉類
      if (lowerCat.contains('meat') || lowerCat.contains('肉') ||
          lowerCat.contains('豚肉') || lowerCat.contains('牛肉') ||
          lowerCat.contains('鶏肉') || lowerCat.contains('ハム')) {
        return '肉';
      }
      
      // 魚介類
      if (lowerCat.contains('fish') || lowerCat.contains('seafood') || lowerCat.contains('魚') ||
          lowerCat.contains('さかな') || lowerCat.contains('サーモン') ||
          lowerCat.contains('まぐろ') || lowerCat.contains('えび')) {
        return '魚';
      }
      
      // 乳製品
      if (lowerCat.contains('dairy') || lowerCat.contains('乳製品') ||
          lowerCat.contains('ミルク') || lowerCat.contains('チーズ') ||
          lowerCat.contains('ヨーグルト') || lowerCat.contains('バター')) {
        return '乳製品';
      }
      
      // 飲料
      if (lowerCat.contains('beverage') || lowerCat.contains('drink') || lowerCat.contains('飲料') ||
          lowerCat.contains('ジュース') || lowerCat.contains('コーヒー') ||
          lowerCat.contains('お茶') || lowerCat.contains('水')) {
        return '飲料';
      }
      
      // お菓子類
      if (lowerCat.contains('snack') || lowerCat.contains('chips') || lowerCat.contains('菓子') ||
          lowerCat.contains('ポテト') || lowerCat.contains('チップス') ||
          lowerCat.contains('クッキー') || lowerCat.contains('チョコレート') ||
          lowerCat.contains('キャンディ') || lowerCat.contains('ガム') ||
          lowerCat.contains('スナック') || lowerCat.contains('お菓子')) {
        return 'お菓子';
      }
      
      // 加工食品
      if (lowerCat.contains('processed') || lowerCat.contains('加工食品') ||
          lowerCat.contains('レトルト') || lowerCat.contains('冷凍食品') ||
          lowerCat.contains('惣菜') || lowerCat.contains('カレー') ||
          lowerCat.contains('丼') || lowerCat.contains('パスタ') ||
          lowerCat.contains('ピザ') || lowerCat.contains('ハンバーグ')) {
        return '加工食品';
      }
      
      // パン・穀物類
      if (lowerCat.contains('bread') || lowerCat.contains('パン') ||
          lowerCat.contains('米') || lowerCat.contains('ご飯') ||
          lowerCat.contains('麺') || lowerCat.contains('うどん') ||
          lowerCat.contains('そば') || lowerCat.contains('パスタ') ||
          lowerCat.contains('シリアル') || lowerCat.contains('穀物')) {
        return 'パン・穀物';
      }
      
      // 調味料
      if (lowerCat.contains('seasoning') || lowerCat.contains('sauce') || lowerCat.contains('調味料') ||
          lowerCat.contains('しょうゆ') || lowerCat.contains('みそ') ||
          lowerCat.contains('ソース') || lowerCat.contains('ケチャップ') ||
          lowerCat.contains('マヨネーズ') || lowerCat.contains('ワサビ')) {
        return '調味料';
      }
      
      return 'その他';
    }).toList();
    
    return japaneseCategories;
  }

  // 栄養情報を解析
  static Map<String, double> _parseNutriments(Map<String, dynamic> nutriments) {
    return {
      'energy-kcal_100g': (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
      'proteins_100g': (nutriments['proteins_100g'] ?? 0).toDouble(),
      'carbohydrates_100g': (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
      'fat_100g': (nutriments['fat_100g'] ?? 0).toDouble(),
    };
  }

  // カテゴリに基づいて賞味期限を推定
  static int _estimateExpiryDays(List<String> categories) {
    for (final category in categories) {
      switch (category) {
        case '野菜':
          return 7; // 1週間
        case '果物':
          return 14; // 2週間
        case '肉':
          return 5; // 5日
        case '魚':
          return 3; // 3日
        case '乳製品':
          return 14; // 2週間
        case '飲料':
          return 180; // 6ヶ月
        case 'お菓子':
          return 90; // 3ヶ月
        case '加工食品':
          return 30; // 1ヶ月
        case 'パン・穀物':
          return 7; // 1週間
        case '調味料':
          return 365; // 1年
        case 'その他':
          return 90; // 3ヶ月
      }
    }
    return 30; // デフォルト1ヶ月
  }

  // 数量を推定
  static int _estimateQuantity(Map<String, dynamic> product) {
    final quantity = product['quantity'] ?? '';
    final servingSize = product['serving_size'] ?? '';
    
    // 数量情報から推定
    if (quantity.contains('個') || quantity.contains('pack')) {
      final match = RegExp(r'(\d+)').firstMatch(quantity);
      return int.tryParse(match?.group(1) ?? '1') ?? 1;
    }
    
    // サービングサイズから推定
    if (servingSize.contains('個') || servingSize.contains('pack')) {
      final match = RegExp(r'(\d+)').firstMatch(servingSize);
      return int.tryParse(match?.group(1) ?? '1') ?? 1;
    }
    
    return 1; // デフォルト1個
  }

  // 価格を推定（商品情報から）
  static double _estimatePrice(Map<String, dynamic> product) {
    // 簡単な価格推定ロジック
    final categories = _parseCategories(product['categories'] ?? '');
    
    for (final category in categories) {
      switch (category) {
        case '野菜':
          return 80.0;
        case '果物':
          return 120.0;
        case '肉':
          return 300.0;
        case '魚':
          return 250.0;
        case '乳製品':
          return 180.0;
        case '飲料':
          return 150.0;
        case 'お菓子':
          return 150.0; // スナック菓子
        case '加工食品':
          return 250.0; // レトルト食品など
        case 'パン・穀物':
          return 200.0; // パンや米など
        case '調味料':
          return 120.0; // ソースや調味料
        case 'その他':
          return 150.0;
      }
    }
    
    return 100.0; // デフォルト価格
  }

  // 保管場所を推定
  static String _estimateStorageLocation(List<String> categories) {
    for (final category in categories) {
      switch (category) {
        case '野菜':
        case '果物':
        case '肉':
        case '魚':
        case '乳製品':
          return '冷蔵庫'; // 生鮮食品は冷蔵庫
          
        case '飲料':
        case 'お菓子':
        case '調味料':
          return '常温'; // 飲料やスナック、調味料は常温
          
        case '加工食品':
          return '冷蔵庫'; // 加工食品は冷蔵庫
          
        case 'パン・穀物':
          return '常温'; // パンや穀物は常温
          
        case 'その他':
          return '常温'; // デフォルトは常温
      }
    }
    
    return '常温'; // デフォルトは常温
  }
}
