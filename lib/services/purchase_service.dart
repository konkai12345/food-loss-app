import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../services/mock_data_service.dart';
import '../services/qr_code_service.dart';
import '../utils/error_handler.dart';

class PurchaseService {
  // 購入データの取得
  static Future<List<FoodItem>> getPurchaseData() async {
    if (kIsWeb) {
      return MockDataService.getAllFoodItems();
    }
    
    try {
      return await DatabaseService.getAllFoodItems();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.getPurchaseData');
      return [];
    }
  }

  // 購入分析の取得
  static Future<Map<String, dynamic>> getPurchaseAnalysis() async {
    try {
      final items = await getPurchaseData();
      
      // 購入済みアイテム（価格があるもの）
      final purchasedItems = items.where((item) => item.price != null && item.price! > 0).toList();
      
      // 月別購入分析
      final Map<String, List<Map<String, dynamic>>> monthlyPurchases = {};
      for (final item in purchasedItems) {
        final monthKey = '${item.registrationDate.year}-${item.registrationDate.month.toString().padLeft(2, '0')}';
        
        if (!monthlyPurchases.containsKey(monthKey)) {
          monthlyPurchases[monthKey] = [];
        }
        
        monthlyPurchases[monthKey]!.add({
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'category': item.category,
          'purchaseStore': item.purchaseStore,
          'purchaseDate': item.registrationDate.toIso8601String(),
          'expiryDate': item.expiryDate.toIso8601String(),
          'storageLocation': item.storageLocation,
          'isConsumed': item.isConsumed,
        });
      }

      // カテゴリ別購入分析
      final Map<String, double> categoryPurchases = {};
      for (final item in purchasedItems) {
        final category = item.category;
        final price = item.price!;
        categoryPurchases[category] = (categoryPurchases[category] ?? 0) + price;
      }

      // 店舗別購入分析
      final Map<String, double> storePurchases = {};
      for (final item in purchasedItems) {
        final store = item.purchaseStore ?? '不明';
        final price = item.price!;
        storePurchases[store] = (storePurchases[store] ?? 0) + price;
      }

      // 保管場所別購入分析
      final Map<String, double> storagePurchases = {};
      for (final item in purchasedItems) {
        final location = item.storageLocation;
        final price = item.price!;
        storagePurchases[location] = (storagePurchases[location] ?? 0) + price;
      }

      // 総合購入金額
      final totalPurchaseAmount = purchasedItems.fold<double>(0.0, (sum, item) => sum + item.price!);

      return {
        'totalItems': purchasedItems.length,
        'totalAmount': totalPurchaseAmount,
        'averagePrice': purchasedItems.isNotEmpty ? totalPurchaseAmount / purchasedItems.length : 0.0,
        'monthlyPurchases': monthlyPurchases,
        'categoryPurchases': categoryPurchases,
        'storePurchases': storePurchases,
        'storagePurchases': storagePurchases,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.getPurchaseAnalysis');
      return {
        'totalItems': 0,
        'totalAmount': 0.0,
        'averagePrice': 0.0,
        'monthlyPurchases': {},
        'categoryPurchases': {},
        'storePurchases': {},
        'storagePurchases': {},
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // 購入レポートの生成
  static Future<Map<String, dynamic>> generatePurchaseReport() async {
    try {
      final analysis = await getPurchaseAnalysis();
      final items = await getPurchaseData();
      
      // 購入済みアイテム
      final purchasedItems = items.where((item) => item.price != null && item.price! > 0).toList();
      
      // 購入履歴（月次）
      final monthlyData = analysis['monthlyPurchases'] as Map<String, List<Map<String, dynamic>>>;
      final monthlyHistory = monthlyData.entries.map((entry) {
        final month = entry.key;
        final purchases = entry.value;
        final monthTotal = purchases.fold<double>(0.0, (sum, item) => sum + item['price']);
        
        return {
          'month': month,
          'totalAmount': monthTotal,
          'itemCount': purchases.length,
          'averagePrice': purchases.isNotEmpty ? monthTotal / purchases.length : 0.0,
          'items': purchases,
        };
      }).toList();

      // カテゴリ別分析
      final categoryData = analysis['categoryPurchases'] as Map<String, double>;
      final categoryAnalysis = categoryData.entries.map((entry) => {
        'category': entry.key,
        'amount': entry.value,
        'percentage': analysis['totalAmount'] > 0 ? (entry.value / analysis['totalAmount']) * 100 : 0.0,
      }).toList();

      // 店舗別分析
      final storeData = analysis['storePurchases'] as Map<String, double>;
      final storeAnalysis = storeData.entries.map((entry) => {
        'store': entry.key,
        'amount': entry.value,
        'percentage': analysis['totalAmount'] > 0 ? (entry.value / analysis['totalAmount']) * 100 : 0.0,
      }).toList();

      return {
        'reportDate': DateTime.now().toIso8601String(),
        'summary': analysis,
        'monthlyHistory': monthlyHistory,
        'categoryAnalysis': categoryAnalysis,
        'storeAnalysis': storeAnalysis,
        'purchasedItems': purchasedItems.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'category': item.category,
          'purchaseStore': item.purchaseStore,
          'purchaseDate': item.registrationDate.toIso8601String(),
          'expiryDate': item.expiryDate.toIso8601String(),
          'storageLocation': item.storageLocation,
          'isConsumed': item.isConsumed,
        }).toList(),
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.generatePurchaseReport');
      return {
        'reportDate': DateTime.now().toIso8601String(),
        'summary': {},
        'monthlyHistory': [],
        'categoryAnalysis': [],
        'storeAnalysis': [],
        'purchasedItems': [],
      };
    }
  }

  // 購入管理用QRコードの生成
  static Future<String> generatePurchaseQRCode() async {
    try {
      final items = await getPurchaseData();
      return await QRCodeService.generatePurchaseQRCode(items);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.generatePurchaseQRCode');
      rethrow;
    }
  }

  // 月次購入データの取得
  static Future<Map<String, dynamic>> getMonthlyPurchaseData(String yearMonth) async {
    try {
      final analysis = await getPurchaseAnalysis();
      final monthlyPurchases = analysis['monthlyPurchases'] as Map<String, dynamic>? ?? {};
      
      if (monthlyPurchases.isEmpty || !monthlyPurchases.containsKey(yearMonth)) {
        return {
          'month': yearMonth,
          'totalAmount': 0.0,
          'itemCount': 0,
          'averagePrice': 0.0,
          'items': [],
        };
      }

      final purchases = monthlyPurchases[yearMonth]!;
      final totalAmount = purchases.fold<double>(0.0, (sum, item) => sum + (item['price'] as double));
      
      return {
        'month': yearMonth,
        'totalAmount': totalAmount,
        'itemCount': purchases.length,
        'averagePrice': purchases.isNotEmpty ? totalAmount / purchases.length : 0.0,
        'items': purchases,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.getMonthlyPurchaseData');
      return {
        'month': yearMonth,
        'totalAmount': 0.0,
        'itemCount': 0,
        'averagePrice': 0.0,
        'items': [],
      };
    }
  }

  // 購入予算の計算
  static Future<Map<String, double>> calculatePurchaseForecast(int months) async {
    try {
      final analysis = await getPurchaseAnalysis();
      final monthlyPurchases = analysis['monthlyPurchases'] as Map<String, dynamic>? ?? {};
      
      if (monthlyPurchases.isEmpty) {
        return {
          'forecastAmount': 0.0,
          'averageMonthlyAmount': 0.0,
          'confidence': 0.0,
        };
      }

      // 過去3ヶ月の平均を計算
      final now = DateTime.now();
      final recentMonths = <String>[];
      
      for (int i = 0; i < 3; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
        if (monthlyPurchases.containsKey(monthKey)) {
          recentMonths.add(monthKey);
        }
      }

      if (recentMonths.isEmpty) {
        return {
          'forecastAmount': 0.0,
          'averageMonthlyAmount': 0.0,
          'confidence': 0.0,
        };
      }

      double totalAmount = 0.0;
      for (final month in recentMonths) {
        final purchases = monthlyPurchases[month]!;
        totalAmount += purchases.fold<double>(0.0, (sum, item) => sum + (item['price'] as double));
      }

      final averageMonthlyAmount = totalAmount / recentMonths.length;
      final forecastAmount = averageMonthlyAmount * months;
      
      return {
        'forecastAmount': forecastAmount,
        'averageMonthlyAmount': averageMonthlyAmount,
        'confidence': recentMonths.length >= 3 ? 0.8 : 0.5,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.calculatePurchaseForecast');
      return {
        'forecastAmount': 0.0,
        'averageMonthlyAmount': 0.0,
        'confidence': 0.0,
      };
    }
  }

  // 購入最適化の提案
  static Future<List<Map<String, dynamic>>> getPurchaseOptimizationSuggestions() async {
    try {
      final analysis = await getPurchaseAnalysis();
      final suggestions = <Map<String, dynamic>>[];

      // 高価カテゴリの提案
      final categoryPurchases = analysis['categoryPurchases'] as Map<String, double>? ?? {};
      final totalAmount = analysis['totalAmount'] as double;
      
      final highValueCategories = categoryPurchases.entries
          .where((entry) => entry.value > totalAmount * 0.3) // 30%以上を高価とみなす
          .map((entry) => entry.key)
          .toList();

      if (highValueCategories.isNotEmpty) {
        suggestions.add({
          'type': 'high_value_categories',
          'priority': 'medium',
          'title': '高価カテゴリの見直し',
          'description': '${highValueCategories.join(', ')}の購入が多めです。予算の見直しを検討してください。',
          'categories': highValueCategories,
          'action': 'review_budget',
        });
      }

      // 店舗の集中度分析
      final storePurchases = analysis['storePurchases'] as Map<String, double>? ?? {};
      if (storePurchases.isEmpty) {
        suggestions.add({
          'type': 'store_diversification',
          'priority': 'low',
          'title': '店舗の分散化',
          'description': '購入データがありません。複数の店舗を検討してください。',
          'store': '不明',
          'percentage': 0.0,
          'action': 'explore_stores',
        });
      } else {
        final dominantStore = storePurchases.entries.reduce((prev, curr) => 
          prev.value > curr.value ? prev : curr);
        
        final storePercentage = (dominantStore.value / totalAmount) * 100;
        if (storePercentage > 50) {
          suggestions.add({
            'type': 'store_diversification',
            'priority': 'low',
            'title': '店舗の分散化',
            'description': '${dominantStore.key}での購入が${storePercentage.toStringAsFixed(1)}%を占めています。他の店舗も検討してください。',
            'store': dominantStore.key,
            'percentage': storePercentage,
            'action': 'explore_stores',
          });
        }
      }

      // 季在場所の最適化
      final storagePurchases = analysis['storagePurchases'] as Map<String, double>? ?? {};
      final refrigeratedRatio = (storagePurchases['冷蔵庫'] ?? 0) / totalAmount * 100;
      
      if (refrigeratedRatio > 80) {
        suggestions.add({
          'type': 'storage_optimization',
          'priority': 'low',
          'title': '保管場所の最適化',
          'description': '冷蔵庫での購入が${refrigeratedRatio.toStringAsFixed(1)}%です。常温保存可能なアイテムを検討してください。',
          'refrigeratedRatio': refrigeratedRatio,
          'action': 'optimize_storage',
        });
      }

      return suggestions;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.getPurchaseOptimizationSuggestions');
      return [];
    }
  }

  // 購入効率の計算
  static Future<Map<String, double>> calculatePurchaseEfficiency() async {
    try {
      final analysis = await getPurchaseAnalysis();
      final items = await getPurchaseData();
      
      // 購入済みアイテム
      final purchasedItems = items.where((item) => item.price != null && item.price! > 0).toList();
      
      // 消費済みアイテム
      final consumedItems = purchasedItems.where((item) => item.isConsumed).length;
      
      // 破棄されたアイテム（期限切れ）
      final expiredItems = purchasedItems.where((item) => item.daysUntilExpiry < 0).length;
      
      final totalPurchased = purchasedItems.length;
      if (totalPurchased == 0) {
        return {
          'consumptionRate': 0.0,
          'wasteRate': 0.0,
          'efficiencyScore': 0.0,
        };
      }

      final consumptionRate = (consumedItems / totalPurchased) * 100;
      final wasteRate = (expiredItems / totalPurchased) * 100;
      final efficiencyScore = consumptionRate - wasteRate;

      return {
        'consumptionRate': consumptionRate,
        'wasteRate': wasteRate,
        'efficiencyScore': efficiencyScore,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.calculatePurchaseEfficiency');
      return {
        'consumptionRate': 0.0,
        'wasteRate': 0.0,
        'efficiencyScore': 0.0,
      };
    }
  }

  // 購入トレンドの分析
  static Future<Map<String, dynamic>> analyzePurchaseTrends() async {
    try {
      final analysis = await getPurchaseAnalysis();
      final monthlyPurchases = analysis['monthlyPurchases'] as Map<String, dynamic>? ?? {};
      
      if (monthlyPurchases.isEmpty) {
        return {
          'trend': 'stable',
          'growthRate': 0.0,
          'recommendation': 'insufficient_data',
        };
      }

      // 月次データをソート
      final sortedMonths = monthlyPurchases.keys.toList()..sort();
      
      if (sortedMonths.length < 2) {
        return {
          'trend': 'stable',
          'growthRate': 0.0,
          'recommendation': 'insufficient_data',
        };
      }

      // 成長率の計算
      final latestMonth = sortedMonths.last;
      final previousMonth = sortedMonths[sortedMonths.length - 2];
      
      final latestAmount = monthlyPurchases[latestMonth]!.fold<double>(0.0, (sum, item) => sum + (item['price'] as double));
      final previousAmount = monthlyPurchases[previousMonth]!.fold<double>(0.0, (sum, item) => sum + (item['price'] as double));
      
      final growthRate = previousAmount > 0 ? ((latestAmount - previousAmount) / previousAmount) * 100 : 0.0;
      
      String trend;
      String recommendation;
      
      if (growthRate > 10) {
        trend = 'increasing';
        recommendation = 'budget_increase';
      } else if (growthRate < -10) {
        trend = 'decreasing';
        recommendation = 'budget_decrease';
      } else {
        trend = 'stable';
        recommendation = 'maintain_budget';
      }

      return {
        'trend': trend,
        'growthRate': growthRate,
        'recommendation': recommendation,
        'latestMonth': latestMonth,
        'previousMonth': previousMonth,
        'latestAmount': latestAmount,
        'previousAmount': previousAmount,
      };
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'PurchaseService.analyzePurchaseTrends');
      return {
        'trend': 'stable',
        'growthRate': 0.0,
        'recommendation': 'insufficient_data',
      };
    }
  }
}
