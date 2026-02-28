import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe.dart';
import '../themes/natural_eco_theme.dart';
import '../widgets/natural_eco_components.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeSearchScreenNaturalEco extends StatefulWidget {
  const RecipeSearchScreenNaturalEco({Key? key}) : super(key: key);

  @override
  State<RecipeSearchScreenNaturalEco> createState() => _RecipeSearchScreenNaturalEcoState();
}

class _RecipeSearchScreenNaturalEcoState extends State<RecipeSearchScreenNaturalEco>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _selectedCategory = 'すべて';
  bool _isSearching = false;
  List<Recipe> _searchResults = [];
  List<Recipe> _popularRecipes = [];

  late AnimationController _searchAnimationController;
  late AnimationController _resultsAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _resultsAnimation;

  final List<String> _categories = [
    'すべて', 'Beef', 'Chicken', 'Dessert', 'Lamb', 'Miscellaneous', 
    'Pasta', 'Pork', 'Seafood', 'Side', 'Starter', 'Vegan', 
    'Vegetarian', 'Breakfast', 'Goat'
  ];

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _resultsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _resultsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 人気レシピを読み込み
    _loadPopularRecipes();
    
    // スクロールリスナー
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreRecipes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchAnimationController.dispose();
    _resultsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadPopularRecipes() async {
    try {
      final recipes = await Provider.of<RecipeProvider>(context, listen: false)
          .getPopularRecipes();
      setState(() {
        _popularRecipes = recipes.take(6).toList();
      });
    } catch (e) {
      // エラー処理
    }
  }

  Future<void> _searchRecipes() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });
    _searchAnimationController.forward();

    try {
      final results = await Provider.of<RecipeProvider>(context, listen: false)
          .searchRecipes(_searchController.text.trim());
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      _resultsAnimationController.forward();
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('検索エラーが発生しました'),
            backgroundColor: NaturalEcoTheme.darkGrey,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreRecipes() async {
    // 追加読み込み処理
  }

  @override
  Widget build(BuildContext context) {
    return NaturalEcoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('レシピ検索'),
          backgroundColor: NaturalEcoTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: Column(
          children: [
            // 検索エリア
            Container(
              margin: const EdgeInsets.all(16),
              decoration: NaturalEcoTheme.cardDecoration,
              child: Column(
                children: [
                  // 検索バー
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'レシピを検索...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: AnimatedBuilder(
                        animation: _searchAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _searchAnimation.value,
                            child: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            ),
                          );
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: NaturalEcoTheme.lightGrey,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    onSubmitted: (_) => _searchRecipes(),
                  ),
                  const SizedBox(height: 16),
                  
                  // カテゴリ選択
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _searchRecipes();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                  ? NaturalEcoTheme.primaryGradient
                                  : null,
                              color: isSelected ? null : NaturalEcoTheme.lightGrey,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? NaturalEcoTheme.primaryGreen 
                                    : NaturalEcoTheme.woodBrown.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              category,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: isSelected ? Colors.white : NaturalEcoTheme.darkGrey,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 検索結果
            Expanded(
              child: _isSearching
                  ? const NaturalEcoLoadingIndicator(
                      message: 'レシピを検索中...',
                    )
                  : _searchResults.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '検索結果 (${_searchResults.length}件)',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: NaturalEcoTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _resultsAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (1 - _resultsAnimation.value) * 30),
                                    child: Opacity(
                                      opacity: _resultsAnimation.value,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: _searchResults.length,
                                        itemBuilder: (context, index) {
                                          final recipe = _searchResults[index];
                                          return AnimatedContainer(
                                            duration: Duration(milliseconds: 300 + (index * 50)),
                                            curve: Curves.easeOutCubic,
                                            child: NaturalEcoCard(
                                              key: Key(recipe.recipeId),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // レシピ画像
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: NaturalEcoTheme.lightGrey,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: recipe.imageUrl?.isNotEmpty == true
                                                          ? Image.network(
                                                              recipe.imageUrl!,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  color: NaturalEcoTheme.lightGrey,
                                                                  child: const Icon(
                                                                    Icons.restaurant,
                                                                    color: NaturalEcoTheme.mediumGrey,
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : Container(
                                                              color: NaturalEcoTheme.lightGrey,
                                                              child: const Icon(
                                                                Icons.restaurant,
                                                                color: NaturalEcoTheme.mediumGrey,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          recipe.title,
                                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            NaturalEcoChip(
                                                              label: recipe.category,
                                                              icon: Icons.category,
                                                              backgroundColor: NaturalEcoTheme.skyBlue.withOpacity(0.1),
                                                              textColor: NaturalEcoTheme.skyBlue,
                                                            ),
                                                            if (recipe.area.isNotEmpty) ...[
                                                              const SizedBox(width: 8),
                                                              NaturalEcoChip(
                                                                label: recipe.area,
                                                                icon: Icons.location_on,
                                                                backgroundColor: NaturalEcoTheme.woodBrown.withOpacity(0.1),
                                                                textColor: NaturalEcoTheme.woodBrown,
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          '${recipe.ingredients.length}個の材料',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: NaturalEcoTheme.mediumGrey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : _searchController.text.trim().isNotEmpty
                          ? NaturalEcoEmptyState(
                              title: 'レシピが見つかりませんでした',
                              subtitle: '別のキーワードで検索してみてください',
                              icon: Icons.search_off,
                            )
                          : _popularRecipes.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '人気のレシピ',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: NaturalEcoTheme.primaryGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: GridView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 0.8,
                                        ),
                                        itemCount: _popularRecipes.length,
                                        itemBuilder: (context, index) {
                                          final recipe = _popularRecipes[index];
                                          return NaturalEcoCard(
                                            key: Key(recipe.recipeId),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      color: NaturalEcoTheme.lightGrey,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12),
                                                      child: recipe.imageUrl?.isNotEmpty == true
                                                          ? Image.network(
                                                              recipe.imageUrl!,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  color: NaturalEcoTheme.lightGrey,
                                                                  child: const Icon(
                                                                    Icons.restaurant,
                                                                    color: NaturalEcoTheme.mediumGrey,
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : Container(
                                                              color: NaturalEcoTheme.lightGrey,
                                                              child: const Icon(
                                                                Icons.restaurant,
                                                                color: NaturalEcoTheme.mediumGrey,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  recipe.title,
                                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : NaturalEcoEmptyState(
                                  title: 'レシピを検索してみましょう',
                                  subtitle: '食材名や料理名で検索できます',
                                  icon: Icons.search,
                                ),
            ),
          ],
        ),
      ),
    );
  }
}
