import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';
import '../models/shopping_item.dart';
import 'shopping_item_edit_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingProvider>().loadShoppingItems('default_list');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [],
      ),
      body: Consumer<ShoppingProvider>(
        builder: (context, provider, child) {
          // 全チェックされていれば削除ボタンを表示
          final hasPurchasedItems = provider.currentItems.any((item) => item.isPurchased);

          return Column(
            children: [
              // チェック済みアイテム削除ボタン
              if (hasPurchasedItems)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showClearListConfirmation(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('チェック済みアイテムを削除'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              // アイテムリスト
              Expanded(
                child: provider.currentItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '買い物リストが空です',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '＋ボタンでアイテムを追加してください',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        cacheExtent: 150,
                        itemCount: provider.currentItems.length,
                        itemBuilder: (context, index) {
                          if (index >= provider.currentItems.length) return null;
                          return RepaintBoundary(
                            key: ValueKey('shopping_item_${provider.currentItems[index].id}'),
                            child: _buildShoppingItemCard(provider.currentItems[index]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShoppingItemCard(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: item.isPurchased,
          onChanged: (bool? value) {
            if (value != null) {
              _toggleItemPurchased(item);
            }
          },
          activeColor: Colors.green,
        ),
        title: Text(
          item.productName,
          style: TextStyle(
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
            color: item.isPurchased ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('数量: ${item.quantity}個'),
            if (item.plannedPurchaseDate != null)
              Text(
                '購入予定: ${item.plannedPurchaseDate!.month}/${item.plannedPurchaseDate!.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 編集ボタン
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editItem(item),
              tooltip: '編集',
            ),
            // 削除ボタン（個別削除用）
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(item),
              tooltip: '削除',
            ),
          ],
        ),
      ),
    );
  }

  void _toggleItemPurchased(ShoppingItem item) async {
    try {
      final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
      await context.read<ShoppingProvider>().updateShoppingItem(updatedItem);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    }
  }

  void _editItem(ShoppingItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingItemEditScreen(
          editingItem: item,
          isEditing: true,
        ),
      ),
    );
    
    if (result == true) {
      // データを再読み込み
      context.read<ShoppingProvider>().loadShoppingItems('default_list');
    }
  }

  void _deleteItem(ShoppingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text('${item.productName}を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await context.read<ShoppingProvider>().deleteShoppingItem(item.id);
        
        // 削除後にデータを再読み込み
        await context.read<ShoppingProvider>().loadShoppingItems('default_list');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アイテムを削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  void _showClearListConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('チェックしたアイテムをすべて削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final provider = context.read<ShoppingProvider>();
        final purchasedItems = provider.currentItems.where((item) => item.isPurchased);
        
        for (final item in purchasedItems) {
          await provider.deleteShoppingItem(item.id);
        }
        
        // 削除後にデータを再読み込み
        await provider.loadShoppingItems('default_list');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('チェックしたアイテムを削除しました')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  void _showAddItemDialog() {
    final TextEditingController _itemNameController = TextEditingController();
    final TextEditingController _quantityController = TextEditingController(text: '1');
    DateTime? _selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('アイテムを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: '商品名',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: '数量',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // 購入予定日
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                            : '購入予定日を選択',
                        style: TextStyle(
                          color: _selectedDate != null ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_itemNameController.text.isNotEmpty) {
                  try {
                    final quantity = int.tryParse(_quantityController.text) ?? 1;
                    await context.read<ShoppingProvider>().addShoppingItem(
                      _itemNameController.text,
                      quantity: quantity,
                      plannedPurchaseDate: _selectedDate,
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('アイテムの追加に失敗しました: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }
}
