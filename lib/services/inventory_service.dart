import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../services/mock_data_service.dart';
import '../services/qr_code_service.dart';
import '../utils/error_handler.dart';

class InventoryService {
  // 在庫状況の取得
  static Future<List<FoodItem>> getInventoryStatus() async {
    if (kIsWeb) {
      return MockDataService.getAllFoodItems();
    }
    
    try {
      return await DatabaseService.getAllFoodItems();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.getInventoryStatus');
      return [];
    }
  }

  // 在庫分析の取得
  static Future<Map<String, dynamic>> getInventoryAnalysis() async {
    try {
      final items = await getInventoryStatus();
      
      final totalItems = items.length;
      final expiredItems = items.where((item) => item.daysUntilExpiry < 0).length;
      final soonExpiringItems = items.where((item) => item.daysUntilExpiry > 0 && item.daysUntilExpiry <= 3).length;
      final freshItems = items.where((item) => item.daysUntilExpiry > 3).length;
      final consumedItems = items.where((item) => item.isConsumed).length;

      // カテゴリ別分析
      final Map<String, int> categoryAnalysis = {};
      for (final item in items) {
        final category = item.category;
        categoryAnalysis[category] = (categoryAnalysis[category] ?? 0) + 1;
      }

      // 保管場所別分析
      final Map<String, int> storageAnalysis = {};
      for (final item in items) {
        final location = item.storageLocation;
        storageAnalysis[location] = (storageAnalysis[location] ?? 0) + 1;
      }

      // 期限別分析
      final Map<String, int> expiryAnalysis = {};
      for (final item in items) {
        final daysUntil = item.daysUntilExpiry;
        String category;
        if (daysUntil < 0) {
          category = '期限切れ';
        } else if (daysUntil <= 3) {
          category = '期限近い';
        } else if (daysUntil <= 7) {
          category = '1週間以内';
        } else {
          category = '1ヶ月以上';
        }
        expiryAnalysis[category] = (expiryAnalysis[category] ?? 0) + 1;
      }

      return {
        'totalItems': totalItems,
        'expiredItems': expiredItems,
        'soonExpiringItems': soonExpiringItems,
        'freshItems': freshItems,
        'consumedItems': consumedItems,
        'categoryAnalysis': categoryAnalysis,
        'storageAnalysis': storageAnalysis,
        'expiryAnalysis': expiryAnalysis,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.getInventoryAnalysis');
      return {
        'totalItems': 0,
        'expiredItems': 0,
        'soonExpiringItems': 0,
        'freshItems': 0,
        'consumedItems': 0,
        'categoryAnalysis': {},
        'storageAnalysis': {},
        'expiryAnalysis': {},
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // 在庫レポートの生成
  static Future<Map<String, dynamic>> generateInventoryReport() async {
    try {
      final analysis = await getInventoryAnalysis();
      final items = await getInventoryStatus();

      // 期限切れアイテムの詳細
      final expiredItems = items.where((item) => item.daysUntilExpiry < 0).toList();
      
      // 期限近いアイテムの詳細
      final soonExpiringItems = items
          .where((item) => item.daysUntilExpiry > 0 && item.daysUntilExpiry <= 3)
          .toList()
        ..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

      // 在庫価値の計算
      double totalValue = 0;
      double expiredValue = 0;
      for (final item in items) {
        final price = item.price ?? 0.0;
        totalValue += price;
        if (item.daysUntilExpiry < 0) {
          expiredValue += price;
        }
      }

      return {
        'reportDate': DateTime.now().toIso8601String(),
        'summary': analysis,
        'expiredItems': expiredItems.map((item) => {
          'id': item.id,
          'name': item.name,
          'expiryDate': item.expiryDate.toIso8601String(),
          'daysUntilExpiry': item.daysUntilExpiry,
          'price': item.price,
          'category': item.category,
          'storageLocation': item.storageLocation,
        }).toList(),
        'soonExpiringItems': soonExpiringItems.map((item) => {
          'id': item.id,
          'name': item.name,
          'expiryDate': item.expiryDate.toIso8601String(),
          'daysUntilExpiry': item.daysUntilExpiry,
          'price': item.price,
          'category': item.category,
          'storageLocation': item.storageLocation,
        }).toList(),
        'totalValue': totalValue,
        'expiredValue': expiredValue,
        'lossRate': totalValue > 0 ? (expiredValue / totalValue) * 100 : 0.0,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.generateInventoryReport');
      return {
        'reportDate': DateTime.now().toIso8601String(),
        'summary': {},
        'expiredItems': [],
        'soonExpiringItems': [],
        'totalValue': 0.0,
        'expiredValue': 0.0,
        'lossRate': 0.0,
      };
    }
  }

  // 在庫管理用QRコードの生成
  static Future<String> generateInventoryQRCode() async {
    try {
      final items = await getInventoryStatus();
      return await QRCodeService.generateInventoryQRCode(items);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.generateInventoryQRCode');
      rethrow;
    }
  }

  // 棚卸し用データの生成
  static Future<Map<String, dynamic>> generateStocktakingData() async {
    try {
      final items = await getInventoryStatus();
      final now = DateTime.now();
      
      return {
        'stocktakingDate': now.toIso8601String(),
        'totalItems': items.length,
        'items': items.map((item) => {
          'id': item.id,
          'name': item.name,
          'quantity': item.quantity,
          'expiryDate': item.expiryDate.toIso8601String(),
          'daysUntilExpiry': item.daysUntilExpiry,
          'category': item.category,
          'storageLocation': item.storageLocation,
          'price': item.price,
          'isConsumed': item.isConsumed,
          'status': _getItemStatus(item),
        }).toList(),
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.generateStocktakingData');
      return {
        'stocktakingDate': DateTime.now().toIso8601String(),
        'totalItems': 0,
        'items': [],
      };
    }
  }

  // アイテムのステータス判定
  static String _getItemStatus(FoodItem item) {
    if (item.isConsumed) return '消費済み';
    if (item.daysUntilExpiry < 0) return '期限切れ';
    if (item.daysUntilExpiry <= 3) return '期限近い';
    if (item.daysUntilExpiry <= 7) return '1週間以内';
    return '新鮮';
  }

  // 在庫警告の取得
  static Future<List<Map<String, dynamic>>> getInventoryWarnings() async {
    try {
      final items = await getInventoryStatus();
      final warnings = <Map<String, dynamic>>[];

      for (final item in items) {
        if (item.daysUntilExpiry < 0) {
          warnings.add({
            'type': 'expired',
            'severity': 'high',
            'itemId': item.id,
            'itemName': item.name,
            'message': '期限切れ',
            'daysUntilExpiry': item.daysUntilExpiry,
            'category': item.category,
            'storageLocation': item.storageLocation,
          });
        } else if (item.daysUntilExpiry <= 3) {
          warnings.add({
            'type': 'expiring_soon',
            'severity': 'medium',
            'itemId': item.id,
            'itemName': item.name,
            'message': '期限近い',
            'daysUntilExpiry': item.daysUntilExpiry,
            'category': item.category,
            'storageLocation': item.storageLocation,
          });
        }
      }

      // 重要度でソート
      warnings.sort((a, b) {
        final severityOrder = {'high': 0, 'medium': 1, 'low': 2};
        return severityOrder[a['severity'] as String]!.compareTo(severityOrder[b['severity'] as String]!);
      });

      return warnings;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.getInventoryWarnings');
      return [];
    }
  }

  // 在庫最適化の提案
  static Future<List<Map<String, dynamic>>> getInventoryOptimizationSuggestions() async {
    try {
      final items = await getInventoryStatus();
      final suggestions = <Map<String, dynamic>>[];

      // 期限切れアイテムの処理提案
      final expiredItems = items.where((item) => item.daysUntilExpiry < 0);
      if (expiredItems.isNotEmpty) {
        suggestions.add({
          'type': 'expired_items',
          'priority': 'high',
          'title': '期限切れアイテムの処理',
          'description': '${expiredItems.length}件の期限切れアイテムがあります。廃棄または他の用途を検討してください。',
          'items': expiredItems.map((item) => item.name).toList(),
          'action': 'dispose_or_reuse',
        });
      }

      // 期限近いアイテムの優先消費提案
      final soonExpiringItems = items.where((item) => item.daysUntilExpiry > 0 && item.daysUntilExpiry <= 3);
      if (soonExpiringItems.isNotEmpty) {
        suggestions.add({
          'type': 'expiring_soon',
          'priority': 'medium',
          'title': '期限近いアイテムの優先消費',
          'description': '${soonExpiringItems.length}件のアイテムが期限近いです。優先的に消費することをお勧めします。',
          'items': soonExpiringItems.map((item) => '${item.name} (${item.daysUntilExpiry}日)').toList(),
          'action': 'prioritize_consumption',
        });
      }

      // カテゴリ別の在庫バランス提案
      final categoryAnalysis = <String, int>{};
      for (final item in items) {
        categoryAnalysis[item.category] = (categoryAnalysis[item.category] ?? 0) + 1;
      }

      // 在庫が少ないカテゴリの提案
      final lowStockCategories = categoryAnalysis.entries
          .where((entry) => entry.value < 2)
          .map((entry) => entry.key)
          .toList();

      if (lowStockCategories.isNotEmpty) {
        suggestions.add({
          'type': 'low_stock',
          'priority': 'low',
          'title': '在庫補充の提案',
          'description': '${lowStockCategories.join(', ')}の在庫が少ないです。補充を検討してください。',
          'items': lowStockCategories,
          'action': 'restock_items',
        });
      }

      return suggestions;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.getInventoryOptimizationSuggestions');
      return [];
    }
  }

  // 在庫効率の計算
  static Future<Map<String, double>> calculateInventoryEfficiency() async {
    try {
      final items = await getInventoryStatus();
      
      if (items.isEmpty) {
        return {
          'consumptionRate': 0.0,
          'wasteRate': 0.0,
          'efficiencyScore': 0.0,
        };
      }

      final consumedItems = items.where((item) => item.isConsumed).length;
      final expiredItems = items.where((item) => item.daysUntilExpiry < 0).length;
      final totalItems = items.length;

      final consumptionRate = consumedItems / totalItems * 100;
      final wasteRate = expiredItems / totalItems * 100;
      final efficiencyScore = consumptionRate - wasteRate;

      return {
        'consumptionRate': consumptionRate,
        'wasteRate': wasteRate,
        'efficiencyScore': efficiencyScore,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'InventoryService.calculateInventoryEfficiency');
      return {
        'consumptionRate': 0.0,
        'wasteRate': 0.0,
        'efficiencyScore': 0.0,
      };
    }
  }
}
