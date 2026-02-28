import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/recipe.dart';
import '../utils/error_handler.dart';

class QRCodeService {
  // 食材情報のQRコード生成
  static Future<String> generateFoodItemQRCode(FoodItem foodItem) async {
    try {
      final qrData = {
        'type': 'food_item',
        'id': foodItem.id,
        'name': foodItem.name,
        'expiryDate': foodItem.expiryDate.toIso8601String(),
        'quantity': foodItem.quantity,
        'storageLocation': foodItem.storageLocation,
        'category': foodItem.category,
        'memo': foodItem.memo,
        'price': foodItem.price,
        'purchaseStore': foodItem.purchaseStore,
        'registrationDate': foodItem.registrationDate.toIso8601String(),
        'isConsumed': foodItem.isConsumed,
      };

      return jsonEncode(qrData);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.generateFoodItemQRCode');
      rethrow;
    }
  }

  // 買い物リストのQRコード生成
  static Future<String> generateShoppingListQRCode(ShoppingList shoppingList, List<ShoppingItem> items) async {
    try {
      final qrData = {
        'type': 'shopping_list',
        'list': {
          'id': shoppingList.id,
          'name': shoppingList.name,
          'createdDate': shoppingList.createdDate.toIso8601String(),
          'isCompleted': shoppingList.isCompleted,
        },
        'items': items.map((item) => {
          'id': item.id,
          'listId': item.listId,
          'productName': item.productName,
          'quantity': item.quantity,
          'barcode': item.barcode,
          'isPurchased': item.isPurchased,
          'createdDate': item.createdDate.toIso8601String(),
        }).toList(),
      };

      return jsonEncode(qrData);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.generateShoppingListQRCode');
      rethrow;
    }
  }

  // レシピのQRコード生成
  static Future<String> generateRecipeQRCode(Recipe recipe) async {
    try {
      final qrData = {
        'type': 'recipe',
        'recipeId': recipe.recipeId,
        'title': recipe.title,
        'category': recipe.category,
        'area': recipe.area,
        'instructions': recipe.instructions,
        'ingredients': recipe.ingredients,
        'imageUrl': recipe.imageUrl,
        'cachedDate': recipe.cachedDate.toIso8601String(),
      };

      return jsonEncode(qrData);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.generateRecipeQRCode');
      rethrow;
    }
  }

  // 在庫管理用のQRコード生成
  static Future<String> generateInventoryQRCode(List<FoodItem> items) async {
    try {
      final qrData = {
        'type': 'inventory',
        'date': DateTime.now().toIso8601String(),
        'totalItems': items.length,
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'expiryDate': item.expiryDate.toIso8601String(),
          'quantity': item.quantity,
          'storageLocation': item.storageLocation,
          'category': item.category,
          'daysUntilExpiry': item.daysUntilExpiry,
          'isConsumed': item.isConsumed,
        }).toList(),
      };

      return jsonEncode(qrData);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.generateInventoryQRCode');
      rethrow;
    }
  }

  // 購入管理用のQRコード生成
  static Future<String> generatePurchaseQRCode(List<FoodItem> items) async {
    try {
      final qrData = {
        'type': 'purchase',
        'date': DateTime.now().toIso8601String(),
        'totalItems': items.length,
        'totalValue': items.fold<double>(0.0, (sum, item) => sum + (item.price ?? 0.0)),
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'purchaseStore': item.purchaseStore,
          'purchaseDate': item.registrationDate.toIso8601String(),
          'expiryDate': item.expiryDate.toIso8601String(),
          'storageLocation': item.storageLocation,
          'category': item.category,
        }).toList(),
      };

      return jsonEncode(qrData);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.generatePurchaseQRCode');
      rethrow;
    }
  }

  // QRコード画像の生成
  static Future<Uint8List> generateQRImage(String qrData, {double size = 200.0}) async {
    try {
      final qrPainter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      final qrImageData = await qrPainter.toImageData(size);
      if (qrImageData != null) {
        return qrImageData.buffer.asUint8List();
      } else {
        throw Exception('QRコード画像の生成に失敗しました');
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.generateQRImage');
      rethrow;
    }
  }

  // QRコード画像の保存
  static Future<String> saveQRImage(String qrData, {String fileName = 'qrcode.png'}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$fileName';
      
      final qrImage = await generateQRImage(qrData);
      final file = File(imagePath);
      await file.writeAsBytes(qrImage);
      
      return imagePath;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.saveQRImage');
      rethrow;
    }
  }

  // QRコードの共有
  static Future<void> shareQRCode(String qrData, {String title = 'QRコード'}) async {
    try {
      final imagePath = await saveQRImage(qrData);
      
      await Share.shareXFiles(
        [XFile(imagePath, name: title)],
        subject: title,
        text: 'QRコードを共有します',
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.shareQRCode');
      rethrow;
    }
  }

  // QRコードデータの解析
  static Map<String, dynamic> parseQRCodeData(String qrData) {
    try {
      final data = jsonDecode(qrData);
      return data as Map<String, dynamic>;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.parseQRCodeData');
      return {};
    }
  }

  // QRコードの種類を判定
  static String getQRCodeType(String qrData) {
    try {
      final data = parseQRCodeData(qrData);
      return data['type'] as String? ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  // 食材情報のQRコードからFoodItemを復元
  static FoodItem? parseFoodItemFromQRCode(String qrData) {
    try {
      final data = parseQRCodeData(qrData);
      if (data['type'] != 'food_item') return null;

      return FoodItem(
        id: data['id'],
        name: data['name'],
        expiryDate: DateTime.parse(data['expiryDate']),
        quantity: data['quantity'],
        storageLocation: data['storageLocation'],
        category: data['category'],
        memo: data['memo'],
        price: data['price']?.toDouble(),
        purchaseStore: data['purchaseStore'],
        registrationDate: DateTime.parse(data['registrationDate']),
        isConsumed: data['isConsumed'],
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.parseFoodItemFromQRCode');
      return null;
    }
  }

  // 買い物リストのQRコードからデータを復元
  static Map<String, dynamic>? parseShoppingListFromQRCode(String qrData) {
    try {
      final data = parseQRCodeData(qrData);
      if (data['type'] != 'shopping_list') return null;

      return data;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.parseShoppingListFromQRCode');
      return null;
    }
  }

  // レシピのQRコードからRecipeを復元
  static Recipe? parseRecipeFromQRCode(String qrData) {
    try {
      final data = parseQRCodeData(qrData);
      if (data['type'] != 'recipe') return null;

      return Recipe(
        recipeId: data['recipeId'],
        title: data['title'],
        category: data['category'],
        area: data['area'],
        instructions: data['instructions'],
        ingredients: List<String>.from(data['ingredients']),
        imageUrl: data['imageUrl'],
        cachedDate: DateTime.parse(data['cachedDate']),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'QRCodeService.parseRecipeFromQRCode');
      return null;
    }
  }

  // QRコードのバリデーション
  static bool validateQRCodeData(String qrData) {
    try {
      final data = parseQRCodeData(qrData);
      return data.isNotEmpty && data.containsKey('type');
    } catch (e) {
      return false;
    }
  }

  // QRコードの形式を取得
  static String getQRCodeFormat(String qrData) {
    try {
      final data = parseQRCodeData(qrData);
      final type = data['type'] as String;
      
      switch (type) {
        case 'food_item':
          return '食材情報';
        case 'shopping_list':
          return '買い物リスト';
        case 'recipe':
          return 'レシピ';
        case 'inventory':
          return '在庫管理';
        case 'purchase':
          return '購入管理';
        default:
          return '不明';
      }
    } catch (e) {
      return '不明';
    }
  }
}
