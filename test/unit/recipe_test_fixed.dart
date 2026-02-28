import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/recipe.dart';

void main() {
  group('Recipe 単体テスト', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        recipeId: 'test_recipe_1',
        title: 'テストカレーライス',
        category: 'カレー',
        area: '日本',
        instructions: 'テスト用カレーライスの作り方。1. 材料を切る。2. 炒める。3. 調味する。',
        ingredients: ['テスト玉ねぎ', 'テスト人参', 'テストじゃがいも', 'テストカレールー'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/52874.jpg',
        cachedDate: DateTime.now(),
      );
    });

    test('Recipeの基本プロパティが正しく設定される', () {
      expect(testRecipe.recipeId, 'test_recipe_1');
      expect(testRecipe.title, 'テストカレーライス');
      expect(testRecipe.category, 'カレー');
      expect(testRecipe.area, '日本');
      expect(testRecipe.ingredients, isA<List<String>>());
      expect(testRecipe.cachedDate, isA<DateTime>());
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedRecipe = testRecipe.copyWith(
        title: '更新されたレシピ',
        category: '更新されたカテゴリ',
      );

      expect(copiedRecipe.recipeId, testRecipe.recipeId);
      expect(copiedRecipe.title, '更新されたレシピ');
      expect(copiedRecipe.category, '更新されたカテゴリ');
      expect(copiedRecipe.area, testRecipe.area);
      expect(copiedRecipe.ingredients, testRecipe.ingredients);
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testRecipe.toJson();
      
      expect(json['recipeId'], 'test_recipe_1');
      expect(json['title'], 'テストカレーライス');
      expect(json['category'], 'カレー');
      expect(json['area'], '日本');
      expect(json['ingredients'], isA<String>());
      expect(json['cachedDate'], isA<String>());
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'recipeId': 'json_test_recipe',
        'title': 'JSONテストレシピ',
        'category': 'JSONテストカテゴリ',
        'area': 'JSONテスト地域',
        'instructions': 'JSONテスト手順',
        'ingredients': 'JSONテスト材料1,JSONテスト材料2',
        'imageUrl': 'https://example.com/test.jpg',
        'cachedDate': DateTime.now().toIso8601String(),
      };

      final recipe = Recipe.fromJson(json);
      
      expect(recipe.recipeId, 'json_test_recipe');
      expect(recipe.title, 'JSONテストレシピ');
      expect(recipe.category, 'JSONテストカテゴリ');
      expect(recipe.area, 'JSONテスト地域');
      expect(recipe.instructions, 'JSONテスト手順');
      expect(recipe.ingredients, isA<List<String>>());
      expect(recipe.imageUrl, 'https://example.com/test.jpg');
      expect(recipe.cachedDate, isA<DateTime>());
    });

    test('材料リストが正しく処理される', () {
      final json = {
        'recipeId': 'ingredients_test',
        'title': '材料テストレシピ',
        'ingredients': '材料1,材料2,材料3',
        'cachedDate': DateTime.now().toIso8601String(),
      };

      final recipe = Recipe.fromJson(json);
      
      expect(recipe.ingredients.length, 3);
      expect(recipe.ingredients.contains('材料1'), true);
      expect(recipe.ingredients.contains('材料2'), true);
      expect(recipe.ingredients.contains('材料3'), true);
    });

    test('空の材料リストを処理できる', () {
      final json = {
        'recipeId': 'empty_ingredients_test',
        'title': '空材料テストレシピ',
        'ingredients': '',
        'instructions': '',
        'cachedDate': DateTime.now().toIso8601String(),
      };

      final recipe = Recipe.fromJson(json);
      
      expect(recipe.ingredients.isEmpty, true);
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testRecipe.toString();
      expect(result, contains('テストカレーライス'));
      expect(result, contains('test_recipe_1'));
    });

    test('等価性比較が正しく機能する', () {
      final sameRecipe = Recipe(
        recipeId: testRecipe.recipeId,
        title: testRecipe.title,
        category: testRecipe.category,
        area: testRecipe.area,
        instructions: testRecipe.instructions,
        ingredients: testRecipe.ingredients,
        imageUrl: testRecipe.imageUrl,
        cachedDate: testRecipe.cachedDate,
      );

      expect(testRecipe == sameRecipe, true);
      
      final differentRecipe = testRecipe.copyWith(title: '違うタイトル');
      expect(testRecipe == differentRecipe, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameRecipe = Recipe(
        recipeId: testRecipe.recipeId,
        title: testRecipe.title,
        category: testRecipe.category,
        area: testRecipe.area,
        instructions: testRecipe.instructions,
        ingredients: testRecipe.ingredients,
        imageUrl: testRecipe.imageUrl,
        cachedDate: testRecipe.cachedDate,
      );

      expect(testRecipe.hashCode, sameRecipe.hashCode);
    });

    test('キャッシュ日付が正しく設定される', () {
      final now = DateTime.now();
      final recipe = testRecipe.copyWith(cachedDate: now);
      
      expect(recipe.cachedDate, now);
      expect(recipe.cachedDate.isBefore(now.add(const Duration(seconds: 1))), true);
      expect(recipe.cachedDate.isAfter(now.subtract(const Duration(seconds: 1))), true);
    });
  });

  group('Recipe 境界値テスト', () {
    test('空のタイトルでRecipeを作成できる', () {
      final recipe = Recipe(
        recipeId: 'test_empty_title',
        title: '',
        category: 'テストカテゴリ',
        area: 'テスト地域',
        instructions: 'テスト手順',
        ingredients: ['テスト材料'],
        imageUrl: 'https://example.com/test.jpg',
        cachedDate: DateTime.now(),
      );

      expect(recipe.title, '');
    });

    test('空のカテゴリでRecipeを作成できる', () {
      final recipe = Recipe(
        recipeId: 'test_empty_category',
        title: 'テストレシピ',
        category: '',
        area: 'テスト地域',
        instructions: 'テスト手順',
        ingredients: ['テスト材料'],
        imageUrl: 'https://example.com/test.jpg',
        cachedDate: DateTime.now(),
      );

      expect(recipe.category, '');
    });

    test('空の地域でRecipeを作成できる', () {
      final recipe = Recipe(
        recipeId: 'test_empty_area',
        title: 'テストレシピ',
        category: 'テストカテゴリ',
        area: '',
        instructions: 'テスト手順',
        ingredients: ['テスト材料'],
        imageUrl: 'https://example.com/test.jpg',
        cachedDate: DateTime.now(),
      );

      expect(recipe.area, '');
    });

    test('空の手順でRecipeを作成できる', () {
      final recipe = Recipe(
        recipeId: 'test_empty_instructions',
        title: 'テストレシピ',
        category: 'テストカテゴリ',
        area: 'テスト地域',
        instructions: '',
        ingredients: ['テスト材料'],
        imageUrl: 'https://example.com/test.jpg',
        cachedDate: DateTime.now(),
      );

      expect(recipe.instructions, '');
    });

    test('空の材料リストでRecipeを作成できる', () {
      final recipe = Recipe(
        recipeId: 'test_empty_ingredients',
        title: 'テストレシピ',
        category: 'テストカテゴリ',
        area: 'テスト地域',
        instructions: 'テスト手順',
        ingredients: [],
        imageUrl: 'https://example.com/test.jpg',
        cachedDate: DateTime.now(),
      );

      expect(recipe.ingredients.isEmpty, true);
    });

    test('nullのimageUrlでRecipeを作成できる', () {
      final recipe = Recipe(
        recipeId: 'test_null_image',
        title: 'テストレシピ',
        category: 'テストカテゴリ',
        area: 'テスト地域',
        instructions: 'テスト手順',
        ingredients: ['テスト材料'],
        imageUrl: '',
        cachedDate: DateTime.now(),
      );

      expect(recipe.imageUrl, '');
    });
  });

  group('Recipe 機能テスト', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        recipeId: 'test_recipe_1',
        title: 'テストカレーライス',
        category: 'カレー',
        area: '日本',
        instructions: 'テスト用カレーライスの作り方。1. 材料を切る。2. 炒める。3. 調味する。',
        ingredients: ['テスト玉ねぎ', 'テスト人参', 'テストじゃがいも', 'テストカレールー'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/52874.jpg',
        cachedDate: DateTime.now(),
      );
    });

    test('材料の数を正しく取得できる', () {
      expect(testRecipe.ingredients.length, 4);
    });

    test('材料の内容を正しく取得できる', () {
      expect(testRecipe.ingredients.contains('テスト玉ねぎ'), true);
      expect(testRecipe.ingredients.contains('テスト人参'), true);
      expect(testRecipe.ingredients.contains('テストじゃがいも'), true);
      expect(testRecipe.ingredients.contains('テストカレールー'), true);
    });

    test('英語レシピのタイトルを正しく取得できる', () {
      final englishRecipe = Recipe(
        recipeId: 'test_recipe_2',
        title: 'Test Tomato Salad',
        category: 'Salad',
        area: 'Italian',
        instructions: 'Test tomato salad recipe. 1. Cut tomatoes. 2. Add vegetables. 3. Mix dressing.',
        ingredients: ['Test Tomato', 'Test Onion', 'Test Cucumber', 'Test Olive Oil'],
        imageUrl: 'https://www.themealdb.com/images/media/meals/52875.jpg',
        cachedDate: DateTime.now(),
      );
      expect(englishRecipe.title, 'Test Tomato Salad');
      expect(englishRecipe.category, 'Salad');
      expect(englishRecipe.area, 'Italian');
    });

    test('日本語レシピのタイトルを正しく取得できる', () {
      expect(testRecipe.title, 'テストカレーライス');
      expect(testRecipe.category, 'カレー');
      expect(testRecipe.area, '日本');
    });

    test('手順の内容を正しく取得できる', () {
      expect(testRecipe.instructions, contains('テスト用カレーライスの作り方'));
      expect(testRecipe.instructions, contains('1. 材料を切る'));
      expect(testRecipe.instructions, contains('2. 炒める'));
      expect(testRecipe.instructions, contains('3. 調味する'));
    });
  });
}
