import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/inventory_service.dart';
import '../themes/natural_eco_theme_fixed.dart';
import '../widgets/natural_eco_components.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<FoodItem> _inventoryItems = [];
  List<FoodItem> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'すべて';
  String _sortBy = '賞味期限';

  @override
  void initState() {
    super.initState();
    _loadInventoryItems();
  }

  Future<void> _loadInventoryItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await InventoryService.getInventoryStatus();
      setState(() {
        _inventoryItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('在庫データの読み込みに失敗しました: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredItems = _inventoryItems.where((item) {
        // カテゴリフィルタ
        final categoryMatch = _selectedCategory == 'すべて' || item.category == _selectedCategory;
        
        // 検索フィルタ
        final searchMatch = _searchQuery.isEmpty || 
            item.name.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return categoryMatch && searchMatch;
      }).toList();

      // 並び替え
      switch (_sortBy) {
        case '賞味期限':
          _filteredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
          break;
        case '名前':
          _filteredItems.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'カテゴリ':
          _filteredItems.sort((a, b) => a.category.compareTo(b.category));
          break;
        case '追加日':
          _filteredItems.sort((a, b) => a.registrationDate.compareTo(b.registrationDate));
          break;
      }
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        onItemAdded: (item) {
          setState(() {
            _inventoryItems.add(item);
            _applyFilters();
          });
        },
      ),
    );
  }

  void _showItemDetails(FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailsDialog(
        item: item,
        onItemUpdated: (updatedItem) {
          setState(() {
            final index = _inventoryItems.indexWhere((i) => i.id == updatedItem.id);
            if (index != -1) {
              _inventoryItems[index] = updatedItem;
              _applyFilters();
            }
          });
        },
        onItemDeleted: (itemId) {
          setState(() {
            _inventoryItems.removeWhere((item) => item.id == itemId);
            _applyFilters();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('在庫管理'),
        backgroundColor: NaturalEcoThemeFixed.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventoryItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 検索とフィルター
                _buildSearchAndFilters(),
                
                // 在庫リスト
                Expanded(
                  child: _buildInventoryList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: NaturalEcoThemeFixed.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 検索バー
          TextField(
            decoration: InputDecoration(
              hintText: '食材を検索...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: NaturalEcoThemeFixed.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: NaturalEcoThemeFixed.primaryGreen),
              ),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          
          // フィルター行
          Row(
            children: [
              // カテゴリフィルター
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
                  items: ['すべて', '野菜', '果物', '肉類', '魚介類', '乳製品', '調味料', 'その他']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    _selectedCategory = value!;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // 並び替え
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: '並び替え',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['賞味期限', '名前', 'カテゴリ', '追加日']
                      .map((sort) => DropdownMenuItem(
                            value: sort,
                            child: Text(sort),
                          ))
                      .toList(),
                  onChanged: (value) {
                    _sortBy = value!;
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: NaturalEcoThemeFixed.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              '在庫がありません',
              style: TextStyle(
                fontSize: 18,
                color: NaturalEcoThemeFixed.mediumGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '右下の＋ボタンから食材を追加してください',
              style: TextStyle(
                fontSize: 14,
                color: NaturalEcoThemeFixed.mediumGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return InventoryItemCard(
          item: item,
          onTap: () => _showItemDetails(item),
        );
      },
    );
  }
}

class InventoryItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const InventoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = item.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 3;
    final isExpired = daysUntilExpiry < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // カテゴリアイコン
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(item.category),
                  color: _getCategoryColor(item.category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // 食材情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity}個',
                      style: TextStyle(
                        fontSize: 14,
                        color: NaturalEcoThemeFixed.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 期限情報
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired 
                          ? Colors.red.withOpacity(0.1)
                          : isExpiringSoon
                              ? Colors.orange.withOpacity(0.1)
                              : NaturalEcoThemeFixed.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isExpired 
                          ? '期限切れ'
                          : isExpiringSoon
                              ? 'あと${daysUntilExpiry}日'
                              : 'あと${daysUntilExpiry}日',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired 
                            ? Colors.red
                            : isExpiringSoon
                                ? Colors.orange
                                : NaturalEcoThemeFixed.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.expiryDate.month}/${item.expiryDate.day}',
                    style: TextStyle(
                      fontSize: 12,
                      color: NaturalEcoThemeFixed.mediumGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '野菜':
        return Colors.green;
      case '果物':
        return Colors.orange;
      case '肉類':
        return Colors.red;
      case '魚介類':
        return Colors.blue;
      case '乳製品':
        return Colors.purple;
      case '調味料':
        return Colors.brown;
      default:
        return NaturalEcoThemeFixed.mediumGrey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '野菜':
        return Icons.eco;
      case '果物':
        return Icons.apple;
      case '肉類':
        return Icons.lunch_dining;
      case '魚介類':
        return Icons.set_meal;
      case '乳製品':
        return Icons.egg;
      case '調味料':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }
}

class AddItemDialog extends StatefulWidget {
  final Function(FoodItem) onItemAdded;

  const AddItemDialog({super.key, required this.onItemAdded});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedCategory = '野菜';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  String _selectedUnit = '個';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('食材を追加'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '食材名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '食材名を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'カテゴリ',
                        border: OutlineInputBorder(),
                      ),
                      items: ['野菜', '果物', '肉類', '魚介類', '乳製品', '調味料', 'その他']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: '数量',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '数量を入力してください';
                        }
                        if (double.tryParse(value) == null) {
                          return '有効な数字を入力してください';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: '単位',
                        border: OutlineInputBorder(),
                      ),
                      items: ['個', 'g', 'kg', 'ml', 'L', '本', '袋']
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '賞味期限',
                          border: OutlineInputBorder(),
                        ),
                        child: Text('${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newItem = FoodItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _nameController.text,
                category: _selectedCategory,
                quantity: int.parse(_quantityController.text),
                expiryDate: _selectedDate,
                registrationDate: DateTime.now(),
                storageLocation: '冷蔵庫',
              );
              widget.onItemAdded(newItem);
              Navigator.of(context).pop();
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}

class ItemDetailsDialog extends StatelessWidget {
  final FoodItem item;
  final Function(FoodItem) onItemUpdated;
  final Function(String) onItemDeleted;

  const ItemDetailsDialog({
    super.key,
    required this.item,
    required this.onItemUpdated,
    required this.onItemDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = item.expiryDate.difference(DateTime.now()).inDays;
    final isExpired = daysUntilExpiry < 0;

    return AlertDialog(
      title: Text(item.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('カテゴリ: ${item.category}'),
          Text('数量: ${item.quantity}個'),
          Text('賞味期限: ${item.expiryDate.year}/${item.expiryDate.month}/${item.expiryDate.day}'),
          Text(
            '状態: ${isExpired ? "期限切れ" : "あと${daysUntilExpiry}日"}',
            style: TextStyle(
              color: isExpired ? Colors.red : NaturalEcoThemeFixed.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('追加日: ${item.registrationDate.year}/${item.registrationDate.month}/${item.registrationDate.day}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        TextButton(
          onPressed: () {
            // 消費記録
            onItemDeleted(item.id);
            Navigator.of(context).pop();
          },
          child: const Text('消費した'),
        ),
        TextButton(
          onPressed: () {
            onItemDeleted(item.id);
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('削除'),
        ),
      ],
    );
  }
}
