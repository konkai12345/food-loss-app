import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_info.dart';
import '../models/recipe.dart';
import '../utils/error_handler.dart';

class CacheService {
  static const String _productCachePrefix = 'product_cache_';
  static const String _recipeCachePrefix = 'recipe_cache_';
  static const Duration _cacheExpiry = Duration(days: 7);

  // 商品情報キャッシュ保存
  static Future<void> cacheProductInfo(ProductInfo productInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_productCachePrefix${productInfo.barcode}';
      
      final cacheData = {
        'data': productInfo.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(key, json.encode(cacheData));
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.cacheProductInfo');
    }
  }

  // 商品情報キャッシュ取得
  static Future<ProductInfo?> getCachedProductInfo(String barcode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_productCachePrefix$barcode';
      
      final cachedData = prefs.getString(key);
      if (cachedData == null) return null;

      final cache = json.decode(cachedData) as Map<String, dynamic>;
      final timestamp = cache['timestamp'] as int;
      
      // キャッシュの有効期限チェック
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await prefs.remove(key);
        return null;
      }

      return ProductInfo.fromJson(cache['data'] as Map<String, dynamic>);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.getCachedProductInfo');
      return null;
    }
  }

  // レシピキャッシュ保存
  static Future<void> cacheRecipe(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_recipeCachePrefix${recipe.recipeId}';
      
      final cacheData = {
        'data': recipe.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(key, json.encode(cacheData));
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.cacheRecipe');
    }
  }

  // レシピキャッシュ取得
  static Future<Recipe?> getCachedRecipe(String recipeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_recipeCachePrefix$recipeId';
      
      final cachedData = prefs.getString(key);
      if (cachedData == null) return null;

      final cache = json.decode(cachedData) as Map<String, dynamic>;
      final timestamp = cache['timestamp'] as int;
      
      // キャッシュの有効期限チェック
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await prefs.remove(key);
        return null;
      }

      return Recipe.fromJson(cache['data'] as Map<String, dynamic>);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.getCachedRecipe');
      return null;
    }
  }

  // レシピ検索キャッシュ
  static Future<void> cacheRecipeSearch(String query, List<Recipe> recipes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'recipe_search_$query';
      
      final cacheData = {
        'data': recipes.map((r) => r.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(key, json.encode(cacheData));
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.cacheRecipeSearch');
    }
  }

  // レシピ検索キャッシュ取得
  static Future<List<Recipe>?> getCachedRecipeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'recipe_search_$query';
      
      final cachedData = prefs.getString(key);
      if (cachedData == null) return null;

      final cache = json.decode(cachedData) as Map<String, dynamic>;
      final timestamp = cache['timestamp'] as int;
      
      // キャッシュの有効期限チェック
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        await prefs.remove(key);
        return null;
      }

      final recipesData = cache['data'] as List<dynamic>;
      return recipesData.map((r) => Recipe.fromJson(r as Map<String, dynamic>)).toList();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.getCachedRecipeSearch');
      return null;
    }
  }

  // 古いキャッシュをクリーンアップ
  static Future<void> cleanupExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_productCachePrefix) || key.startsWith(_recipeCachePrefix)) {
          final cachedData = prefs.getString(key);
          if (cachedData != null) {
            final cache = json.decode(cachedData) as Map<String, dynamic>;
            final timestamp = cache['timestamp'] as int;
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            
            if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.cleanupExpiredCache');
    }
  }

  // キャッシュサイズを取得
  static Future<Map<String, int>> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int productCacheCount = 0;
      int recipeCacheCount = 0;

      for (final key in keys) {
        if (key.startsWith(_productCachePrefix)) {
          productCacheCount++;
        } else if (key.startsWith(_recipeCachePrefix)) {
          recipeCacheCount++;
        }
      }

      return {
        'productCache': productCacheCount,
        'recipeCache': recipeCacheCount,
        'total': productCacheCount + recipeCacheCount,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.getCacheSize');
      return {'productCache': 0, 'recipeCache': 0, 'total': 0};
    }
  }

  // 全キャッシュをクリア
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_productCachePrefix) || 
            key.startsWith(_recipeCachePrefix) ||
            key.startsWith('recipe_search_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'CacheService.clearAllCache');
    }
  }
}
