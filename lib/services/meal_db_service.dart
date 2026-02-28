import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/recipe.dart';
import '../utils/error_handler.dart';
import 'mock_data_service.dart';

class MealDbService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration timeout = Duration(seconds: 10); // 30秒→10秒に短縮

  // 日本語対応の食材名マッピング
  static const Map<String, String> _ingredientMapping = {
    'トマト': 'tomato',
    '玉ねぎ': 'onion',
    'にんにく': 'garlic',
    'じゃがいも': 'potato',
    '人参': 'carrot',
    'キャベツ': 'cabbage',
    'きゅうり': 'cucumber',
    '卵': 'egg',
    '鶏肉': 'chicken',
    '豚肉': 'pork',
    '牛肉': 'beef',
    '米': 'rice',
    'パン': 'bread',
    'チーズ': 'cheese',
    '牛乳': 'milk',
    'バター': 'butter',
    '油': 'oil',
    '塩': 'salt',
    '砂糖': 'sugar',
    '醤油': 'soy sauce',
    '味噌': 'miso',
    '酒': 'sake',
    'みりん': 'mirin',
  };

  // 日本語食材を英語に変換
  static List<String> _translateIngredients(List<String> ingredients) {
    return ingredients.map((ingredient) {
      return _ingredientMapping[ingredient.toLowerCase()] ?? ingredient.toLowerCase();
    }).toList();
  }

  // 英語レシピタイトルを日本語に変換（簡易版）
  static String _translateTitle(String englishTitle) {
    final Map<String, String> titleMapping = {
      'tomato': 'トマト',
      'chicken': 'チキン',
      'beef': 'ビーフ',
      'pork': 'ポーク',
      'pasta': 'パスタ',
      'rice': 'ライス',
      'soup': 'スープ',
      'salad': 'サラダ',
      'curry': 'カレー',
      'stir fry': '炒め物',
      'roast': 'ロースト',
      'grilled': 'グリル',
    };

    String translated = englishTitle.toLowerCase();
    titleMapping.forEach((english, japanese) {
      if (translated.contains(english)) {
        translated = translated.replaceAll(english, japanese);
      }
    });

    return translated;
  }

  // 食材名でレシピ検索（日本語対応・リトライ戦略付き）
  static Future<List<Recipe>> searchRecipesByIngredients(List<String> ingredients, {int retryCount = 2}) async {
    if (kIsWeb) {
      return await MockDataService.searchRecipesByIngredients(ingredients);
    }

    // 日本語食材を英語に変換
    final translatedIngredients = _translateIngredients(ingredients);

    for (int i = 0; i < retryCount; i++) {
      try {
        final ingredient = translatedIngredients.join(',');
        final uri = Uri.parse('$baseUrl/filter.php').replace(queryParameters: {
          'i': ingredient,
        });

        final response = await http.get(uri).timeout(timeout);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final meals = json['meals'] as List<dynamic>? ?? [];

          final recipes = <Recipe>[];
          
          for (final meal in meals) {
            final recipe = await getRecipeDetails(meal['idMeal']);
            if (recipe != null) {
              recipes.add(recipe);
            }
          }

          return recipes;
        }
        
        return [];
      } catch (e) {
        if (i == retryCount - 1) {
          AppErrorHandler.handleError(e, StackTrace.current, context: 'MealDbService.searchRecipesByIngredients');
          return [];
        }
        await Future.delayed(Duration(milliseconds: 300 * (i + 1)));
      }
    }
    
    return [];
  }

  // レシピ詳細取得（日本語タイトル変換・リトライ戦略付き）
  static Future<Recipe?> getRecipeDetails(String recipeId, {int retryCount = 2}) async {
    if (kIsWeb) {
      return await MockDataService.getRecipeDetails(recipeId);
    }

    for (int i = 0; i < retryCount; i++) {
      try {
        final uri = Uri.parse('$baseUrl/lookup.php').replace(queryParameters: {
          'i': recipeId,
        });

        final response = await http.get(uri).timeout(timeout);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final meals = json['meals'] as List<dynamic>? ?? [];

          if (meals.isNotEmpty) {
            final meal = meals.first;
            final englishTitle = meal['strMeal'] ?? '';
            final translatedTitle = _translateTitle(englishTitle);
            
            return Recipe(
              recipeId: meal['idMeal'],
              title: translatedTitle.isNotEmpty ? translatedTitle : englishTitle,
              category: meal['strCategory'],
              area: meal['strArea'],
              instructions: meal['strInstructions'] ?? '',
              ingredients: _extractIngredients(meal),
              imageUrl: meal['strMealThumb'],
              cachedDate: DateTime.now(),
            );
          }
        }
        
        return null;
      } catch (e) {
        if (i == retryCount - 1) {
          AppErrorHandler.handleError(e, StackTrace.current, context: 'MealDbService.getRecipeDetails');
          return null;
        }
        await Future.delayed(Duration(milliseconds: 200 * (i + 1)));
      }
    }
    
    return null;
  }

  // カテゴリでレシピ検索（Web版ではモックデータを使用）
  static Future<List<Recipe>> searchRecipesByCategory(String category) async {
    if (kIsWeb) {
      // Web版ではモックデータを使用
      return await MockDataService.searchRecipesByCategory(category);
    }

    try {
      final uri = Uri.parse('$baseUrl/filter.php').replace(queryParameters: {
        'c': category,
      });

      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final meals = json['meals'] as List<dynamic>? ?? [];

        final recipes = <Recipe>[];
        
        for (final meal in meals) {
          final recipe = await getRecipeDetails(meal['idMeal']);
          if (recipe != null) {
            recipes.add(recipe);
          }
        }

        return recipes;
      }
      
      return [];
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MealDbService.searchRecipesByCategory');
      return [];
    }
  }

  // ランダムレシピ取得（Web版ではモックデータを使用）
  static Future<Recipe?> getRandomRecipe() async {
    if (kIsWeb) {
      // Web版ではモックデータを使用
      return await MockDataService.getRandomRecipe();
    }

    try {
      final uri = Uri.parse('$baseUrl/random.php');

      final response = await http.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final meals = json['meals'] as List<dynamic>? ?? [];

        if (meals.isNotEmpty) {
          final meal = meals.first;
          return Recipe(
            recipeId: meal['idMeal'],
            title: meal['strMeal'] ?? '',
            category: meal['strCategory'],
            area: meal['strArea'],
            instructions: meal['strInstructions'] ?? '',
            ingredients: _extractIngredients(meal),
            imageUrl: meal['strMealThumb'],
            cachedDate: DateTime.now(),
          );
        }
      }
      
      return null;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'MealDbService.getRandomRecipe');
      return null;
    }
  }

  // 食材リストを抽出
  static List<String> _extractIngredients(Map<String, dynamic> meal) {
    final ingredients = <String>[];
    
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'] as String?;
      final measure = meal['strMeasure$i'] as String?;
      
      if (ingredient != null && ingredient.isNotEmpty) {
        final ingredientWithMeasure = measure != null && measure.isNotEmpty
            ? '$ingredient ($measure)'
            : ingredient;
        ingredients.add(ingredientWithMeasure);
      }
    }
    
    return ingredients;
  }

  // 日本語に翻訳（簡単な翻訳マップ）
  static String translateToJapanese(String englishText) {
    final translations = {
      'Chicken': '鶏肉',
      'Beef': '牛肉',
      'Pork': '豚肉',
      'Fish': '魚',
      'Rice': '米',
      'Pasta': 'パスタ',
      'Bread': 'パン',
      'Egg': '卵',
      'Milk': '牛乳',
      'Cheese': 'チーズ',
      'Tomato': 'トマト',
      'Onion': '玉ねぎ',
      'Garlic': 'にんにく',
      'Potato': 'じゃがいも',
      'Carrot': '人参',
      'Cabbage': 'キャベツ',
      'Lettuce': 'レタス',
      'Apple': 'りんご',
      'Banana': 'バナナ',
      'Orange': 'オレンジ',
    };

    return translations[englishText] ?? englishText;
  }
}
