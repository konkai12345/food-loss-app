import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/food_provider.dart';
import '../models/food_item.dart';
import '../themes/natural_eco_theme.dart';
import '../widgets/natural_eco_components.dart';
import '../screens/add_food_screen.dart';
import '../screens/shopping_list_screen.dart';
import '../screens/recipe_search_screen.dart';
import '../screens/food_detail_screen.dart';

class HomeScreenNaturalEco extends StatefulWidget {
  const HomeScreenNaturalEco({Key? key}) : super(key: key);

  @override
  State<HomeScreenNaturalEco> createState() => _HomeScreenNaturalEcoState();
}

class _HomeScreenNaturalEcoState extends State<HomeScreenNaturalEco>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // アニメーションを開始
    _fabAnimationController.forward();
    _statsAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NaturalEcoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('食品ロス削減アプリ'),
          backgroundColor: NaturalEcoTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: NaturalEcoTheme.woodBrown.withOpacity(0.3),
          actions: [
            AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // 検索機能
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<FoodProvider>(
          builder: (context, foodProvider, child) {
            final foodItems = foodProvider.foodItems;
            final expiringItems = foodItems
                .where((item) => item.daysUntilExpiry > 0 && item.daysUntilExpiry <= 3)
                .length;
            final expiredItems = foodItems
                .where((item) => item.daysUntilExpiry <= 0)
                .length;

            return RefreshIndicator(
              onRefresh: () async {
                await foodProvider.loadFoodItems();
              },
              color: NaturalEcoTheme.primaryGreen,
              child: Column(
                children: [
                  // 統計カード
                  AnimatedBuilder(
                    animation: _statsAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _statsAnimation.value) * 50),
                        child: Opacity(
                          opacity: _statsAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NaturalEcoStatCard(
                                    title: '総食品数',
                                    value: foodItems.length.toString(),
                                    icon: Icons.inventory_2,
                                    iconColor: NaturalEcoTheme.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: NaturalEcoStatCard(
                                    title: '期限切れ間近',
                                    value: expiringItems.toString(),
                                    icon: Icons.warning,
                                    iconColor: const Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: NaturalEcoStatCard(
                                    title: '期限切れ',
                                    value: expiredItems.toString(),
                                    icon: Icons.error,
                                    iconColor: NaturalEcoTheme.darkGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // 食品リスト
                  Expanded(
                    child: foodItems.isEmpty
                        ? NaturalEcoEmptyState(
                            title: '食品がありません',
                            subtitle: '右下の＋ボタンから食品を追加してください',
                            icon: Icons.no_food,
                            action: NaturalEcoButton(
                              text: '最初の食品を追加',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddFoodScreen(),
                                  ),
                                );
                              },
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              final item = foodItems[index];
                              final isExpiring = item.daysUntilExpiry > 0 && item.daysUntilExpiry <= 3;
                              final isExpired = item.daysUntilExpiry <= 0;

                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300 + (index * 50)),
                                curve: Curves.easeOutCubic,
                                child: NaturalEcoCard(
                                  key: Key(item.id),
                                  isExpiring: isExpiring,
                                  isExpired: isExpired,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FoodDetailScreen(foodItem: item),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          NaturalEcoCategoryIcon(
                                            category: item.category,
                                            size: 32,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    NaturalEcoChip(
                                                      label: item.storageLocation,
                                                      icon: Icons.location_on,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    NaturalEcoChip(
                                                      label: '${item.quantity}${item.unit}',
                                                      icon: Icons.scale,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          NaturalEcoExpiryBadge(
                                            daysUntilExpiry: item.daysUntilExpiry,
                                            isExpired: isExpired,
                                          ),
                                        ],
                                      ),
                                      if (item.memo != null && item.memo!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          item.memo!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: NaturalEcoTheme.mediumGrey,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _fabAnimation.value,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFoodScreen(),
                    ),
                  );
                },
                backgroundColor: NaturalEcoTheme.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 12,
                icon: const Icon(Icons.add),
                label: const Text('食品を追加'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: NaturalEcoTheme.woodBrown.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: NaturalEcoTheme.primaryGreen,
            unselectedItemColor: NaturalEcoTheme.mediumGrey,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: '買い物リスト',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: 'レシピ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: '統計',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  // ホーム（現在の画面）
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShoppingListScreen(),
                    ),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeSearchScreen(),
                    ),
                  );
                  break;
                case 3:
                  // 統計画面（未実装）
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('統計機能は準備中です'),
                      backgroundColor: NaturalEcoTheme.woodBrown,
                    ),
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
