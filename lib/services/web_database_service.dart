import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/product_info.dart';
import '../models/recipe.dart';
import 'mock_data_service.dart';
import '../utils/error_handler.dart';

class WebDatabaseService {
  // Web環境かどうかをチェック
  static bool get isWeb => kIsWeb;

  // 食材関連メソッド
  static Future<void> addFoodItem(FoodItem item) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      await MockDataService.addFoodItem(item);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.addFoodItem');
      rethrow;
    }
  }

  static Future<List<FoodItem>> getAllFoodItems() async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      return await MockDataService.getAllFoodItems();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getAllFoodItems');
      return [];
    }
  }

  static Future<void> updateFoodItem(FoodItem item) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      await MockDataService.updateFoodItem(item);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.updateFoodItem');
      rethrow;
    }
  }

  static Future<void> deleteFoodItem(String id) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      // Web版では何もしない
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.deleteFoodItem');
    }
  }

  static Future<void> markAsConsumed(String id) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      // Web版では何もしない
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.markAsConsumed');
    }
  }

  static Future<List<FoodItem>> getFoodItemsByCategory(String category) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      final allItems = await MockDataService.getAllFoodItems();
      return allItems.where((item) => item.category == category).toList();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getFoodItemsByCategory');
      return [];
    }
  }

  static Future<List<FoodItem>> getFoodItemsByStorageLocation(String location) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      final allItems = await MockDataService.getAllFoodItems();
      return allItems.where((item) => item.storageLocation == location).toList();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getFoodItemsByStorageLocation');
      return [];
    }
  }

  // 買い物リスト関連メソッド
  static Future<String> createShoppingList(String name) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      // Web版では何もしない
      return 'mock_list_id';
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.createShoppingList');
      rethrow;
    }
  }

  static Future<List<ShoppingList>> getAllShoppingLists() async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      return MockDataService.getMockShoppingLists();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getAllShoppingLists');
      return [];
    }
  }

  static Future<void> deleteShoppingList(String id) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      await MockDataService.deleteShoppingList(id);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.deleteShoppingList');
      rethrow;
    }
  }

  static Future<List<ShoppingItem>> getShoppingItems(String listId) async {
    try {
      return await MockDataService.getShoppingItems(listId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getShoppingItems');
      return [];
    }
  }

  static Future<String> addShoppingItem(
    String listId,
    String productName, {
    int quantity = 1,
    String? barcode,
  }) async {
    try {
      final item = ShoppingItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        listId: listId,
        productName: productName,
        quantity: quantity,
        barcode: barcode ?? '',
        isPurchased: false,
        createdDate: DateTime.now(),
      );
      await MockDataService.addShoppingItem(item);
      return item.id;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.addShoppingItem');
      rethrow;
    }
  }

  static Future<void> updateShoppingItem(ShoppingItem item) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      // Web版では何もしない
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.updateShoppingItem');
    }
  }

  static Future<void> deleteShoppingItem(String id) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      // Web版では何もしない
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.deleteShoppingItem');
    }
  }

  // 商品情報キャッシュ関連メソッド
  static Future<void> cacheProductInfo(ProductInfo productInfo) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    // Web版ではMockDataServiceがキャッシュを管理
  }

  static Future<ProductInfo?> getCachedProductInfo(String barcode) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      return await MockDataService.getProductByBarcode(barcode);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getCachedProductInfo');
      return null;
    }
  }

  // レシピキャッシュ関連メソッド
  static Future<void> cacheRecipe(Recipe recipe) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    // Web版ではMockDataServiceがキャッシュを管理
  }

  static Future<Recipe?> getCachedRecipe(String recipeId) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      return await MockDataService.getRecipeDetails(recipeId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getCachedRecipe');
      return null;
    }
  }

  static Future<List<Recipe>> searchCachedRecipes(String query) async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      // 簡易的な検索実装
      final allRecipes = [
        await MockDataService.getRandomRecipe(),
        await MockDataService.getRandomRecipe(),
        await MockDataService.getRandomRecipe(),
      ];
      
      return allRecipes.where((recipe) =>
          recipe?.title.toLowerCase().contains(query.toLowerCase()) == true ||
          recipe?.ingredients.any((ingredient) =>
              ingredient.toLowerCase().contains(query.toLowerCase())) == true
      ).where((recipe) => recipe != null).cast<Recipe>().toList();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.searchCachedRecipes');
      return [];
    }
  }

  // 統計情報
  static Future<Map<String, int>> getStatistics() async {
    if (!isWeb) {
      throw Exception('WebDatabaseService is for web environment only');
    }
    try {
      return MockDataService.getStatistics();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WebDatabaseService.getStatistics');
      return {
        'totalItems': 0,
        'expiredCount': 0,
        'soonCount': 0,
        'freshCount': 0,
      };
    }
  }
}
