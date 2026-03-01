import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';
import 'food_item_add_screen.dart';
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
    'すべて', '野菜', '果物', '肉', '魚', '乳製品', '飲料', 'お菓子', '加工食品', 'パン・穀物', '調味料', 'その他'
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
      MaterialPageRoute(builder: (context) => const FoodItemAddScreen()),
    );
    
    if (result == true) {
      _loadFoodItems();
    }
  }

  Widget _buildFoodItemCard(FoodItem foodItem) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _getCategoryBackgroundColor(foodItem.category),
      child: InkWell(
        onTap: () => _showDeleteConfirmation(foodItem),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildCategoryIcon(foodItem.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          foodItem.storageLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 横並び3要素：数量・消費期限・消費ボタン（大きく）
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 数量（大きく）
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200, width: 1.5),
                        ),
                        child: Text(
                          '${foodItem.quantity}個',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 消費期限（大きく）
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getExpiryColor(foodItem.expiryDate),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getExpiryText(foodItem.expiryDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 消費ボタン（大きく）
                    SizedBox(
                      width: 65,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => _consumeFoodItem(foodItem),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '消費',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
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

  // 食材を消費する（削除）
  Future<void> _consumeFoodItem(FoodItem foodItem) async {
    try {
      // 確認ダイアログ
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('確認'),
          content: Text('${foodItem.name}を消費済みとして削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('消費する'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // データベースから削除
        await DatabaseService.deleteFoodItem(foodItem.id);
        
        // リストを再読み込み
        await _loadFoodItems();
        
        // 成功メッセージ
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${foodItem.name}を消費しました'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: const Text('在庫管理'),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '在庫状況',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleStatCard('総数', _totalItems.toString(), Colors.blue.shade50),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSimpleStatCard('期限切れ', _expiredItems.toString(), Colors.red.shade50),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSimpleStatCard('期限近い', _expiringSoonItems.toString(), Colors.orange.shade50),
                    ),
                  ],
                ),
              ],
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
                    : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      cacheExtent: 200,
                      itemCount: _foodItems.length,
                      itemBuilder: (context, index) {
                        if (index >= _foodItems.length) return null;
                        return RepaintBoundary(
                          key: ValueKey('food_item_${_foodItems[index].id}'),
                          child: _buildFoodItemCard(_foodItems[index]),
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

  // カテゴリに応じた背景色を取得
  Color _getCategoryBackgroundColor(String category) {
    switch (category) {
      case '野菜':
        return Colors.green.withOpacity(0.05); // 透明度を0.05に調整
      case '果物':
        return Colors.orange.withOpacity(0.05); // 透明度を0.05に調整
      case '肉':
        return Colors.brown.withOpacity(0.05); // 透明度を0.05に調整
      case '魚':
        return Colors.blue.withOpacity(0.05); // 透明度を0.05に調整
      case '乳製品':
        return Colors.brown.shade300.withOpacity(0.05); // 透明度を0.05に調整
      case '飲料':
        return Colors.cyan.withOpacity(0.05); // 透明度を0.05に調整
      case 'お菓子':
        return Colors.pink.withOpacity(0.05); // 透明度を0.05に調整
      case '加工食品':
        return Colors.purple.withOpacity(0.05); // 透明度を0.05に調整
      case 'パン・穀物':
        return Colors.amber.withOpacity(0.05); // 透明度を0.05に調整
      case '調味料':
        return Colors.deepOrange.withOpacity(0.05); // 透明度を0.05に調整
      default:
        return Colors.grey.withOpacity(0.05); // 透明度を0.05に調整
    }
  }

  // 期限に応じた色を取得
  Color _getExpiryColor(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    if (expiryDate.isBefore(now)) {
      return Colors.red; // 期限切れ
    } else if (difference.inDays <= 7) {
      return Colors.orange; // 期限近い（7日以内）
    } else {
      return Colors.green; // まだ余裕あり
    }
  }

  // 期限に応じたテキストを取得
  String _getExpiryText(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    if (expiryDate.isBefore(now)) {
      return '期限切れ';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays}日';
    } else {
      return '${difference.inDays}日';
    }
  }

  // カテゴリに応じた色を取得
  Color _getCategoryColor(String category) {
    switch (category) {
      case '野菜':
        return Colors.green;
      case '果物':
        return Colors.red;
      case '肉':
        return Colors.brown;
      case '魚':
        return Colors.blue;
      case '乳製品':
        return Colors.orange;
      case '飲料':
        return Colors.cyan;
      case 'お菓子':
        return Colors.pink;
      case '加工食品':
        return Colors.purple;
      case 'パン・穀物':
        return Colors.amber;
      case '調味料':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  // カテゴリアイコンを構築
  Widget _buildCategoryIcon(String category) {
    IconData iconData;
    Color iconColor;
    
    switch (category) {
      case '野菜':
        iconData = Icons.eco; // Grassの代わりにEco - 草・野菜のイメージ
        iconColor = Colors.green;
        break;
      case '果物':
        iconData = Icons.apple; // りんご - 果物のイメージ
        iconColor = Colors.orange;
        break;
      case '肉':
        iconData = Icons.lunch_dining; // Yakitoriの代わりにランチ - 肉のイメージ
        iconColor = Colors.brown;
        break;
      case '魚':
        iconData = Icons.set_meal; // Set Meal - 魚料理のイメージ
        iconColor = Colors.blue;
        break;
      case '乳製品':
        iconData = Icons.egg; // Egg - 卵・乳製品のイメージ
        iconColor = Colors.brown.shade300;
        break;
      case '飲料':
        iconData = Icons.local_drink; // Water Fullの代わりに飲み物 - 飲料のイメージ
        iconColor = Colors.cyan;
        break;
      case 'お菓子':
        iconData = Icons.cake; // Cake - ケーキ・お菓子のイメージ
        iconColor = Colors.pink;
        break;
      case '加工食品':
        iconData = Icons.dinner_dining; // Skillet Cooktopの代わりにディナー - 加工食品のイメージ
        iconColor = Colors.purple;
        break;
      case 'パン・穀物':
        iconData = Icons.bakery_dining; // Bakery Dining - パン・穀物のイメージ
        iconColor = Colors.amber;
        break;
      case '調味料':
        iconData = Icons.restaurant; // Chef Hatの代わりにレストラン - 調味料のイメージ
        iconColor = Colors.deepOrange;
        break;
      default:
        iconData = Icons.fastfood; // Fork Spoonの代わりにファストフード - その他のイメージ
        iconColor = Colors.grey;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05), // 透明度を0.05に調整
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  // シンプルな統計カード
  Widget _buildSimpleStatCard(String label, String value, Color color) {
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
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
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
