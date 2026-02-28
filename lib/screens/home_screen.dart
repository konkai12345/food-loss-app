import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../widgets/food_item_card.dart';
import 'add_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FoodItem> _foodItems = [];
  List<FoodItem> _filteredItems = [];
  String _selectedCategory = 'すべて';
  String _searchQuery = '';
  bool _isLoading = true;

  final List<String> _categories = [
    'すべて',
    '野菜',
    '肉',
    '魚',
    '乳製品',
    '果物',
    '調味料',
    'その他',
  ];

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await DatabaseService.getAllFoodItems();
      setState(() {
        _foodItems = items;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _foodItems.where((item) {
        // カテゴリフィルター
        final categoryMatch = _selectedCategory == 'すべて' || 
                            item.category == _selectedCategory;
        
        // 検索フィルター
        final searchMatch = _searchQuery.isEmpty ||
                            item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return categoryMatch && searchMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食品ロス削減アプリ'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: '食材を検索...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          
          // カテゴリフィルター
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _applyFilters();
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 食材リスト
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return FoodItemCard(
                            foodItem: item,
                            onTap: () => _showFoodDetail(item),
                            onEdit: () => _editFoodItem(item),
                            onDelete: () => _deleteFoodItem(item),
                            onConsume: () => _markAsConsumed(item),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFoodItem,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'すべて'
                ? '該当する食材がありません'
                : '食材がまだ登録されていません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isEmpty && _selectedCategory == 'すべて') ...[
            const SizedBox(height: 8),
            Text(
              '右下の＋ボタンから食材を追加してください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addFoodItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
    );
    
    if (result == true) {
      _loadFoodItems();
    }
  }

  void _editFoodItem(FoodItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(foodItem: item),
      ),
    );
    
    if (result == true) {
      _loadFoodItems();
    }
  }

  void _deleteFoodItem(FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('${item.name}を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseService.deleteFoodItem(item.id);
                _loadFoodItems();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('削除しました')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('削除に失敗しました: $e')),
                  );
                }
              }
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAsConsumed(FoodItem item) async {
    try {
      await DatabaseService.markAsConsumed(item.id);
      _loadFoodItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name}を消費済みにしました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    }
  }

  void _showFoodDetail(FoodItem item) {
    // TODO: 食材詳細画面を実装
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('賞味期限: ${_formatDate(item.expiryDate)}'),
            Text('数量: ${item.quantity}'),
            Text('保管場所: ${item.storageLocation}'),
            Text('カテゴリ: ${item.category}'),
            if (item.memo != null) Text('メモ: ${item.memo}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // TODO: 通知画面を実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知機能は準備中です')),
    );
  }

  void _showSettings() {
    // TODO: 設定画面を実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('設定機能は準備中です')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
