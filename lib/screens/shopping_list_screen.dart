import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';

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
          final allPurchased = provider.currentItems.isNotEmpty && 
                              provider.currentItems.every((item) => item.isPurchased);

          return Column(
            children: [
              // 全チェック時の削除ボタン
              if (allPurchased)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: ElevatedButton.icon(
                    onPressed: () => _showClearListConfirmation(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('リストをクリア'),
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
                        const SnackBar(content: Text('アイテムの追加に失敗しました')),
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

  void _showEditItemDialog(ShoppingItem item) {
    final TextEditingController _itemNameController = TextEditingController(text: item.productName);
    final TextEditingController _quantityController = TextEditingController(text: item.quantity.toString());
    DateTime? _selectedDate = item.plannedPurchaseDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('アイテムを編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: '商品名',
                  border: OutlineInputBorder(),
                ),
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
                    initialDate: _selectedDate ?? DateTime.now(),
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
                    final updatedItem = item.copyWith(
                      productName: _itemNameController.text,
                      quantity: quantity,
                      plannedPurchaseDate: _selectedDate,
                    );
                    await context.read<ShoppingProvider>().updateShoppingItem(updatedItem);
                    Navigator.pop(context);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('アイテムの更新に失敗しました')),
                      );
                    }
                  }
                }
              },
              child: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingItemCard(ShoppingItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CheckboxListTile(
        title: Text(
          item.productName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: item.isPurchased ? TextDecoration.lineThrough : null,
            color: item.isPurchased ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数量: ${item.quantity}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (item.plannedPurchaseDate != null)
              Text(
                '購入予定日: ${item.plannedPurchaseDate!.year}/${item.plannedPurchaseDate!.month}/${item.plannedPurchaseDate!.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
        value: item.isPurchased,
        onChanged: (value) {
          context.read<ShoppingProvider>().toggleItemPurchased(item);
        },
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditItemDialog(item),
                padding: const EdgeInsets.all(4),
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () {
                  context.read<ShoppingProvider>().deleteShoppingItem(item.id);
                },
                padding: const EdgeInsets.all(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearListConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('リストクリア'),
        content: const Text('すべてのアイテムが購入済みです。リストをクリアしてもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 全アイテムを削除
              final provider = context.read<ShoppingProvider>();
              for (final item in provider.currentItems) {
                provider.deleteShoppingItem(item.id);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('クリア'),
          ),
        ],
      ),
    );
  }
}
