/// テスト用の新しいダミーデータ
/// 既存のMockDataServiceとは別のデータを使用

import 'package:food_loss_app/models/food_item.dart';
import 'package:food_loss_app/models/shopping_list.dart';
import 'package:food_loss_app/models/shopping_item.dart';
import 'package:food_loss_app/models/recipe.dart';
import 'package:food_loss_app/models/user.dart';
import 'package:food_loss_app/models/family.dart';
import 'package:food_loss_app/models/family_member.dart';
import 'package:food_loss_app/models/product_info.dart';
import 'package:food_loss_app/models/waste_separation.dart';

class TestData {
  // テスト用の食材データ
  static List<FoodItem> getTestFoodItems() {
    return [
      FoodItem(
        id: 'test_food_1',
        name: 'テストトマト',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        quantity: 2,
        storageLocation: '冷蔵庫',
        category: '野菜',
        memo: 'テスト用トマト',
        price: 150.0,
        purchaseStore: 'テストスーパー',
        registrationDate: DateTime.now().subtract(const Duration(days: 2)),
        isConsumed: false,
      ),
      FoodItem(
        id: 'test_food_2',
        name: 'テスト牛乳',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        quantity: 1,
        storageLocation: '冷蔵庫',
        category: '乳製品',
        memo: 'テスト用牛乳',
        price: 200.0,
        purchaseStore: 'テストストア',
        registrationDate: DateTime.now().subtract(const Duration(days: 1)),
        isConsumed: false,
      ),
      FoodItem(
        id: 'test_food_3',
        name: 'テストパン',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        quantity: 3,
        storageLocation: '常温',
        category: '穀物',
        memo: 'テスト用パン',
        price: 100.0,
        purchaseStore: 'テストベーカリー',
        registrationDate: DateTime.now().subtract(const Duration(days: 3)),
        isConsumed: true,
      ),
      FoodItem(
        id: 'test_food_4',
        name: 'テスト卵',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)), // 期限切れ
        quantity: 6,
        storageLocation: '冷蔵庫',
        category: '卵',
        memo: 'テスト用卵（期限切れ）',
        price: 180.0,
        purchaseStore: 'テストスーパー',
        registrationDate: DateTime.now().subtract(const Duration(days: 5)),
        isConsumed: false,
      ),
    ];
  }

  // テスト用の買い物リストデータ
  static List<ShoppingList> getTestShoppingLists() {
    return [
      ShoppingList(
        id: 'test_list_1',
        name: 'テスト買い物リスト1',
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: false,
      ),
      ShoppingList(
        id: 'test_list_2',
        name: 'テスト買い物リスト2',
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
      ),
    ];
  }

  // テスト用の買い物アイテムデータ
  static List<ShoppingItem> getTestShoppingItems() {
    return [
      ShoppingItem(
        id: 'test_item_1',
        listId: 'test_list_1',
        productName: 'テストりんご',
        quantity: 2,
        barcode: '4901085184109',
        isPurchased: false,
        createdDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ShoppingItem(
        id: 'test_item_2',
        listId: 'test_list_1',
        productName: 'テスト人参',
        quantity: 1,
        barcode: '4901085184110',
        isPurchased: true,
        createdDate: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      ShoppingItem(
        id: 'test_item_3',
        listId: 'test_list_2',
        productName: 'テストじゃがいも',
        quantity: 3,
        barcode: '4901085184111',
        isPurchased: false,
        createdDate: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  // テスト用のレシピデータ
  static List<Recipe> getTestRecipes() {
    return [
      Recipe(
        recipeId: 'test_recipe_1',
        title: 'テストカレーライス',
        category: 'カレー',
        area: '日本',
        instructions: 'テスト用カレーライスの作り方。1. 材料を切る。2. 炒める。3. 調味する。',
        ingredients: ['テスト玉ねぎ', 'テスト人参', 'テストじゃがいも', 'テストカレールー'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/52874.jpg',
        cachedDate: DateTime.now(),
      ),
      Recipe(
        recipeId: 'test_recipe_2',
        title: 'Test Tomato Salad',
        category: 'Salad',
        area: 'Italian',
        instructions: 'Test tomato salad recipe. 1. Cut tomatoes. 2. Add vegetables. 3. Mix dressing.',
        ingredients: ['Test Tomato', 'Test Onion', 'Test Cucumber', 'Test Olive Oil'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/52875.jpg',
        cachedDate: DateTime.now(),
      ),
    ];
  }

  // テスト用のユーザーデータ
  static List<User> getTestUsers() {
    return [
      User(
        id: 'test_user_1',
        name: 'テストユーザー1',
        email: 'test1@example.com',
        avatarUrl: 'https://example.com/avatar1.jpg',
        familyIds: ['test_family_1'],
      ),
      User(
        id: 'test_user_2',
        name: 'テストユーザー2',
        email: 'test2@example.com',
        avatarUrl: 'https://example.com/avatar2.jpg',
        familyIds: ['test_family_1'],
      ),
      User(
        id: 'test_user_3',
        name: 'テストユーザー3',
        email: 'test3@example.com',
        avatarUrl: 'https://example.com/avatar3.jpg',
        familyIds: [],
      ),
    ];
  }

  // テスト用のファミリーデータ
  static List<Family> getTestFamilies() {
    return [
      Family(
        id: 'test_family_1',
        name: 'テストファミリー',
        description: 'テスト用のファミリー',
        createdBy: 'test_user_1',
        memberIds: ['test_user_1', 'test_user_2'],
      ),
    ];
  }

  // テスト用のファミリーメンバーデータ
  static List<FamilyMember> getTestFamilyMembers() {
    return [
      FamilyMember(
        id: 'test_member_1',
        familyId: 'test_family_1',
        userId: 'test_user_1',
        userName: 'テストユーザー1',
        userEmail: 'test1@example.com',
        role: 'admin',
      ),
      FamilyMember(
        id: 'test_member_2',
        familyId: 'test_family_1',
        userId: 'test_user_2',
        userName: 'テストユーザー2',
        userEmail: 'test2@example.com',
        role: 'member',
      ),
    ];
  }

  // テスト用の商品情報データ
  static List<ProductInfo> getTestProductInfo() {
    return [
      ProductInfo(
        barcode: '4901085184109',
        productName: 'テストりんご',
        brand: 'テストブランド',
        categories: ['穀物', '米'],
        imageUrl: 'https://example.com/rice.jpg',
        nutriments: {
          'energy-kcal_100g': 130,
          'proteins_100g': 2.5,
          'carbohydrates_100g': 28,
          'fat_100g': 0.3,
        },
        cachedDate: DateTime.now(),
      ),
      ProductInfo(
        barcode: '4901085184110',
        productName: 'Test Carrot',
        brand: 'Test Brand',
        categories: ['Vegetables', 'Root Vegetables'],
        imageUrl: 'https://example.com/carrot.jpg',
        nutriments: {
          'energy-kcal_100g': 41,
          'proteins_100g': 0.9,
          'carbohydrates_100g': 10,
          'fat_100g': 0.2,
        },
        cachedDate: DateTime.now(),
      ),
    ];
  }

  // テスト用のゴミ分別ルールデータ
  static List<WasteSeparationRule> getTestWasteSeparationRules() {
    return [
      WasteSeparationRule(
        id: 'test_rule_1',
        itemName: 'テストトマト',
        category: WasteCategory.burnable,
        description: 'テスト用トマトの分別ルール',
        region: 'テスト地域',
        notes: '燃えるゴミ',
        imageUrl: 'https://example.com/tomato.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WasteSeparationRule(
        id: 'test_rule_2',
        itemName: 'テストペットボトル',
        category: WasteCategory.recyclable,
        description: 'テスト用ペットボトルの分別ルール',
        region: 'テスト地域',
        notes: '資源ゴミ',
        imageUrl: 'https://example.com/bottle.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WasteSeparationRule(
        id: 'test_rule_3',
        itemName: 'テスト電池',
        category: WasteCategory.hazardous,
        description: 'テスト用電池の分別ルール',
        region: 'テスト地域',
        notes: '有害ゴミ',
        imageUrl: 'https://example.com/battery.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // テスト用の地域設定データ
  static List<RegionSettings> getTestRegionSettings() {
    return [
      RegionSettings(
        id: 'test_region_1',
        name: 'テスト市',
        description: 'テスト用の地域設定',
        collectionDays: {
          'burnable': ['月', '木', '土'],
          'unburnable': ['第2火曜日'],
          'recyclable': ['第2火曜日'],
          'hazardous': ['第4火曜日'],
          'oversized': ['第3火曜日'],
        },
        specialRules: 'テスト用の特別ルール',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // テスト用のゴミ分別履歴データ
  static List<WasteSeparationHistory> getTestWasteSeparationHistory() {
    return [
      WasteSeparationHistory(
        id: 'test_history_1',
        itemName: 'テストトマト',
        category: WasteCategory.burnable,
        region: 'テスト市',
        separatedDate: DateTime.now().subtract(const Duration(hours: 2)),
        feedback: '正しく分別できた',
        imageUrl: 'https://example.com/tomato_disposed.jpg',
      ),
      WasteSeparationHistory(
        id: 'test_history_2',
        itemName: 'テストペットボトル',
        category: WasteCategory.recyclable,
        region: 'テスト市',
        separatedDate: DateTime.now().subtract(const Duration(days: 1)),
        feedback: 'キャップを洗浄して分別',
        imageUrl: 'https://example.com/bottle_disposed.jpg',
      ),
    ];
  }
}
