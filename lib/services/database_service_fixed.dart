import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/product_info.dart';
import '../models/recipe.dart';
import 'web_database_service.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'food_items';

  // データベース初期化
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // データベース作成
  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'food_loss_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // テーブル作成
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        expiryDate TEXT NOT NULL,
        registrationDate TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        storageLocation TEXT NOT NULL,
        category TEXT NOT NULL,
        memo TEXT,
        imagePath TEXT,
        price REAL,
        purchaseStore TEXT,
        consumptionDate TEXT,
        isConsumed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 買い物リストテーブル
    await db.execute('''
      CREATE TABLE shopping_lists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        createdDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 買い物アイテムテーブル
    await db.execute('''
      CREATE TABLE shopping_items (
        id TEXT PRIMARY KEY,
        listId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        barcode TEXT,
        isPurchased INTEGER NOT NULL DEFAULT 0,
        createdDate TEXT NOT NULL,
        FOREIGN KEY (listId) REFERENCES shopping_lists(id)
      )
    ''');

    // 商品情報キャッシュテーブル
    await db.execute('''
      CREATE TABLE product_cache (
        barcode TEXT PRIMARY KEY,
        productName TEXT,
        brand TEXT,
        categories TEXT,
        imageUrl TEXT,
        nutriments TEXT,
        cachedDate TEXT NOT NULL
      )
    ''');

    // レシピキャッシュテーブル
    await db.execute('''
      CREATE TABLE recipe_cache (
        recipeId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT,
        area TEXT,
        instructions TEXT,
        ingredients TEXT,
        imageUrl TEXT,
        cachedDate TEXT NOT NULL
      )
    ''');
  }

  // Web環境の場合はWebDatabaseServiceを使用
  static Future<void> addFoodItem(FoodItem item) async {
    if (kIsWeb) {
      await WebDatabaseService.addFoodItem(item);
    } else {
      final db = await database;
      await db.insert(
        _tableName,
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 全食材アイテム取得
  static Future<List<FoodItem>> getAllFoodItems() async {
    if (kIsWeb) {
      return await WebDatabaseService.getAllFoodItems();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'isConsumed = ?',
        whereArgs: [0],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    }
  }

  // 食材アイテム更新
  static Future<void> updateFoodItem(FoodItem item) async {
    if (kIsWeb) {
      await WebDatabaseService.updateFoodItem(item);
    } else {
      final db = await database;
      await db.update(
        _tableName,
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  // 食材アイテム削除
  static Future<void> deleteFoodItem(String id) async {
    if (kIsWeb) {
      await WebDatabaseService.deleteFoodItem(id);
    } else {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // 食材を消費済みにする
  static Future<void> markAsConsumed(String id) async {
    if (kIsWeb) {
      await WebDatabaseService.markAsConsumed(id);
    } else {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      await db.update(
        _tableName,
        {
          'isConsumed': 1,
          'consumptionDate': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // 期限切れの食材を取得
  static Future<List<FoodItem>> getExpiredItems() async {
    if (kIsWeb) {
      final allItems = await WebDatabaseService.getAllFoodItems();
      return allItems.where((item) => item.daysUntilExpiry < 0).toList();
    } else {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'expiryDate < ? AND isConsumed = 0',
        whereArgs: [now],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    }
  }

  // 期限が近い食材を取得
  static Future<List<FoodItem>> getExpiringSoonItems({int days = 3}) async {
    if (kIsWeb) {
      final allItems = await WebDatabaseService.getAllFoodItems();
      return allItems.where((item) => item.daysUntilExpiry > 0 && item.daysUntilExpiry <= days).toList();
    } else {
      final db = await database;
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'expiryDate BETWEEN ? AND ? AND isConsumed = 0',
        whereArgs: [now.toIso8601String(), futureDate.toIso8601String()],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    }
  }

  // カテゴリ別食材取得
  static Future<List<FoodItem>> getFoodItemsByCategory(String category) async {
    if (kIsWeb) {
      return await WebDatabaseService.getFoodItemsByCategory(category);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'category = ? AND isConsumed = 0',
        whereArgs: [category],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    }
  }

  // 保管場所別に食材を取得
  static Future<List<FoodItem>> getFoodItemsByStorageLocation(String location) async {
    if (kIsWeb) {
      return await WebDatabaseService.getFoodItemsByStorageLocation(location);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'storageLocation = ? AND isConsumed = 0',
        whereArgs: [location],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    }
  }

  // 買い物リスト関連メソッド
  
  // 買い物リスト作成
  static Future<String> createShoppingList(String name) async {
    if (kIsWeb) {
      return await WebDatabaseService.createShoppingList(name);
    } else {
      final db = await database;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final shoppingList = ShoppingList(
        id: id,
        name: name,
        createdDate: DateTime.now(),
      );
      await db.insert('shopping_lists', shoppingList.toJson());
      return id;
    }
  }

  // 全買い物リスト取得
  static Future<List<ShoppingList>> getAllShoppingLists() async {
    if (kIsWeb) {
      return await WebDatabaseService.getAllShoppingLists();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'shopping_lists',
        orderBy: 'createdDate DESC',
      );
      return List.generate(maps.length, (i) => ShoppingList.fromJson(maps[i]));
    }
  }

  // 買い物リスト削除
  static Future<void> deleteShoppingList(String id) async {
    if (kIsWeb) {
      await WebDatabaseService.deleteShoppingList(id);
    } else {
      final db = await database;
      await db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
      await db.delete('shopping_items', where: 'listId = ?', whereArgs: [id]);
    }
  }

  // 買い物アイテム追加
  static Future<String> addShoppingItem(String listId, String productName, {int quantity = 1, String? barcode}) async {
    if (kIsWeb) {
      return await WebDatabaseService.addShoppingItem(listId, productName, quantity: quantity, barcode: barcode);
    } else {
      final db = await database;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final shoppingItem = ShoppingItem(
        id: id,
        listId: listId,
        productName: productName,
        quantity: quantity,
        barcode: barcode,
        createdDate: DateTime.now(),
      );
      await db.insert('shopping_items', shoppingItem.toJson());
      return id;
    }
  }

  // 買い物アイテム取得
  static Future<List<ShoppingItem>> getShoppingItems(String listId) async {
    if (kIsWeb) {
      return await WebDatabaseService.getShoppingItems(listId);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'shopping_items',
        where: 'listId = ?',
        whereArgs: [listId],
        orderBy: 'createdDate ASC',
      );
      return List.generate(maps.length, (i) => ShoppingItem.fromJson(maps[i]));
    }
  }

  // 買い物アイテム更新
  static Future<void> updateShoppingItem(ShoppingItem item) async {
    if (kIsWeb) {
      await WebDatabaseService.updateShoppingItem(item);
    } else {
      final db = await database;
      await db.update(
        'shopping_items',
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  // 買い物アイテム削除
  static Future<void> deleteShoppingItem(String id) async {
    if (kIsWeb) {
      await WebDatabaseService.deleteShoppingItem(id);
    } else {
      final db = await database;
      await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
    }
  }

  // 商品情報キャッシュ関連メソッド
  
  // 商品情報キャッシュ保存
  static Future<void> cacheProductInfo(ProductInfo productInfo) async {
    if (kIsWeb) {
      // Web版ではMockDataServiceがキャッシュを管理
    } else {
      final db = await database;
      await db.insert(
        'product_cache',
        productInfo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 商品情報キャッシュ取得
  static Future<ProductInfo?> getCachedProductInfo(String barcode) async {
    if (kIsWeb) {
      return await WebDatabaseService.getCachedProductInfo(barcode);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'product_cache',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
      if (maps.isNotEmpty) {
        return ProductInfo.fromJson(maps.first);
      }
      return null;
    }
  }

  // レシピキャッシュ関連メソッド
  
  // レシピキャッシュ保存
  static Future<void> cacheRecipe(Recipe recipe) async {
    if (kIsWeb) {
      // Web版ではMockDataServiceがキャッシュを管理
    } else {
      final db = await database;
      await db.insert(
        'recipe_cache',
        recipe.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // レシピキャッシュ取得
  static Future<Recipe?> getCachedRecipe(String recipeId) async {
    if (kIsWeb) {
      return await WebDatabaseService.getCachedRecipe(recipeId);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'recipe_cache',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
      );
      if (maps.isNotEmpty) {
        return Recipe.fromJson(maps.first);
      }
      return null;
    }
  }

  // レシピキャッシュ検索
  static Future<List<Recipe>> searchCachedRecipes(String query) async {
    if (kIsWeb) {
      return await WebDatabaseService.searchCachedRecipes(query);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'recipe_cache',
        where: 'title LIKE ? OR ingredients LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'cachedDate DESC',
      );
      return List.generate(maps.length, (i) => Recipe.fromJson(maps[i]));
    }
  }

  // 統計情報取得
  static Future<Map<String, int>> getStatistics() async {
    if (kIsWeb) {
      return await WebDatabaseService.getStatistics();
    } else {
      final db = await database;
      
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE isConsumed = 0');
      final expiredResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE expiryDate < datetime("now") AND isConsumed = 0');
      final soonResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE expiryDate <= ? AND expiryDate >= ? AND isConsumed = 0',
        [
          DateTime.now().add(Duration(days: 3)).toIso8601String(),
          DateTime.now().toIso8601String()
        ]
      );
      
      final totalItems = totalResult.first['count'] as int;
      final expiredCount = expiredResult.first['count'] as int;
      final soonCount = soonResult.first['count'] as int;
      
      return {
        'totalItems': totalItems,
        'expiredCount': expiredCount,
        'soonCount': soonCount,
        'freshCount': totalItems - expiredCount - soonCount,
      };
    }
  }

  // データベースクローズ
  static Future<void> close() async {
    if (kIsWeb) {
      // Web版では何もしない
    } else {
      final db = await database;
      await db.close();
      _database = null;
    }
  }

  // データベースをリセット
  static Future<void> reset() async {
    if (kIsWeb) {
      // Web版では何もしない
    } else {
      await close();
      final path = join(await getDatabasesPath(), 'food_loss_app.db');
      await deleteDatabase(path);
    }
  }
}
