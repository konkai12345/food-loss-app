import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../services/mock_data_service.dart';
import '../utils/error_handler.dart';

class AnalyticsService {
  // ロス削減量の計算
  static Future<Map<String, double>> calculateWasteReduction() async {
    if (kIsWeb) {
      return await MockDataService.calculateMockWasteReduction();
    }
    
    try {
      final allItems = await DatabaseService.getAllFoodItems();
      
      double totalWasted = 0.0;
      double totalConsumed = 0.0;
      
      // 破棄された食材（期限切れ）の合計金額
      final expiredItems = allItems.where((item) => item.daysUntilExpiry < 0);
      for (final item in expiredItems) {
        totalWasted += item.price ?? 0.0;
      }
      
      // 消費済み食材の合計金額
      final consumedItems = allItems.where((item) => item.isConsumed);
      for (final item in consumedItems) {
        totalConsumed += item.price ?? 0.0;
      }
      
      return {
        'totalWasted': totalWasted,
        'totalConsumed': totalConsumed,
        'totalReduction': totalConsumed - totalWasted,
        'reductionRate': totalConsumed > 0 ? ((totalConsumed - totalWasted) / totalConsumed) * 100 : 0.0,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'AnalyticsService.calculateWasteReduction');
      return {
        'totalWasted': 0.0,
        'totalConsumed': 0.0,
        'totalReduction': 0.0,
        'reductionRate': 0.0,
      };
    }
  }

  // カテゴリ別ロス分析
  static Future<Map<String, double>> getCategoryWasteAnalysis() async {
    if (kIsWeb) {
      return await MockDataService.getMockCategoryWasteAnalysis();
    }
    
    try {
      final allItems = await DatabaseService.getAllFoodItems();
      final expiredItems = allItems.where((item) => item.daysUntilExpiry < 0);
      
      final Map<String, double> categoryWaste = {};
      
      for (final item in expiredItems) {
        final category = item.category;
        final price = item.price ?? 0.0;
        
        if (categoryWaste.containsKey(category)) {
          categoryWaste[category] = categoryWaste[category]! + price;
        } else {
          categoryWaste[category] = price;
        }
      }
      
      return categoryWaste;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'AnalyticsService.getCategoryWasteAnalysis');
      return {};
    }
  }

  // 保管場所別ロス分析
  static Future<Map<String, double>> getStorageWasteAnalysis() async {
    if (kIsWeb) {
      return await MockDataService.getMockStorageWasteAnalysis();
    }
    
    try {
      final allItems = await DatabaseService.getAllFoodItems();
      final expiredItems = allItems.where((item) => item.daysUntilExpiry < 0);
      
      final Map<String, double> storageWaste = {};
      
      for (final item in expiredItems) {
        final location = item.storageLocation;
        final price = item.price ?? 0.0;
        
        if (storageWaste.containsKey(location)) {
          storageWaste[location] = storageWaste[location]! + price;
        } else {
          storageWaste[location] = price;
        }
      }
      
      return storageWaste;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'AnalyticsService.getStorageWasteAnalysis');
      return {};
    }
  }

  // 月次ロス削減推移
  static Future<Map<String, List<double>>> getMonthlyWasteData() async {
    if (kIsWeb) {
      return await MockDataService.getMockMonthlyWasteData();
    }
    
    try {
      final allItems = await DatabaseService.getAllFoodItems();
      final now = DateTime.now();
      
      // 過去6ヶ月分のデータ
      final Map<String, List<double>> monthlyData = {};
      
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
        
        double monthlyWasted = 0.0;
        double monthlyConsumed = 0.0;
        
        // その月の期限切れ・消費済みアイテムを取得
        final monthItems = allItems.where((item) {
          final itemDate = item.registrationDate;
          return itemDate.year == month.year && itemDate.month == month.month;
        });
        
        for (final item in monthItems) {
          if (item.daysUntilExpiry < 0) {
            monthlyWasted += item.price ?? 0.0;
          } else if (item.isConsumed) {
            monthlyConsumed += item.price ?? 0.0;
          }
        }
        
        monthlyData[monthKey] = [monthlyWasted, monthlyConsumed];
      }
      
      return monthlyData;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'AnalyticsService.getMonthlyWasteData');
      return {};
    }
  }

  // 統計サマリー
  static Future<Map<String, dynamic>> getAnalyticsSummary() async {
    if (kIsWeb) {
      final wasteAnalysis = await MockDataService.calculateMockWasteReduction();
      final categoryAnalysis = await MockDataService.getMockCategoryWasteAnalysis();
      final storageAnalysis = await MockDataService.getMockStorageWasteAnalysis();
      final monthlyData = await MockDataService.getMockMonthlyWasteData();
      final stats = MockDataService.getStatistics();
      
      return {
        'totalItems': stats['totalItems'],
        'expiredCount': stats['expiredCount'],
        'soonCount': stats['soonCount'],
        'freshCount': stats['freshCount'],
        'totalWasted': wasteAnalysis['totalWasted'],
        'totalConsumed': wasteAnalysis['totalConsumed'],
        'totalReduction': wasteAnalysis['totalReduction'],
        'reductionRate': wasteAnalysis['reductionRate'],
        'categoryWaste': categoryAnalysis,
        'storageWaste': storageAnalysis,
        'monthlyData': monthlyData,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
    
    try {
      final allItems = await DatabaseService.getAllFoodItems();
      final stats = await DatabaseService.getStatistics();
      
      final wasteAnalysis = await calculateWasteReduction();
      final categoryAnalysis = await getCategoryWasteAnalysis();
      final storageAnalysis = await getStorageWasteAnalysis();
      final monthlyData = await getMonthlyWasteData();
      
      return {
        'totalItems': stats['totalItems'],
        'expiredCount': stats['expiredCount'],
        'soonCount': stats['soonCount'],
        'freshCount': stats['freshCount'],
        'totalWasted': wasteAnalysis['totalWasted'],
        'totalConsumed': wasteAnalysis['totalConsumed'],
        'totalReduction': wasteAnalysis['totalReduction'],
        'reductionRate': wasteAnalysis['reductionRate'],
        'categoryWaste': categoryAnalysis,
        'storageWaste': storageAnalysis,
        'monthlyData': monthlyData,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'AnalyticsService.getAnalyticsSummary');
      return {
        'totalItems': 0,
        'expiredCount': 0,
        'soonCount': 0,
        'freshCount': 0,
        'totalWasted': 0.0,
        'totalConsumed': 0.0,
        'totalReduction': 0.0,
        'reductionRate': 0.0,
        'categoryWaste': {},
        'storageWaste': {},
        'monthlyData': {},
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
}
