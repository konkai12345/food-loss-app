import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/meal_db_service.dart';
import '../services/cache_service.dart';
import '../utils/error_handler.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _recipes = [];
  List<Recipe> _expiringSoonRecipes = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRandomRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRandomRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = <Recipe>[];
      
      // ランダムレシピを3つ取得
      for (int i = 0; i < 3; i++) {
        final recipe = await MealDbService.getRandomRecipe();
        if (recipe != null) {
          recipes.add(recipe);
        }
      }

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'RecipeScreen._loadRandomRecipes');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.isEmpty) {
      _loadRandomRecipes();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // キャッシュを確認
      final cachedRecipes = await CacheService.getCachedRecipeSearch(query);
      
      if (cachedRecipes != null) {
        setState(() {
          _recipes = cachedRecipes;
          _isSearching = false;
        });
      } else {
        // 食材名で検索（簡易的に）
        final ingredients = [query];
        final recipes = await MealDbService.searchRecipesByIngredients(ingredients);
        
        // キャッシュに保存
        await CacheService.cacheRecipeSearch(query, recipes);
        
        setState(() {
          _recipes = recipes;
          _isSearching = false;
        });
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'RecipeScreen._searchRecipes');
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _loadRecipesByCategory(String category) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await MealDbService.searchRecipesByCategory(category);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'RecipeScreen._loadRecipesByCategory');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ提案'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 検索バー
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '食材でレシピを検索...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                _searchRecipes(value);
              },
            ),
          ),
          
          // カテゴリフィルター
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('全て', () => _loadRandomRecipes()),
                _buildCategoryChip('Chicken', () => _loadRecipesByCategory('Chicken')),
                _buildCategoryChip('Beef', () => _loadRecipesByCategory('Beef')),
                _buildCategoryChip('Pork', () => _loadRecipesByCategory('Pork')),
                _buildCategoryChip('Fish', () => _loadRecipesByCategory('Fish')),
                _buildCategoryChip('Vegetarian', () => _loadRecipesByCategory('Vegetarian')),
                _buildCategoryChip('Dessert', () => _loadRecipesByCategory('Dessert')),
              ],
            ),
          ),
          
          // レシピリスト
          Expanded(
            child: _isLoading || _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _recipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'レシピが見つかりませんでした',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '別の食材で試してみてください',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recipes[index];
                          return RecipeCard(recipe: recipe);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Colors.green.shade100,
        labelStyle: TextStyle(
          color: Colors.green.shade800,
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 画像
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: recipe.imageUrl != null
                    ? Image.network(
                        recipe.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              
              // レシピ情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (recipe.category != null)
                      Text(
                        recipe.category!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (recipe.area != null)
                      Text(
                        recipe.area!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.ingredients.length} 材料',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 画像
            if (recipe.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant, color: Colors.grey, size: 64),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 基本情報
            if (recipe.category != null || recipe.area != null)
              Row(
                children: [
                  if (recipe.category != null)
                    Chip(
                      label: Text(recipe.category!),
                      backgroundColor: Colors.green.shade100,
                    ),
                  if (recipe.area != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(recipe.area!),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ],
                ],
              ),
            
            const SizedBox(height: 16),
            
            // 材料
            const Text(
              '材料',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            // 作り方
            const Text(
              '作り方',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.instructions,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
