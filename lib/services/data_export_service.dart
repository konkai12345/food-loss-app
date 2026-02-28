import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/mock_data_service.dart';
import '../services/family_service.dart';
import '../utils/error_handler.dart';

class DataExportService {
  // CSV出力機能
  static Future<String> exportToCSV(String dataType) async {
    try {
      List<Map<String, dynamic>> data;
      String fileName;
      
      switch (dataType) {
        case 'food_items':
          data = await _getFoodItemsData();
          fileName = 'food_items_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'shopping_lists':
          data = await _getShoppingListsData();
          fileName = 'shopping_lists_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'recipes':
          data = await _getRecipesData();
          fileName = 'recipes_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'users':
          data = await _getUsersData();
          fileName = 'users_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'families':
          data = await _getFamiliesData();
          fileName = 'families_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        case 'all':
          data = await _getAllData();
          fileName = 'all_data_${DateTime.now().millisecondsSinceEpoch}.csv';
          break;
        default:
          throw Exception('不明なデータタイプ: $dataType');
      }

      final csvData = _convertToCSV(data);
      final filePath = await _saveToFile(csvData, fileName);
      
      return filePath;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.exportToCSV');
      rethrow;
    }
  }

  // JSON出力機能
  static Future<String> exportToJSON(String dataType) async {
    try {
      Map<String, dynamic> data;
      String fileName;
      
      switch (dataType) {
        case 'food_items':
          data = {'food_items': await _getFoodItemsData()};
          fileName = 'food_items_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case 'shopping_lists':
          data = {'shopping_lists': await _getShoppingListsData()};
          fileName = 'shopping_lists_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case 'recipes':
          data = {'recipes': await _getRecipesData()};
          fileName = 'recipes_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case 'users':
          data = {'users': await _getUsersData()};
          fileName = 'users_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case 'families':
          data = {'families': await _getFamiliesData()};
          fileName = 'families_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        case 'all':
          data = await _getAllDataAsJSON();
          fileName = 'all_data_${DateTime.now().millisecondsSinceEpoch}.json';
          break;
        default:
          throw Exception('不明なデータタイプ: $dataType');
      }

      final jsonData = const JsonEncoder.withIndent('  ').convert(data);
      final filePath = await _saveToFile(jsonData, fileName);
      
      return filePath;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.exportToJSON');
      rethrow;
    }
  }

  // バックアップ機能
  static Future<String> createBackup() async {
    try {
      final backupData = {
        'version': '1.0.0',
        'created_at': DateTime.now().toIso8601String(),
        'data': await _getAllDataAsJSON(),
      };

      final jsonData = const JsonEncoder.withIndent('  ').convert(backupData);
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = await _saveToFile(jsonData, fileName);
      
      return filePath;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.createBackup');
      rethrow;
    }
  }

  // 復元機能
  static Future<bool> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('バックアップファイルが見つかりません');
      }

      final content = await file.readAsString();
      final backupData = jsonDecode(content) as Map<String, dynamic>;
      
      // バージョンチェック
      final version = backupData['version'] as String?;
      if (version != '1.0.0') {
        throw Exception('バックアップのバージョンが一致しません');
      }

      final data = backupData['data'] as Map<String, dynamic>;
      
      // データの復元
      await _restoreData(data);
      
      return true;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.restoreFromBackup');
      return false;
    }
  }

  // データ共有機能
  static Future<void> shareData(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath, name: file.path.split('/').last)],
          subject: 'データ共有',
          text: '食品ロス削減アプリのデータを共有します',
        );
      } else {
        throw Exception('ファイルが見つかりません');
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.shareData');
    }
  }

  // データ取得メソッド
  static Future<List<Map<String, dynamic>>> _getFoodItemsData() async {
    List<FoodItem> items;
    
    if (kIsWeb) {
      items = await MockDataService.getAllFoodItems();
    } else {
      items = await DatabaseService.getAllFoodItems();
    }

    return items.map((item) => {
      'id': item.id,
      'name': item.name,
      'expiryDate': item.expiryDate.toIso8601String(),
      'quantity': item.quantity,
      'storageLocation': item.storageLocation,
      'category': item.category,
      'memo': item.memo,
      'price': item.price,
      'purchaseStore': item.purchaseStore,
      'registrationDate': item.registrationDate.toIso8601String(),
      'isConsumed': item.isConsumed,
      'daysUntilExpiry': item.daysUntilExpiry,
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _getShoppingListsData() async {
    List<ShoppingList> lists;
    
    if (kIsWeb) {
      lists = MockDataService.getMockShoppingLists();
    } else {
      lists = await DatabaseService.getAllShoppingLists();
    }

    final List<Map<String, dynamic>> result = [];
    
    for (final list in lists) {
      final items = kIsWeb 
          ? MockDataService.getMockShoppingItems().where((item) => item.listId == list.id).toList()
          : await DatabaseService.getShoppingItems(list.id);
      
      result.add({
        'id': list.id,
        'name': list.name,
        'createdDate': list.createdDate.toIso8601String(),
        'isCompleted': list.isCompleted,
        'items': items.map((item) => {
          'id': item.id,
          'listId': item.listId,
          'productName': item.productName,
          'quantity': item.quantity,
          'barcode': item.barcode,
          'isPurchased': item.isPurchased,
          'createdDate': item.createdDate.toIso8601String(),
        }).toList(),
      });
    }
    
    return result;
  }

  static Future<List<Map<String, dynamic>>> _getRecipesData() async {
    List<Recipe> recipes;
    
    if (kIsWeb) {
      recipes = MockDataService.getMockRecipes();
    } else {
      // 実際のデータベースから取得
      recipes = MockDataService.getMockRecipes(); // 簡易実装
    }

    return recipes.map((recipe) => {
      'recipeId': recipe.recipeId,
      'title': recipe.title,
      'category': recipe.category,
      'area': recipe.area,
      'instructions': recipe.instructions,
      'ingredients': recipe.ingredients,
      'imageUrl': recipe.imageUrl,
      'cachedDate': recipe.cachedDate.toIso8601String(),
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _getUsersData() async {
    final users = await FamilyService.getAllUsers();
    
    return users.map((user) => {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'avatarUrl': user.avatarUrl,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt.toIso8601String(),
      'isActive': user.isActive,
      'familyIds': user.familyIds,
      'preferences': user.preferences,
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> _getFamiliesData() async {
    final families = await FamilyService.getAllFamilies();
    
    final List<Map<String, dynamic>> result = [];
    
    for (final family in families) {
      final members = await FamilyService.getFamilyMembers(family.id);
      
      result.add({
        'id': family.id,
        'name': family.name,
        'description': family.description,
        'createdBy': family.createdBy,
        'createdAt': family.createdAt.toIso8601String(),
        'memberIds': family.memberIds,
        'settings': family.settings,
        'members': members.map((member) => {
          'id': member.id,
          'familyId': member.familyId,
          'userId': member.userId,
          'userName': member.userName,
          'userEmail': member.userEmail,
          'role': member.role,
          'joinedAt': member.joinedAt.toIso8601String(),
          'isActive': member.isActive,
          'permissions': member.permissions,
        }).toList(),
      });
    }
    
    return result;
  }

  static Future<List<Map<String, dynamic>>> _getAllData() async {
    final allData = <Map<String, dynamic>>[];
    
    // 食材データ
    final foodItems = await _getFoodItemsData();
    for (final item in foodItems) {
      allData.add({...item, 'data_type': 'food_item'});
    }
    
    // 買い物リストデータ
    final shoppingLists = await _getShoppingListsData();
    for (final list in shoppingLists) {
      allData.add({...list, 'data_type': 'shopping_list'});
    }
    
    // レシピデータ
    final recipes = await _getRecipesData();
    for (final recipe in recipes) {
      allData.add({...recipe, 'data_type': 'recipe'});
    }
    
    // ユーザーデータ
    final users = await _getUsersData();
    for (final user in users) {
      allData.add({...user, 'data_type': 'user'});
    }
    
    // ファミリーデータ
    final families = await _getFamiliesData();
    for (final family in families) {
      allData.add({...family, 'data_type': 'family'});
    }
    
    return allData;
  }

  static Future<Map<String, dynamic>> _getAllDataAsJSON() async {
    return {
      'food_items': await _getFoodItemsData(),
      'shopping_lists': await _getShoppingListsData(),
      'recipes': await _getRecipesData(),
      'users': await _getUsersData(),
      'families': await _getFamiliesData(),
    };
  }

  // CSV変換
  static String _convertToCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    final headers = data.first.keys.toList();
    final csvRows = <String>[];
    
    // ヘッダー行
    csvRows.add(headers.join(','));
    
    // データ行
    for (final row in data) {
      final values = headers.map((header) {
        final value = row[header]?.toString() ?? '';
        // 値にカンマが含まれる場合は引用符で囲む
        if (value.contains(',')) {
          return '"$value"';
        }
        return value;
      }).toList();
      csvRows.add(values.join(','));
    }
    
    return csvRows.join('\n');
  }

  // ファイル保存
  static Future<String> _saveToFile(String content, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      await file.writeAsString(content);
      return filePath;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService._saveToFile');
      rethrow;
    }
  }

  // データ復元
  static Future<void> _restoreData(Map<String, dynamic> data) async {
    try {
      // 食材データの復元
      if (data.containsKey('food_items')) {
        final foodItems = data['food_items'] as List;
        for (final item in foodItems) {
          if (kIsWeb) {
            // Web版ではモックデータに追加
            // 実際の実装では必要に応じて処理
          } else {
            // モバイル版ではデータベースに保存
            final foodItem = FoodItem(
              id: item['id'],
              name: item['name'],
              expiryDate: DateTime.parse(item['expiryDate']),
              quantity: item['quantity'],
              storageLocation: item['storageLocation'],
              category: item['category'],
              memo: item['memo'],
              price: item['price']?.toDouble(),
              purchaseStore: item['purchaseStore'],
              registrationDate: DateTime.parse(item['registrationDate']),
              isConsumed: item['isConsumed'],
            );
            await DatabaseService.addFoodItem(foodItem);
          }
        }
      }
      
      // 買い物リストデータの復元
      if (data.containsKey('shopping_lists')) {
        final shoppingLists = data['shopping_lists'] as List;
        for (final list in shoppingLists) {
          if (kIsWeb) {
            // Web版ではモックデータに追加
          } else {
            final shoppingList = ShoppingList(
              id: list['id'],
              name: list['name'],
              createdDate: DateTime.parse(list['createdDate']),
              isCompleted: list['isCompleted'],
            );
            await DatabaseService.addShoppingList(shoppingList);
            
            // アイテムの復元
            final items = list['items'] as List;
            for (final item in items) {
              final shoppingItem = ShoppingItem(
                id: item['id'],
                listId: item['listId'],
                productName: item['productName'],
                quantity: item['quantity'],
                barcode: item['barcode'],
                isPurchased: item['isPurchased'],
                createdDate: DateTime.parse(item['createdDate']),
              );
              await DatabaseService.addShoppingItem(shoppingItem.listId, shoppingItem.productName, quantity: shoppingItem.quantity, barcode: shoppingItem.barcode);
            }
          }
        }
      }
      
      // 他のデータタイプも同様に復元...
      
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService._restoreData');
      rethrow;
    }
  }

  // データ統計情報
  static Future<Map<String, dynamic>> getDataStatistics() async {
    try {
      final foodItems = await _getFoodItemsData();
      final shoppingLists = await _getShoppingListsData();
      final recipes = await _getRecipesData();
      final users = await _getUsersData();
      final families = await _getFamiliesData();
      
      return {
        'food_items': {
          'total': foodItems.length,
          'expired': foodItems.where((item) => item['daysUntilExpiry'] < 0).length,
          'consumed': foodItems.where((item) => item['isConsumed']).length,
        },
        'shopping_lists': {
          'total': shoppingLists.length,
          'completed': shoppingLists.where((list) => list['isCompleted']).length,
          'total_items': shoppingLists.fold<int>(0, (sum, list) => sum + (list['items'] as List).length),
        },
        'recipes': {
          'total': recipes.length,
        },
        'users': {
          'total': users.length,
          'active': users.where((user) => user['isActive']).length,
        },
        'families': {
          'total': families.length,
          'total_members': families.fold<int>(0, (sum, family) => sum + (family['members'] as List).length),
        },
        'export_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.getDataStatistics');
      return {};
    }
  }

  // データクリーンアップ
  static Future<void> cleanupOldData({int daysToKeep = 365}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      // 古いデータの削除処理
      // 実際の実装ではデータベースから古いデータを削除
      
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'DataExportService.cleanupOldData');
    }
  }
}
