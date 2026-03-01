import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/product_info.dart';
import '../models/recipe.dart';
import '../utils/error_handler.dart';

class DatabaseService {
  static const String _tableName = 'food_items';
  static Database? _database;
  
  // Web環境用のメモリ内データ
  static List<FoodItem> _mockFoodItems = [];
  static List<ShoppingItem> _mockShoppingItems = [];

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

    // 共有グループテーブル
    await db.execute('''
      CREATE TABLE shared_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        memberIds TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        createdBy TEXT NOT NULL
      )
    ''');

    // インデックス作成（パフォーマンス向上）
    await db.execute('CREATE INDEX idx_food_items_expiryDate ON food_items(expiryDate)');
    await db.execute('CREATE INDEX idx_food_items_category ON food_items(category)');
    await db.execute('CREATE INDEX idx_food_items_name ON food_items(name)');
    await db.execute('CREATE INDEX idx_shopping_items_listId ON shopping_items(listId)');
    await db.execute('CREATE INDEX idx_product_cache_barcode ON product_cache(barcode)');
    await db.execute('CREATE INDEX idx_recipe_cache_category ON recipe_cache(category)');
    await db.execute('CREATE INDEX idx_recipe_cache_cachedDate ON recipe_cache(cachedDate)');
    await db.execute('CREATE INDEX idx_shared_groups_createdBy ON shared_groups(createdBy)');
  }

  // 食材アイテム追加
  static Future<void> addFoodItem(FoodItem item) async {
    if (kIsWeb) {
      // Web環境ではメモリ内でデータを管理
      _mockFoodItems.add(item);
      print('Web環境で食材を追加: ${item.name}');
      return;
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
      // Web環境ではメモリ内のデータを返す
      return _mockFoodItems;
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
      // Web環境ではメモリ内データを更新
      final index = _mockFoodItems.indexWhere((foodItem) => foodItem.id == item.id);
      if (index != -1) {
        _mockFoodItems[index] = item;
        print('Web環境で食材を更新: ${item.name}');
      }
      return;
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
      // Web環境ではメモリ内データから削除
      _mockFoodItems.removeWhere((item) => item.id == id);
      print('Web環境で食材を削除しました: $id');
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
      // Web環境では何もしない
      print('Web環境では消費済みマークをスキップします');
      return;
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
      // Web環境ではモックデータを返す
      return await _getMockFoodItems();
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
      // Web環境ではモックデータを返す
      return await _getMockFoodItems();
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
      // Web環境ではメモリ内データからフィルター
      return _mockFoodItems.where((item) => 
        item.category == category && !item.isConsumed
      ).toList();
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
      // Web環境ではメモリ内データからフィルター
      return _mockFoodItems.where((item) => 
        item.storageLocation == location && !item.isConsumed
      ).toList();
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
      // Web環境ではモックデータを返す
      return await _getMockShoppingList();
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
      // Web環境ではモックデータを返す
      return await _getMockShoppingLists();
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
      // Web環境では何もしない
      print('Web環境ではショッピングリストの削除をスキップします');
    } else {
      final db = await database;
      await db.delete('shopping_lists', where: 'id = ?', whereArgs: [id]);
      await db.delete('shopping_items', where: 'listId = ?', whereArgs: [id]);
    }
  }

  // 食材関連のヘルパーメソッド
  static Future<FoodItem?> getFoodItemById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'food_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return FoodItem.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DatabaseService.getFoodItemById');
      return null;
    }
  }

  // 買い物リスト関連のヘルパーメソッド
  static Future<ShoppingList?> getShoppingListById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'shopping_lists',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return ShoppingList.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DatabaseService.getShoppingListById');
      return null;
    }
  }

  // 買い物リストの追加
  static Future<void> addShoppingList(ShoppingList list) async {
    try {
      final db = await database;
      await db.insert('shopping_lists', list.toJson());
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DatabaseService.addShoppingList');
    }
  }

  // 買い物アイテム追加
  static Future<String> addShoppingItem(String listId, String productName, {int quantity = 1, String? barcode, DateTime? plannedPurchaseDate}) async {
    if (kIsWeb) {
      final item = ShoppingItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        listId: listId,
        productName: productName,
        quantity: quantity,
        barcode: barcode ?? '',
        isPurchased: false,
        createdDate: DateTime.now(),
        plannedPurchaseDate: plannedPurchaseDate,
      );
      // Web環境ではメモリに保存
      _mockShoppingItems.add(item);
      return item.id;
    } else {
      final db = await database;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final shoppingItem = ShoppingItem(
        id: id,
        listId: listId,
        productName: productName,
        quantity: quantity,
        barcode: barcode ?? '',
        isPurchased: false,
        createdDate: DateTime.now(),
        plannedPurchaseDate: plannedPurchaseDate,
      );
      await db.insert('shopping_items', shoppingItem.toJson());
      return id;
    }
  }

  // 買い物アイテム取得
  static Future<List<ShoppingItem>> getShoppingItems(String listId) async {
    if (kIsWeb) {
      // Web環境ではメモリ内データからフィルタリング
      return _mockShoppingItems.where((item) => item.listId == listId).toList();
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
      // Web環境ではメモリ内データを更新
      final index = _mockShoppingItems.indexWhere((mockItem) => mockItem.id == item.id);
      if (index != -1) {
        _mockShoppingItems[index] = item;
        print('Web環境で買い物アイテムを更新しました: ${item.id}');
      }
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
      // Web環境ではメモリ内データから削除
      _mockShoppingItems.removeWhere((item) => item.id == id);
      print('Web環境で買い物アイテムを削除しました: $id');
    } else {
      final db = await database;
      await db.delete('shopping_items', where: 'id = ?', whereArgs: [id]);
    }
  }

  // モックデータメソッド
static Future<List<FoodItem>> _getMockFoodItems() async {
  return [
    FoodItem(
      id: '1',
      name: 'トマト',
      category: '野菜',
      quantity: 5,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      registrationDate: DateTime.now().subtract(const Duration(days: 1)),
      storageLocation: '冷蔵庫',
    ),
    FoodItem(
      id: '2',
      name: '牛乳',
      category: '乳製品',
      quantity: 1,
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      registrationDate: DateTime.now().subtract(const Duration(days: 2)),
      storageLocation: '冷蔵庫',
    ),
  ];
}

static Future<List<ShoppingItem>> _getMockShoppingItems() async {
  return [
    ShoppingItem(
      id: '1',
      listId: 'mock-list-id',
      productName: 'トマト',
      quantity: 5,
      barcode: '123456789',
      isPurchased: false,
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ShoppingItem(
      id: '2',
      listId: 'mock-list-id',
      productName: '牛乳',
      quantity: 1,
      barcode: '987654321',
      isPurchased: false,
      createdDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}

static Future<String> _getMockShoppingList() async {
  return 'mock-list-id';
}

static Future<List<ShoppingList>> _getMockShoppingLists() async {
  return [
    ShoppingList(
      id: '1',
      name: '今週の買い物',
      createdDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

static Future<ProductInfo?> _getMockProductInfo(String barcode) async {
  return ProductInfo(
    barcode: barcode,
    productName: 'モック商品 ($barcode)',
    brand: 'テストブランド',
    categories: ['食品'],
    nutriments: {
      'calories': 100,
      'protein': 10,
      'carbs': 20,
      'fat': 5,
    },
    cachedDate: DateTime.now(),
  );
}

static Future<Recipe?> _getMockRecipe(String recipeId) async {
  return Recipe(
    recipeId: recipeId,
    title: 'モックレシピ',
    instructions: '手順1\n手順2',
    ingredients: ['材料1', '材料2'],
    cachedDate: DateTime.now(),
  );
}

static Future<List<Recipe>> _getMockRecipesSearch(String query) async {
  return [
    Recipe(
      recipeId: '1',
      title: 'モックレシピ ($query)',
      instructions: '手順1\n手順2',
      ingredients: ['材料1', '材料2'],
      cachedDate: DateTime.now(),
    ),
  ];
}

static Future<Map<String, int>> _getMockStatistics() async {
  return {
    'total': 10,
    'expired': 2,
    'expiring_soon': 3,
    'consumed': 5,
  };
}

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
      // Webデータベースサービスは削除されたため、モックデータを返す
      return await _getMockProductInfo(barcode);
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'product_cache',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
      if (maps.isNotEmpty) {
        final productData = maps.first;
        return ProductInfo(
          barcode: productData['barcode'],
          productName: productData['productName'],
          brand: productData['brand'],
          categories: List<String>.from(productData['categories'] ?? []),
          imageUrl: productData['imageUrl'],
          nutriments: Map<String, dynamic>.from(productData['nutriments'] ?? {}),
          cachedDate: DateTime.parse(productData['cachedDate']),
        );
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
      // Webデータベースサービスは削除されたため、モックデータを返す
      return await _getMockRecipe(recipeId);
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
      // Webデータベースサービスは削除されたため、モックデータを返す
      return await _getMockRecipesSearch(query);
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
      // Web環境ではメモリ内データから統計を計算
      final now = DateTime.now();
      final totalItems = _mockFoodItems.where((item) => !item.isConsumed).length;
      final expiredCount = _mockFoodItems.where((item) => 
        !item.isConsumed && item.expiryDate.isBefore(now)
      ).length;
      final soonCount = _mockFoodItems.where((item) => 
        !item.isConsumed && 
        item.expiryDate.isAfter(now) && 
        item.expiryDate.difference(now).inDays <= 7
      ).length;
      
      return {
        'totalItems': totalItems,
        'expiredCount': expiredCount,
        'soonCount': soonCount,
        'freshCount': totalItems - expiredCount - soonCount,
      };
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
