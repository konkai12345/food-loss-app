import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_provider.dart';
import 'barcode_scanner_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final TextEditingController _listNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingProvider>().loadShoppingLists();
    });
  }

  @override
  void dispose() {
    _listNameController.dispose();
    super.dispose();
  }

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しい買い物リスト'),
        content: TextField(
          controller: _listNameController,
          decoration: const InputDecoration(
            labelText: 'リスト名',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_listNameController.text.isNotEmpty) {
                try {
                  await context.read<ShoppingProvider>().createShoppingList(_listNameController.text);
                  Navigator.pop(context);
                  _listNameController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('リストの作成に失敗しました')),
                  );
                }
              }
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final TextEditingController _itemNameController = TextEditingController();
    final TextEditingController _quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('アイテムの追加に失敗しました')),
                  );
                }
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
              );
              
              if (result != null && context.mounted) {
                try {
                  await context.read<ShoppingProvider>().addShoppingItem(
                    result['productName'],
                    barcode: result['barcode'],
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('商品の追加に失敗しました')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Consumer<ShoppingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.shoppingLists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.shoppingLists.isEmpty) {
            return Center(
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
                    '買い物リストがありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '右下のボタンから新しいリストを作成してください',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.shoppingLists.length,
            itemBuilder: (context, index) {
              final list = provider.shoppingLists[index];
              return Card(
                child: ListTile(
                  title: Text(list.name),
                  subtitle: Text('作成日: ${list.createdDate.year}/${list.createdDate.month}/${list.createdDate.day}'),
                  trailing: list.isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle_outlined),
                  onTap: () async {
                    await provider.selectShoppingList(list);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShoppingItemsScreen(shoppingList: list),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ShoppingItemsScreen extends StatelessWidget {
  final ShoppingList shoppingList;

  const ShoppingItemsScreen({super.key, required this.shoppingList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ShoppingProvider>(
        builder: (context, provider, child) {
          if (provider.currentList?.id != shoppingList.id) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.getStatistics();
          
          return Column(
            children: [
              // 統計情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.green.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('合計', stats['total'].toString()),
                    _buildStatItem('購入済み', stats['purchased'].toString()),
                    _buildStatItem('残り', stats['remaining'].toString()),
                  ],
                ),
              ),
              
              // アイテムリスト
              Expanded(
                child: provider.currentItems.isEmpty
                    ? const Center(
                        child: Text('アイテムがありません'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.currentItems.length,
                        itemBuilder: (context, index) {
                          final item = provider.currentItems[index];
                          return CheckboxListTile(
                            title: Text(item.productName),
                            subtitle: item.quantity > 1
                                ? Text('数量: ${item.quantity}')
                                : null,
                            value: item.isPurchased,
                            onChanged: (value) {
                              provider.toggleItemPurchased(item);
                            },
                            secondary: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                provider.deleteShoppingItem(item.id);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              final provider = context.read<ShoppingProvider>();
              if (provider.currentList?.id == shoppingList.id) {
                // アイテム追加ダイアログを表示
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('アイテムを追加'),
                    content: const TextField(
                      decoration: InputDecoration(
                        labelText: '商品名',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: アイテム追加処理
                        },
                        child: const Text('追加'),
                      ),
                    ],
                  ),
                );
              }
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'clear',
            onPressed: () {
              final provider = context.read<ShoppingProvider>();
              if (provider.currentList?.id == shoppingList.id) {
                provider.clearPurchasedItems();
              }
            },
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            child: const Icon(Icons.clear_all),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }
}
