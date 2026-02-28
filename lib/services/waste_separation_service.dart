import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/waste_separation.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class WasteSeparationService {
  static List<WasteSeparationRule> _mockRules = [];
  static List<RegionSettings> _mockRegions = [];
  static List<WasteSeparationHistory> _mockHistory = [];

  // 初期化
  static void initializeMockData() {
    if (_mockRules.isNotEmpty) return;

    // モックゴミ分別ルール
    _mockRules = [
      WasteSeparationRule(
        id: 'rule_1',
        itemName: 'ペットボトル',
        categories: [WasteCategory.recyclable],
        keywords: ['ペットボトル', 'ボトル', 'プラスチック'],
        description: 'キャップを外して洗浄してから出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_2',
        itemName: '新聞紙',
        categories: [WasteCategory.recyclable],
        keywords: ['新聞', '紙', '新聞紙'],
        description: 'ひもで束ねて出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_3',
        itemName: '生ゴミ',
        categories: [WasteCategory.burnable],
        keywords: ['生ゴミ', '食べ物', '食品', '残飯'],
        description: '水気を切って出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_4',
        itemName: '電池',
        categories: [WasteCategory.hazardous],
        keywords: ['電池', 'バッテリー'],
        description: '専用の回収ボックスに出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_5',
        itemName: 'ガラス瓶',
        categories: [WasteCategory.recyclable],
        keywords: ['瓶', 'ガラス', 'ビン'],
        description: 'キャップを外して洗浄してから出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_6',
        itemName: 'プラスチック容器',
        categories: [WasteCategory.unburnable],
        keywords: ['プラスチック', '容器', 'トレー'],
        description: '洗浄してから出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_7',
        itemName: '衣類',
        categories: [WasteCategory.recyclable],
        keywords: ['衣類', '服', '布'],
        description: '清潔な状態で出す',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WasteSeparationRule(
        id: 'rule_8',
        itemName: '家具',
        categories: [WasteCategory.oversized],
        keywords: ['家具', 'テーブル', '椅子', 'ベッド'],
        description: '事前に粗大ゴミ処理券を購入する',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];

    // モック地域設定
    _mockRegions = [
      RegionSettings(
        id: 'region_1',
        name: '東京都世田谷区',
        prefecture: '東京都',
        city: '世田谷区',
        categoryNames: {
          WasteCategory.burnable: '可燃ゴミ',
          WasteCategory.unburnable: '不燃ゴミ',
          WasteCategory.recyclable: '資源ゴミ',
          WasteCategory.hazardous: '有害ゴミ',
          WasteCategory.oversized: '粗大ゴミ',
          WasteCategory.food: '食品ゴミ',
          WasteCategory.other: 'その他',
        },
        collectionDays: {
          WasteCategory.burnable: '月・木曜日',
          WasteCategory.unburnable: '第2・第4土曜日',
          WasteCategory.recyclable: '火・金曜日',
          WasteCategory.hazardous: '第3土曜日',
          WasteCategory.oversized: '事前予約',
          WasteCategory.food: '月・木曜日',
          WasteCategory.other: '第2土曜日',
        },
        notes: {
          WasteCategory.burnable: ['45L以下の袋で出す', '水気を切る'],
          WasteCategory.unburnable: ['透明・半透明の袋で出す'],
          WasteCategory.recyclable: ['種類別に分けて出す', '洗浄してから出す'],
          WasteCategory.hazardous: ['専用の袋で出す', '破損に注意'],
          WasteCategory.oversized: ['事前申し込みが必要', '処理券を貼付'],
          WasteCategory.food: ['生ゴミと一緒に出す'],
          WasteCategory.other: ['問い合わせが必要'],
        },
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      RegionSettings(
        id: 'region_2',
        name: '大阪府大阪市',
        prefecture: '大阪府',
        city: '大阪市',
        categoryNames: {
          WasteCategory.burnable: '普通ごみ',
          WasteCategory.unburnable: 'プラスチックごみ',
          WasteCategory.recyclable: '資源ごみ',
          WasteCategory.hazardous: '有害ごみ',
          WasteCategory.oversized: '粗大ごみ',
          WasteCategory.food: '生ごみ',
          WasteCategory.other: 'その他',
        },
        collectionDays: {
          WasteCategory.burnable: '週2回',
          WasteCategory.unburnable: '週1回',
          WasteCategory.recyclable: '週1回',
          WasteCategory.hazardous: '月1回',
          WasteCategory.oversized: '事前予約',
          WasteCategory.food: '週2回',
          WasteCategory.other: '問い合わせ',
        },
        notes: {
          WasteCategory.burnable: ['指定袋で出す', '水気を切る'],
          WasteCategory.unburnable: ['青色の袋で出す'],
          WasteCategory.recyclable: ['黄色の袋で出す'],
          WasteCategory.hazardous: ['赤色の袋で出す'],
          WasteCategory.oversized: ['事前申し込みが必要'],
          WasteCategory.food: ['生ゴミと一緒に出す'],
          WasteCategory.other: ['問い合わせが必要'],
        },
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    // モック履歴データ
    _mockHistory = [
      WasteSeparationHistory(
        id: 'history_1',
        itemName: 'ペットボトル',
        category: WasteCategory.recyclable,
        region: '東京都世田谷区',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isCorrect: true,
      ),
      WasteSeparationHistory(
        id: 'history_2',
        itemName: '新聞紙',
        category: WasteCategory.recyclable,
        region: '東京都世田谷区',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isCorrect: true,
      ),
      WasteSeparationHistory(
        id: 'history_3',
        itemName: '生ゴミ',
        category: WasteCategory.burnable,
        region: '東京都世田谷区',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isCorrect: true,
      ),
    ];
  }

  // ゴミ分別の検索
  static Future<WasteSeparationResult?> searchWasteSeparation(
    String itemName, {
    String? region,
  }) async {
    try {
      initializeMockData();
      
      // 完全一致検索
      var rule = _mockRules.firstWhere(
        (r) => r.itemName.toLowerCase() == itemName.toLowerCase(),
        orElse: () => _mockRules.first,
      );
      
      // 部分一致検索
      if (rule.itemName.toLowerCase() != itemName.toLowerCase()) {
        rule = _mockRules.firstWhere(
          (r) => r.keywords.any((keyword) => 
              itemName.toLowerCase().contains(keyword.toLowerCase())),
          orElse: () => _mockRules.first,
        );
      }
      
      // 地域設定の取得
      RegionSettings? regionSettings;
      if (region != null) {
        regionSettings = _mockRegions.firstWhere(
          (r) => r.name == region,
          orElse: () => _mockRegions.first,
        );
      } else {
        regionSettings = _mockRegions.first;
      }
      
      // 結果の作成
      final result = WasteSeparationResult(
        itemName: itemName,
        category: rule.categories.first,
        region: regionSettings.name,
        description: rule.description,
        collectionDays: [regionSettings.collectionDays[rule.categories.first] ?? '不明'],
        notes: regionSettings.notes[rule.categories.first] ?? [],
        confidence: _calculateConfidence(itemName, rule),
        createdAt: DateTime.now(),
      );
      
      return result;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.searchWasteSeparation');
      return null;
    }
  }

  // 確信度の計算
  static double _calculateConfidence(String itemName, WasteSeparationRule rule) {
    if (rule.itemName.toLowerCase() == itemName.toLowerCase()) {
      return 1.0;
    }
    
    if (rule.keywords.any((keyword) => 
        itemName.toLowerCase().contains(keyword.toLowerCase()))) {
      return 0.8;
    }
    
    return 0.5;
  }

  // 地域設定の取得
  static Future<List<RegionSettings>> getRegionSettings() async {
    initializeMockData();
    return _mockRegions;
  }

  static Future<RegionSettings?> getRegionSettingsById(String regionId) async {
    initializeMockData();
    try {
      return _mockRegions.firstWhere((region) => region.id == regionId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.getRegionSettingsById');
      return null;
    }
  }

  static Future<RegionSettings?> getRegionSettingsByName(String regionName) async {
    initializeMockData();
    try {
      return _mockRegions.firstWhere((region) => region.name == regionName);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.getRegionSettingsByName');
      return null;
    }
  }

  // ゴミ分別ルールの取得
  static Future<List<WasteSeparationRule>> getAllRules() async {
    initializeMockData();
    return _mockRules;
  }

  static Future<List<WasteSeparationRule>> getRulesByCategory(WasteCategory category) async {
    initializeMockData();
    return _mockRules.where((rule) => rule.categories.contains(category)).toList();
  }

  static Future<List<WasteSeparationRule>> getRulesByRegion(String region) async {
    initializeMockData();
    return _mockRules.where((rule) => rule.region == region || rule.region == null).toList();
  }

  // 履歴の管理
  static Future<List<WasteSeparationHistory>> getHistory({String? region}) async {
    initializeMockData();
    if (region != null) {
      return _mockHistory.where((history) => history.region == region).toList();
    }
    return _mockHistory;
  }

  static Future<void> addToHistory(WasteSeparationHistory history) async {
    initializeMockData();
    try {
      _mockHistory.add(history);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.addToHistory');
    }
  }

  static Future<void> updateHistory(WasteSeparationHistory history) async {
    initializeMockData();
    try {
      final index = _mockHistory.indexWhere((h) => h.id == history.id);
      if (index >= 0) {
        _mockHistory[index] = history;
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.updateHistory');
    }
  }

  static Future<void> deleteHistory(String historyId) async {
    initializeMockData();
    try {
      _mockHistory.removeWhere((history) => history.id == historyId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.deleteHistory');
    }
  }

  // 統計情報
  static Future<Map<String, dynamic>> getStatistics({String? region}) async {
    initializeMockData();
    
    final history = region != null 
        ? _mockHistory.where((h) => h.region == region).toList()
        : _mockHistory;
    
    final categoryCount = <WasteCategory, int>{};
    final correctCount = <WasteCategory, int>{};
    
    for (final category in WasteCategory.values) {
      categoryCount[category] = 0;
      correctCount[category] = 0;
    }
    
    for (final h in history) {
      categoryCount[h.category] = (categoryCount[h.category] ?? 0) + 1;
      if (h.isCorrect) {
        correctCount[h.category] = (correctCount[h.category] ?? 0) + 1;
      }
    }
    
    return {
      'totalSearches': history.length,
      'categoryCount': categoryCount.map((key, value) => MapEntry(key.name, value)),
      'correctCount': correctCount.map((key, value) => MapEntry(key.name, value)),
      'accuracyRate': history.isNotEmpty 
          ? history.where((h) => h.isCorrect).length / history.length * 100
          : 0.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // おすすめゴミ分別
  static Future<List<WasteSeparationRule>> getRecommendedRules(String itemName) async {
    initializeMockData();
    
    final recommendations = <WasteSeparationRule>[];
    
    // 完全一致
    final exactMatches = _mockRules.where((rule) => 
        rule.itemName.toLowerCase() == itemName.toLowerCase());
    recommendations.addAll(exactMatches);
    
    // 部分一致
    final partialMatches = _mockRules.where((rule) => 
        rule.keywords.any((keyword) => 
            itemName.toLowerCase().contains(keyword.toLowerCase())));
    recommendations.addAll(partialMatches);
    
    // 重複を除去
    final uniqueRecommendations = <WasteSeparationRule>[];
    final seenIds = <String>{};
    
    for (final rule in recommendations) {
      if (!seenIds.contains(rule.id)) {
        seenIds.add(rule.id);
        uniqueRecommendations.add(rule);
      }
    }
    
    return uniqueRecommendations.take(5).toList();
  }

  // 地域別ゴミカレンダー
  static Future<Map<String, List<String>>> getWasteCalendar(String regionId) async {
    initializeMockData();
    
    final region = _mockRegions.firstWhere(
      (r) => r.id == regionId,
      orElse: () => _mockRegions.first,
    );
    
    final calendar = <String, List<String>>{};
    
    // 曜日別のゴミ収集日をマッピング
    final dayMapping = {
      '月': '月曜日',
      '火': '火曜日',
      '水': '水曜日',
      '木': '木曜日',
      '金': '金曜日',
      '土': '土曜日',
      '日': '日曜日',
    };
    
    for (final entry in region.collectionDays.entries) {
      final days = entry.value.split('・');
      for (final day in days) {
        final cleanDay = day.trim();
        if (dayMapping.containsKey(cleanDay)) {
          final dayKey = dayMapping[cleanDay]!;
          if (!calendar.containsKey(dayKey)) {
            calendar[dayKey] = [];
          }
          calendar[dayKey]!.add(entry.key.displayName);
        }
      }
    }
    
    return calendar;
  }

  // ゴミ分別ルールの学習（フィードバックベース）
  static Future<void> learnFromFeedback(
    String itemName,
    WasteCategory correctCategory,
    String region,
  ) async {
    initializeMockData();
    
    try {
      // 既存のルールを検索
      final existingRule = _mockRules.firstWhere(
        (rule) => rule.itemName.toLowerCase() == itemName.toLowerCase(),
        orElse: () => WasteSeparationRule(
          id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
          itemName: itemName,
          categories: [correctCategory],
          keywords: [itemName],
          region: region,
          description: 'ユーザーフィードバックから学習',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      // ルールの更新
      if (existingRule.categories.contains(correctCategory)) {
        // 既存のルールを更新
        final updatedRule = existingRule.copyWith(
          categories: [correctCategory],
          updatedAt: DateTime.now(),
        );
        
        final index = _mockRules.indexWhere((rule) => rule.id == existingRule.id);
        if (index >= 0) {
          _mockRules[index] = updatedRule;
        }
      } else {
        // 新しいルールを追加
        _mockRules.add(existingRule);
      }
      
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.learnFromFeedback');
    }
  }

  // データのエクスポート
  static Future<Map<String, dynamic>> exportData() async {
    initializeMockData();
    
    return {
      'rules': _mockRules.map((rule) => rule.toJson()).toList(),
      'regions': _mockRegions.map((region) => region.toJson()).toList(),
      'history': _mockHistory.map((history) => history.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // データのインポート
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // ルールのインポート
      if (data.containsKey('rules')) {
        final rules = (data['rules'] as List)
            .map((json) => WasteSeparationRule.fromJson(json))
            .toList();
        _mockRules.addAll(rules);
      }
      
      // 地域設定のインポート
      if (data.containsKey('regions')) {
        final regions = (data['regions'] as List)
            .map((json) => RegionSettings.fromJson(json))
            .toList();
        _mockRegions.addAll(regions);
      }
      
      // 履歴のインポート
      if (data.containsKey('history')) {
        final history = (data['history'] as List)
            .map((json) => WasteSeparationHistory.fromJson(json))
            .toList();
        _mockHistory.addAll(history);
      }
      
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'WasteSeparationService.importData');
    }
  }
}
