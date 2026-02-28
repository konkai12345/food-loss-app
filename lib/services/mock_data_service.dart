import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../models/product_info.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';

class MockDataService {
  static List<FoodItem> _mockFoodItems = [];
  static List<ShoppingList> _mockShoppingLists = [];
  static List<ShoppingItem> _mockShoppingItems = [];
  static List<ProductInfo> _mockProductInfo = [];
  static List<Recipe> _mockRecipes = [];
  static List<User> _mockUsers = [];
  static List<Family> _mockFamilies = [];
  static List<FamilyMember> _mockFamilyMembers = [];
  static List<Map<String, dynamic>> _mockSharedData = [];

  // 初期化
  static void initializeMockData() {
    if (_mockFoodItems.isNotEmpty) return;

    // モード食材データ
    _mockFoodItems = [
      FoodItem(
        id: '1',
        name: 'トマト',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        quantity: 3,
        storageLocation: '冷蔵庫',
        category: '野菜',
        memo: 'サラダ用',
        price: 200.0,
        purchaseStore: 'スーパーA',
        registrationDate: DateTime.now().subtract(const Duration(days: 7)),
        isConsumed: false,
      ),
      FoodItem(
        id: '2',
        name: '牛乳',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '乳製品',
        memo: '朝食に',
        price: 150.0,
        purchaseStore: 'スーパーB',
        registrationDate: DateTime.now().subtract(const Duration(days: 5)),
        isConsumed: false,
      ),
      FoodItem(
        id: '3',
        name: '鶏肉',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '肉',
        memo: '夕食用',
        price: 800.0,
        purchaseStore: '肉屋',
        registrationDate: DateTime.now().subtract(const Duration(days: 3)),
        isConsumed: false,
      ),
      FoodItem(
        id: '4',
        name: 'パン',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        quantity: 1,
        storageLocation: '常温',
        category: 'その他',
        memo: '朝食用',
        price: 100.0,
        purchaseStore: 'パン屋',
        registrationDate: DateTime.now().subtract(const Duration(days: 2)),
        isConsumed: false,
      ),
      FoodItem(
        id: '5',
        name: 'りんご',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        quantity: 5,
        storageLocation: '常温',
        category: '果物',
        memo: '期限切れ',
        price: 300.0,
        purchaseStore: '果物屋',
        registrationDate: DateTime.now().subtract(const Duration(days: 10)),
        isConsumed: false,
      ),
    ];

    // モード買い物リストデータ
    _mockShoppingLists = [
      ShoppingList(
        id: '1',
        name: '今週の買い物',
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: false,
      ),
      ShoppingList(
        id: '2',
        name: '週末の買い物',
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
        isCompleted: false,
      ),
    ];

    // モード買い物アイテムデータ
    _mockShoppingItems = [
      ShoppingItem(
        id: '1',
        listId: '1',
        productName: 'ヨーグルト',
        quantity: 2,
        barcode: '4900000000010',
        isPurchased: false,
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ShoppingItem(
        id: '2',
        listId: '1',
        productName: 'バナナ',
        quantity: 6,
        barcode: '4900000000204',
        isPurchased: true,
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ShoppingItem(
        id: '3',
        listId: '2',
        productName: 'りんご',
        quantity: 3,
        barcode: '4900000000304',
        isPurchased: false,
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    // モード商品情報データ
    _mockProductInfo = [
      ProductInfo(
        barcode: '4900000000010',
        productName: 'ヨーグルト',
        brand: '明治',
        categories: ['乳製品', 'ヨーグルト'],
        imageUrl: 'https://example.com/yogurt.jpg',
        nutriments: {
          'calories': 60,
          'protein': 3.5,
          'fat': 2.0,
          'carbohydrates': 4.7,
        },
        cachedDate: DateTime.now(),
      ),
      ProductInfo(
        barcode: '4900000000204',
        productName: 'バナナ',
        brand: 'ドール',
        categories: ['果物', 'バナナ'],
        imageUrl: 'https://example.com/banana.jpg',
        nutriments: {
          'calories': 89,
          'protein': 1.1,
          'fat': 0.3,
          'carbohydrates': 22.8,
        },
        cachedDate: DateTime.now(),
      ),
      ProductInfo(
        barcode: '4900000304',
        productName: 'りんご',
        brand: '不明',
        categories: ['果物', 'りんご'],
        imageUrl: 'https://example.com/apple.jpg',
        nutriments: {
          'calories': 52,
          'protein': 0.3,
          'fat': 0.2,
          'carbohydrates': 13.8,
        },
        cachedDate: DateTime.now(),
      ),
    ];

    // モードレシピデータ
    _mockRecipes = [
      Recipe(
        recipeId: '52874',
        title: 'Chicken Fajitas',
        category: 'Chicken',
        area: 'Mexican',
        instructions: '1. Prepare the chicken and vegetables.\n2. Heat a large skillet over medium-high heat.\n3. Cook the chicken until golden brown.\n4. Add vegetables and cook until tender.\n5. Serve with warm tortillas.',
        ingredients: ['Chicken breast', 'Bell peppers', 'Onions', 'Tortillas', 'Sour cream', 'Cheese'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/583c468d96f43851d60e50e6d4e6a9a3.jpg',
        cachedDate: DateTime.now(),
      ),
      Recipe(
        recipeId: '52772',
        title: 'Spaghetti Bolognese',
        category: 'Pasta',
        area: 'Italian',
        instructions: '1. Cook spaghetti according to package directions.\n2. In a large saucepan, cook ground beef until browned.\n3. Add onion and garlic, cook until soft.\n4. Add tomatoes and simmer for 30 minutes.\n5. Serve with spaghetti and parmesan cheese.',
        ingredients: ['Spaghetti', 'Ground beef', 'Tomatoes', 'Onion', 'Garlic', 'Parmesan cheese'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/utskpsxsrqrvrvhsqohvvykuwjucpqld/meal-1.jpg',
        cachedDate: DateTime.now(),
      ),
      Recipe(
        recipeId: '52959',
        title: 'Beef and Broccoli Stir Fry',
        category: 'Beef',
        area: 'Chinese',
        instructions: '1. Heat oil in a large skillet or wok over high heat.\n2. Add beef and stir-fry until browned.\n3. Add broccoli and stir-fry for 3-4 minutes.\n4. Add sauce and toss to combine.\n5. Serve over rice.',
        ingredients: ['Beef', 'Broccoli', 'Soy sauce', 'Ginger', 'Garlic', 'Rice'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/wyrppptcpuecxeexqkqgqyvqvljzx/meal-1.jpg',
        cachedDate: DateTime.now(),
      ),
    ];

    // モードユーザーデータ
    _mockUsers = [
      User(
        id: 'user_1',
        name: '山田太郎',
        email: 'yamada@example.com',
        avatarUrl: 'https://example.com/avatar1.jpg',
        familyIds: ['family_1'],
      ),
      User(
        id: 'user_2',
        name: '山田花子',
        email: 'hanako@example.com',
        avatarUrl: 'https://example.com/avatar2.jpg',
        familyIds: ['family_1'],
      ),
      User(
        id: 'user_3',
        name: '山田次郎',
        email: 'jiro@example.com',
        avatarUrl: 'https://example.com/avatar3.jpg',
        familyIds: [],
      ),
    ];

    // モードファミリーデータ
    _mockFamilies = [
      Family(
        id: 'family_1',
        name: '山田家',
        description: '食品ロス削減に取り組む家族',
        createdBy: 'user_1',
        memberIds: ['user_1', 'user_2'],
      ),
    ];

    // モードファミリーメンバー
    _mockFamilyMembers = [
      FamilyMember(
        familyId: 'family_1',
        userId: 'user_1',
        userName: '山田太郎',
        userEmail: 'yamada@example.com',
        role: 'admin',
      ),
      FamilyMember(
        familyId: 'family_1',
        userId: 'user_2',
        userName: '山田花子',
        userEmail: 'hanako@example.com',
        role: 'member',
      ),
    ];
  }

  // ユーザー関連
  static Future<User?> getUser(String userId) async {
    initializeMockData();
    try {
      return _mockUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.getUser');
      return null;
    }
  }

  static Future<List<User>> getAllUsers() async {
    initializeMockData();
    return _mockUsers;
  }

  static Future<User> saveUser(User user) async {
    initializeMockData();
    try {
      final existingIndex = _mockUsers.indexWhere((u) => u.id == user.id);
      if (existingIndex >= 0) {
        _mockUsers[existingIndex] = user;
      } else {
        _mockUsers.add(user);
      }
      return user;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.saveUser');
      rethrow;
    }
  }

  static Future<User> updateUser(User user) async {
    initializeMockData();
    try {
      final index = _mockUsers.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        _mockUsers[index] = user;
      }
      return user;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.updateUser');
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    initializeMockData();
    try {
      _mockUsers.removeWhere((user) => user.id == userId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.deleteUser');
    }
  }

  // ファミリー関連
  static Future<Family?> getFamily(String familyId) async {
    initializeMockData();
    try {
      return _mockFamilies.firstWhere((family) => family.id == familyId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.getFamily');
      return null;
    }
  }

  static Future<List<Family>> getAllFamilies() async {
    initializeMockData();
    return _mockFamilies;
  }

  static Future<Family> saveFamily(Family family) async {
    initializeMockData();
    try {
      final existingIndex = _mockFamilies.indexWhere((f) => f.id == family.id);
      if (existingIndex >= 0) {
        _mockFamilies[existingIndex] = family;
      } else {
        _mockFamilies.add(family);
      }
      return family;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.saveFamily');
      rethrow;
    }
  }

  static Future<Family> updateFamily(Family family) async {
    initializeMockData();
    try {
      final index = _mockFamilies.indexWhere((f) => f.id == family.id);
      if (index >= 0) {
        _mockFamilies[index] = family;
      }
      return family;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.updateFamily');
      rethrow;
    }
  }

  static Future<void> deleteFamily(String familyId) async {
    initializeMockData();
    try {
      _mockFamilies.removeWhere((family) => family.id == familyId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.deleteFamily');
    }
  }

  // ファミリーメンバー関連
  static Future<List<FamilyMember>> getFamilyMembers(String familyId) async {
    initializeMockData();
    return _mockFamilyMembers.where((member) => member.familyId == familyId).toList();
  }

  static Future<FamilyMember> saveFamilyMember(FamilyMember member) async {
    initializeMockData();
    try {
      final existingIndex = _mockFamilyMembers.indexWhere((m) => m.id == member.id);
      if (existingIndex >= 0) {
        _mockFamilyMembers[existingIndex] = member;
      } else {
        _mockFamilyMembers.add(member);
      }
      return member;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.saveFamilyMember');
      rethrow;
    }
  }

  static Future<FamilyMember> updateFamilyMember(FamilyMember member) async {
    initializeMockData();
    try {
      final index = _mockFamilyMembers.indexWhere((m) => m.id == member.id);
      if (index >= 0) {
        _mockFamilyMembers[index] = member;
      }
      return member;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.updateFamilyMember');
      rethrow;
    }
  }

  static Future<void> deleteFamilyMember(String familyId, String userId) async {
    initializeMockData();
    try {
      _mockFamilyMembers.removeWhere((member) => member.familyId == familyId && member.userId == userId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.deleteFamilyMember');
    }
  }

  // 共有データ関連
  static Future<List<Map<String, dynamic>>> getSharedData(String familyId) async {
    initializeMockData();
    return _mockSharedData.where((data) => data['familyId'] == familyId).toList();
  }

  static Future<void> saveSharedData(Map<String, dynamic> sharedData) async {
    initializeMockData();
    try {
      _mockSharedData.add(sharedData);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.saveSharedData');
    }
  }

  // 食材データの追加・更新・削除
  static Future<void> addFoodItem(FoodItem item) async {
    initializeMockData();
    try {
      _mockFoodItems.add(item);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.addFoodItem');
    }
  }

  static Future<void> updateFoodItem(FoodItem item) async {
    initializeMockData();
    try {
      final index = _mockFoodItems.indexWhere((i) => i.id == item.id);
      if (index >= 0) {
        _mockFoodItems[index] = item;
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.updateFoodItem');
    }
  }

  static Future<void> updateShoppingList(ShoppingList list) async {
    initializeMockData();
    try {
      final index = _mockShoppingLists.indexWhere((l) => l.id == list.id);
      if (index >= 0) {
        _mockShoppingLists[index] = list;
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.updateShoppingList');
    }
  }

  static Future<void> deleteShoppingList(String listId) async {
    initializeMockData();
    try {
      _mockShoppingLists.removeWhere((list) => list.id == listId);
      _mockShoppingItems.removeWhere((item) => item.listId == listId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.deleteShoppingList');
    }
  }

  // 買い物アイテムの取得・追加・更新・削除
  static Future<List<ShoppingItem>> getShoppingItems(String listId) async {
    initializeMockData();
    return _mockShoppingItems.where((item) => item.listId == listId).toList();
  }

  static Future<String> addShoppingItem(ShoppingItem item) async {
    initializeMockData();
    try {
      final existingIndex = _mockShoppingItems.indexWhere((i) => i.id == item.id);
      if (existingIndex >= 0) {
        _mockShoppingItems[existingIndex] = item;
      } else {
        _mockShoppingItems.add(item);
      }
      return item.id;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.addShoppingItem');
      return item.id;
    }
  }

  static Future<void> deleteShoppingItem(String itemId) async {
    initializeMockData();
    try {
      _mockShoppingItems.removeWhere((item) => item.id == itemId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.deleteShoppingItem');
    }
  }

  // 既存のメソッド
  static Future<List<FoodItem>> getAllFoodItems() async {
    initializeMockData();
    return _mockFoodItems;
  }

  static List<ShoppingList> getMockShoppingLists() {
    initializeMockData();
    return _mockShoppingLists;
  }

  static List<ShoppingItem> getMockShoppingItems() {
    initializeMockData();
    return _mockShoppingItems;
  }

  static List<ProductInfo> getMockProductInfo() {
    initializeMockData();
    return _mockProductInfo;
  }

  static List<Recipe> getMockRecipes() {
    initializeMockData();
    return _mockRecipes;
  }

  static Future<ProductInfo?> getProductByBarcode(String barcode) async {
    initializeMockData();
    try {
      return _mockProductInfo.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.getProductByBarcode');
      return null;
    }
  }

  static Future<List<ProductInfo>> searchProductsByName(String name) async {
    initializeMockData();
    try {
      return _mockProductInfo
          .where((product) => product.productName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Recipe?> getRecipeDetails(String recipeId) async {
    initializeMockData();
    try {
      return _mockRecipes.firstWhere((recipe) => recipe.recipeId == recipeId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.getRecipeDetails');
      return null;
    }
  }

  static Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients) async {
    initializeMockData();
    try {
      final results = _mockRecipes
          .where((recipe) => recipe.ingredients.any((ingredient) =>
              ingredients.any((ing) => ingredient.toLowerCase().contains(ing.toLowerCase()))));
      return results.toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Recipe>> searchRecipesByCategory(String category) async {
    initializeMockData();
    try {
      return _mockRecipes
          .where((recipe) => recipe.category?.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Recipe?> getRandomRecipe() async {
    initializeMockData();
    try {
      if (_mockRecipes.isNotEmpty) {
        final randomIndex = DateTime.now().millisecond % _mockRecipes.length;
        return _mockRecipes[randomIndex];
      }
      return null;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MockDataService.getRandomRecipe');
      return null;
    }
  }

  static Map<String, int> getStatistics() {
    initializeMockData();
    return {
      'totalItems': _mockFoodItems.length,
      'expiredCount': _mockFoodItems.where((item) => item.daysUntilExpiry < 0).length,
      'soonCount': _mockFoodItems.where((item) => item.daysUntilExpiry > 0 && item.daysUntilExpiry <= 3).length,
      'freshCount': _mockFoodItems.where((item) => item.daysUntilExpiry > 3).length,
    };
  }

  // ロス削減量計算（モックデータ用）
  static Map<String, double> calculateMockWasteReduction() {
    initializeMockData();
    
    double totalWasted = 0.0;
    double totalConsumed = 0.0;
    
    // 価格をモックデータに追加
    final pricedItems = _mockFoodItems.map((item) {
      return item.copyWith(
        price: _getMockPrice(item.category),
      );
    });
    
    // 破棄された食材（期限切れ）の合計金額
    final expiredItems = pricedItems.where((item) => item.daysUntilExpiry < 0);
    for (final item in expiredItems) {
      totalWasted += item.price ?? 0.0;
    }
    
    // 消費済み食材の合計金額
    final consumedItems = pricedItems.where((item) => item.isConsumed);
    for (final item in consumedItems) {
      totalConsumed += item.price ?? 0.0;
    }
    
    return {
      'totalWasted': totalWasted,
      'totalConsumed': totalConsumed,
      'totalReduction': totalConsumed - totalWasted,
      'reductionRate': totalConsumed > 0 ? ((totalConsumed - totalWasted) / totalConsumed) * 100 : 0.0,
    };
  }

  // カテゴリ別ロス分析（モックデータ用）
  static Map<String, double> getMockCategoryWasteAnalysis() {
    initializeMockData();
    
    final expiredItems = _mockFoodItems.where((item) => item.daysUntilExpiry < 0);
    final pricedItems = expiredItems.map((item) => 
      item.copyWith(price: _getMockPrice(item.category))
    );
    
    final Map<String, double> categoryWaste = {};
    
    for (final item in pricedItems) {
      final category = item.category;
      final price = item.price ?? 0.0;
      
      if (categoryWaste.containsKey(category)) {
        categoryWaste[category] = categoryWaste[category]! + price;
      } else {
        categoryWaste[category] = price;
      }
    }
    
    return categoryWaste;
  }

  // 保管場所別ロス分析（モックデータ用）
  static Map<String, double> getMockStorageWasteAnalysis() {
    initializeMockData();
    
    final expiredItems = _mockFoodItems.where((item) => item.daysUntilExpiry < 0);
    final pricedItems = expiredItems.map((item) => 
      item.copyWith(price: _getMockPrice(item.category))
    );
    
    final Map<String, double> storageWaste = {};
    
    for (final item in pricedItems) {
      final location = item.storageLocation;
      final price = item.price ?? 0.0;
      
      if (storageWaste.containsKey(location)) {
        storageWaste[location] = storageWaste[location]! + price;
      } else {
        storageWaste[location] = price;
      }
    }
    
    return storageWaste;
  }

  // 月次ロス削減推移（モックデータ用）
  static Map<String, List<double>> getMockMonthlyWasteData() {
    initializeMockData();
    
    final now = DateTime.now();
    final Map<String, List<double>> monthlyData = {};
    
    // 過去6ヶ月分のモックデータ生成
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      
      // モデータを生成
      final monthlyWasted = (i + 1) * 1500.0 + (i * 300.0);
      final monthlyConsumed = (i + 1) * 2500.0 + (i * 500.0);
      
      monthlyData[monthKey] = [monthlyWasted, monthlyConsumed];
    }
    
    return monthlyData;
  }

  // 価格をモックデータとして生成
  static double _getMockPrice(String category) {
    final prices = {
      '野菜': 200.0,
      '果物': 300.0,
      '肉': 800.0,
      '魚': 600.0,
      '乳製品': 150.0,
      '調味料': 100.0,
      'その他': 50.0,
    };
    return prices[category] ?? 100.0;
  }
}
