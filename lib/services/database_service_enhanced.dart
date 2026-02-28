import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/food_item.dart';
import '../utils/error_handler.dart';

class DatabaseServiceEnhanced {
  static sqflite.Database? _database;
  static const String _tableName = 'food_items';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);

  // データベース初期化
  static Future<sqflite.Database> get database async {
    if (kIsWeb) {
      throw AppDatabaseException('Database is not supported on web platform');
    }
    
    if (_database != null) return _database!;
    
    try {
      _database = await _initDatabaseWithRetry();
      return _database!;
    } catch (e) {
      throw AppDatabaseException('Failed to initialize database', originalError: e);
    }
  }

  // リトライ付きデータベース初期化
  static Future<sqflite.Database> _initDatabaseWithRetry({int retryCount = 0}) async {
    try {
      return await _initDatabase();
    } catch (e) {
      if (retryCount < _maxRetries) {
        if (kDebugMode) {
          print('Database initialization failed, retrying... (${retryCount + 1}/$_maxRetries)');
        }
        await Future.delayed(_retryDelay);
        return await _initDatabaseWithRetry(retryCount: retryCount + 1);
      }
      rethrow;
    }
  }

  // データベース作成
  static Future<sqflite.Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'food_loss_app.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: _onOpen,
      );
    } catch (e) {
      throw AppDatabaseException('Failed to create database', originalError: e);
    }
  }

  // データベースオープン時の処理
  static Future<void> _onOpen(sqflite.Database db) async {
    // 外部キー制約を有効化
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // テーブル作成
  static Future<void> _onCreate(sqflite.Database db, int version) async {
    try {
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
          isConsumed INTEGER DEFAULT 0
        )
      ''');
      
      // インデックス作成
      await db.execute('CREATE INDEX idx_expiry_date ON $_tableName(expiryDate)');
      await db.execute('CREATE INDEX idx_category ON $_tableName(category)');
      await db.execute('CREATE INDEX idx_storage_location ON $_tableName(storageLocation)');
      
    } catch (e) {
      throw AppDatabaseException('Failed to create table', originalError: e);
    }
  }

  // 食材の追加
  static Future<String> addFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      final id = await db.insert(_tableName, foodItem.toJson());
      return foodItem.id;
    } catch (e) {
      throw AppDatabaseException('Failed to add food item', originalError: e);
    }
  }

  // 全食材の取得
  static Future<List<FoodItem>> getAllFoodItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'isConsumed = 0',
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Failed to get food items', originalError: e);
    }
  }

  // IDで食材を取得
  static Future<FoodItem?> getFoodItemById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return FoodItem.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException('Failed to get food item by id', originalError: e);
    }
  }

  // 食材の更新
  static Future<int> updateFoodItem(FoodItem foodItem) async {
    try {
      final db = await database;
      return await db.update(
        _tableName,
        foodItem.toJson(),
        where: 'id = ?',
        whereArgs: [foodItem.id],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to update food item', originalError: e);
    }
  }

  // 食材の削除
  static Future<int> deleteFoodItem(String id) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to delete food item', originalError: e);
    }
  }

  // 期限切れの食材を取得
  static Future<List<FoodItem>> getExpiredItems() async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'expiryDate < ? AND isConsumed = 0',
        whereArgs: [now],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Failed to get expired items', originalError: e);
    }
  }

  // 期限が近い食材を取得
  static Future<List<FoodItem>> getExpiringSoonItems({int days = 3}) async {
    try {
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
    } catch (e) {
      throw AppDatabaseException('Failed to get expiring soon items', originalError: e);
    }
  }

  // カテゴリ別に食材を取得
  static Future<List<FoodItem>> getFoodItemsByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'category = ? AND isConsumed = 0',
        whereArgs: [category],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Failed to get food items by category', originalError: e);
    }
  }

  // 保管場所別に食材を取得
  static Future<List<FoodItem>> getFoodItemsByStorageLocation(String location) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'storageLocation = ? AND isConsumed = 0',
        whereArgs: [location],
        orderBy: 'expiryDate ASC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Failed to get food items by storage location', originalError: e);
    }
  }

  // 食材を消費済みにする
  static Future<int> markAsConsumed(String id) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      return await db.update(
        _tableName,
        {
          'isConsumed': 1,
          'consumptionDate': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('Failed to mark food item as consumed', originalError: e);
    }
  }

  // 消費済みの食材を取得
  static Future<List<FoodItem>> getConsumedItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'isConsumed = 1',
        orderBy: 'consumptionDate DESC',
      );
      return List.generate(maps.length, (i) => FoodItem.fromJson(maps[i]));
    } catch (e) {
      throw AppDatabaseException('Failed to get consumed items', originalError: e);
    }
  }

  // データベースの統計情報を取得
  static Future<Map<String, int>> getStatistics() async {
    try {
      final db = await database;
      
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE isConsumed = 0');
      final expiredResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE expiryDate < datetime("now") AND isConsumed = 0');
      final consumedResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE isConsumed = 1');
      
      return {
        'total': totalResult.first['count'] as int,
        'expired': expiredResult.first['count'] as int,
        'consumed': consumedResult.first['count'] as int,
      };
    } catch (e) {
      throw AppDatabaseException('Failed to get statistics', originalError: e);
    }
  }

  // データベースを閉じる
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // データベースをリセット
  static Future<void> reset() async {
    try {
      await close();
      final path = join(await getDatabasesPath(), 'food_loss_app.db');
      await deleteDatabase(path);
    } catch (e) {
      throw AppDatabaseException('Failed to reset database', originalError: e);
    }
  }
}
