import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_provider.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../themes/natural_eco_theme.dart';
import '../widgets/natural_eco_components.dart';
import '../screens/add_shopping_item_screen.dart';

class ShoppingListScreenNaturalEco extends StatefulWidget {
  const ShoppingListScreenNaturalEco({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreenNaturalEco> createState() => _ShoppingListScreenNaturalEcoState();
}

class _ShoppingListScreenNaturalEcoState extends State<ShoppingListScreenNaturalEco>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _listAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // データ読み込みとアニメーション開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingProvider>(context, listen: false).loadShoppingLists();
      _listAnimationController.forward();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _deleteShoppingList(String listId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('この買い物リストを削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: NaturalEcoTheme.darkGrey,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<ShoppingProvider>(context, listen: false)
            .deleteShoppingList(listId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('買い物リストを削除しました'),
                ],
              ),
              backgroundColor: NaturalEcoTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('エラーが発生しました'),
                ],
              ),
              backgroundColor: NaturalEcoTheme.darkGrey,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NaturalEcoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('買い物リスト'),
          backgroundColor: NaturalEcoTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          actions: [
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.white),
              onPressed: () {
                // 並び替え機能
              },
            ),
          ],
        ),
        body: Consumer<ShoppingProvider>(
          builder: (context, shoppingProvider, child) {
            final shoppingLists = shoppingProvider.shoppingLists;

            return RefreshIndicator(
              onRefresh: () async {
                await shoppingProvider.loadShoppingLists();
              },
              color: NaturalEcoTheme.primaryGreen,
              child: shoppingLists.isEmpty
                  ? NaturalEcoEmptyState(
                      title: '買い物リストがありません',
                      subtitle: '右下の＋ボタンから新しいリストを作成してください',
                      icon: Icons.shopping_cart_outlined,
                      action: NaturalEcoButton(
                        text: '最初のリストを作成',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddShoppingItemScreen(),
                            ),
                          );
                        },
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shoppingLists.length,
                      itemBuilder: (context, index) {
                        final list = shoppingLists[index];
                        final itemCount = list.items.length;
                        final purchasedCount = list.items.where((item) => item.isPurchased).length;
                        final completionRate = itemCount > 0 ? (purchasedCount / itemCount * 100).round() : 0;

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          curve: Curves.easeOutCubic,
                          child: NaturalEcoCard(
                            key: Key(list.id),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoppingListDetailScreen(
                                    shoppingList: list,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            list.name,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              NaturalEcoChip(
                                                label: '$itemCount個のアイテム',
                                                icon: Icons.list,
                                              ),
                                              const SizedBox(width: 8),
                                              NaturalEcoChip(
                                                label: '$purchasedCount個購入済み',
                                                icon: Icons.check_circle,
                                                backgroundColor: NaturalEcoTheme.primaryGreen.withOpacity(0.1),
                                                textColor: NaturalEcoTheme.primaryGreen,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: NaturalEcoTheme.mediumGrey),
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          await _deleteShoppingList(list.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: NaturalEcoTheme.darkGrey),
                                              const SizedBox(width: 8),
                                              Text('削除'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // 進捗バー
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '進捗',
                                          style: Theme.of(context).textTheme.labelMedium,
                                        ),
                                        Text(
                                          '$completionRate%',
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: NaturalEcoTheme.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: NaturalEcoTheme.lightGrey,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: completionRate / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: NaturalEcoTheme.primaryGradient,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (list.items.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  // 最近のアイテム
                                  Text(
                                    '最近のアイテム',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: NaturalEcoTheme.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...list.items.take(3).map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            item.isPurchased ? Icons.check_circle : Icons.radio_button_unchecked,
                                            size: 16,
                                            color: item.isPurchased 
                                                ? NaturalEcoTheme.primaryGreen 
                                                : NaturalEcoTheme.mediumGrey,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.productName,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                decoration: item.isPurchased 
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: item.isPurchased 
                                                    ? NaturalEcoTheme.mediumGrey 
                                                    : NaturalEcoTheme.darkGrey,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity}${item.unit}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: NaturalEcoTheme.mediumGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
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
                      builder: (context) => const AddShoppingItemScreen(),
                    ),
                  );
                },
                backgroundColor: NaturalEcoTheme.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 12,
                icon: const Icon(Icons.add),
                label: const Text('リストを作成'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ShoppingListDetailScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListDetailScreen({
    Key? key,
    required this.shoppingList,
  }) : super(key: key);

  @override
  State<ShoppingListDetailScreen> createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  Future<void> _toggleItemPurchased(ShoppingItem item) async {
    try {
      final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
      await Provider.of<ShoppingProvider>(context, listen: false)
          .updateShoppingItem(updatedItem);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('エラーが発生しました'),
            backgroundColor: NaturalEcoTheme.darkGrey,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await Provider.of<ShoppingProvider>(context, listen: false)
          .deleteShoppingItem(itemId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('エラーが発生しました'),
            backgroundColor: NaturalEcoTheme.darkGrey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NaturalEcoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.shoppingList.name),
          backgroundColor: NaturalEcoTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: widget.shoppingList.items.length,
          itemBuilder: (context, index) {
            final item = widget.shoppingList.items[index];
            return NaturalEcoCard(
              key: Key(item.id),
              onTap: () => _toggleItemPurchased(item),
              child: Row(
                children: [
                  Icon(
                    item.isPurchased ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 24,
                    color: item.isPurchased 
                        ? NaturalEcoTheme.primaryGreen 
                        : NaturalEcoTheme.mediumGrey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: item.isPurchased 
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isPurchased 
                                ? NaturalEcoTheme.mediumGrey 
                                : NaturalEcoTheme.darkGrey,
                          ),
                        ),
                        if (item.barcode != null) ...[
                          const SizedBox(height: 4),
                          NaturalEcoChip(
                            label: 'バーコード: ${item.barcode}',
                            icon: Icons.qr_code,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${item.quantity}${item.unit}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: NaturalEcoTheme.mediumGrey,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: NaturalEcoTheme.mediumGrey),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await _deleteItem(item.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: NaturalEcoTheme.darkGrey),
                            const SizedBox(width: 8),
                            Text('削除'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
