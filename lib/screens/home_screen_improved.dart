import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/food_item.dart';
import '../widgets/food_item_card_animated.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';
import 'food_add_screen.dart';
import 'food_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'notification_history_screen.dart';

class HomeScreenImproved extends StatefulWidget {
  const HomeScreenImproved({super.key});

  @override
  State<HomeScreenImproved> createState() => _HomeScreenImprovedState();
}

class _HomeScreenImprovedState extends State<HomeScreenImproved>
    with TickerProviderStateMixin {
  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'すべて';
  String _selectedStorage = 'すべて';
  String _searchQuery = '';
  late AnimationController _fabAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _fabAnimation;
  int _totalItems = 0;
  int _expiredItems = 0;
  int _expiringSoonItems = 0;

  final List<String> _categories = [
    'すべて', '野菜', '果物', '肉', '魚', '乳製品', '調味料', 'その他'
  ];

  final List<String> _storageLocations = [
    'すべて', '冷蔵庫', '冷凍庫', '常温'
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadFoodItems();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<FoodItem> items;
      
      if (_searchQuery.isNotEmpty) {
        items = await _searchFoodItems(_searchQuery);
      } else if (_selectedCategory != 'すべて') {
        items = await DatabaseService.getFoodItemsByCategory(_selectedCategory);
      } else if (_selectedStorage != 'すべて') {
        items = await DatabaseService.getFoodItemsByStorageLocation(_selectedStorage);
      } else {
        items = await DatabaseService.getAllFoodItems();
      }

      final stats = await DatabaseService.getStatistics();
      
      setState(() {
        _foodItems = items;
        _isLoading = false;
        _totalItems = stats['totalItems'] ?? 0;
        _expiredItems = stats['expiredCount'] ?? 0;
        _expiringSoonItems = stats['soonCount'] ?? 0;
      });

      _listAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        AppErrorHandler.showErrorSnackBar(
          context,
          '食材データの読み込みに失敗しました',
        );
      }
      AppErrorHandler.handleError(e, StackTrace.current, context: 'HomeScreen._loadFoodItems');
    }
  }

  Future<List<FoodItem>> _searchFoodItems(String query) async {
    try {
      final allItems = await DatabaseService.getAllFoodItems();
      return allItems.where((item) {
        return item.name.toLowerCase().contains(query.toLowerCase()) ||
               item.category.toLowerCase().contains(query.toLowerCase()) ||
               item.storageLocation.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'HomeScreen._searchFoodItems');
      rethrow;
    }
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoodAddScreen()),
    );
    
    if (result == true) {
      _loadFoodItems();
      if (mounted) {
        AppErrorHandler.showSuccessSnackBar(context, '食材を追加しました');
      }
    }
  }

  void _navigateToEditScreen(FoodItem foodItem) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEditScreen(foodItem: foodItem),
      ),
    );
    
    if (result == true) {
      _loadFoodItems();
      if (mounted) {
        AppErrorHandler.showSuccessSnackBar(context, '食材を更新しました');
      }
    }
  }

  void _deleteFoodItem(FoodItem foodItem) async {
    try {
      await DatabaseService.deleteFoodItem(foodItem.id);
      _loadFoodItems();
      if (mounted) {
        AppErrorHandler.showSuccessSnackBar(context, '食材を削除しました');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showErrorSnackBar(context, '食材の削除に失敗しました');
      }
      AppErrorHandler.handleError(e, StackTrace.current, context: 'HomeScreen._deleteFoodItem');
    }
  }

  void _markAsConsumed(FoodItem foodItem) async {
    try {
      await DatabaseService.markAsConsumed(foodItem.id);
      _loadFoodItems();
      if (mounted) {
        AppErrorHandler.showSuccessSnackBar(context, '食材を消費済みにしました');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showErrorSnackBar(context, '食材の更新に失敗しました');
      }
      AppErrorHandler.handleError(e, StackTrace.current, context: 'HomeScreen._markAsConsumed');
    }
  }

  void _showDeleteConfirmation(FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('${foodItem.name}を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFoodItem(foodItem);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食品ロス削減アプリ'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 統計情報
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '在庫状況',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('総数', _totalItems.toString(), Colors.white),
                    const SizedBox(width: 12),
                    _buildStatCard('期限切れ', _expiredItems.toString(), Colors.red.shade100),
                    const SizedBox(width: 12),
                    _buildStatCard('期限近い', _expiringSoonItems.toString(), Colors.orange.shade100),
                  ],
                ),
              ],
            ),
          ),
          
          // 検索バー
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '食材を検索...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadFoodItems();
              },
            ),
          ),
          
          // フィルター
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'カテゴリ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _selectedStorage = 'すべて';
                      });
                      _loadFoodItems();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStorage,
                    decoration: InputDecoration(
                      labelText: '保管場所',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _storageLocations.map((location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStorage = value!;
                        _selectedCategory = 'すべて';
                      });
                      _loadFoodItems();
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 食材リスト
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _foodItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '食材がありません',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '右下の＋ボタンから追加してください',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _listAnimationController,
                        builder: (context, child) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _foodItems.length,
                            itemBuilder: (context, index) {
                              final foodItem = _foodItems[index];
                              final animation = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _listAnimationController,
                                  curve: Interval(
                                    (index / _foodItems.length) * 0.8,
                                    0.8 + (index / _foodItems.length) * 0.2,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );
                              
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: FoodItemCardAnimated(
                                    foodItem: foodItem,
                                    onTap: () => _navigateToEditScreen(foodItem),
                                    onEdit: () => _navigateToEditScreen(foodItem),
                                    onDelete: () => _showDeleteConfirmation(foodItem),
                                    onConsume: () => _markAsConsumed(foodItem),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToAddScreen,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('追加'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color == Colors.white ? Colors.green.shade800 : Colors.green.shade800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color == Colors.white ? Colors.green.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
