import 'package:flutter/foundation.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class ShoppingProvider extends ChangeNotifier {
  List<ShoppingList> _shoppingLists = [];
  List<ShoppingItem> _currentItems = [];
  ShoppingList? _currentList;
  bool _isLoading = false;

  List<ShoppingList> get shoppingLists => _shoppingLists;
  List<ShoppingItem> get currentItems => _currentItems;
  ShoppingList? get currentList => _currentList;
  bool get isLoading => _isLoading;

  // 買い物リスト一覧読み込み
  Future<void> loadShoppingLists() async {
    _setLoading(true);
    try {
      _shoppingLists = await DatabaseService.getAllShoppingLists();
      notifyListeners();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.loadShoppingLists');
    } finally {
      _setLoading(false);
    }
  }

  // 買い物リスト作成
  Future<String> createShoppingList(String name) async {
    _setLoading(true);
    try {
      final listId = await DatabaseService.createShoppingList(name);
      await loadShoppingLists();
      return listId;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.createShoppingList');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 買い物リスト削除
  Future<void> deleteShoppingList(String id) async {
    _setLoading(true);
    try {
      await DatabaseService.deleteShoppingList(id);
      await loadShoppingLists();
      
      if (_currentList?.id == id) {
        _currentList = null;
        _currentItems = [];
      }
      notifyListeners();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.deleteShoppingList');
    } finally {
      _setLoading(false);
    }
  }

  // 買い物リスト選択
  Future<void> selectShoppingList(ShoppingList list) async {
    _currentList = list;
    await loadShoppingItems(list.id);
  }

  // 買い物アイテム読み込み
  Future<void> loadShoppingItems(String listId) async {
    _setLoading(true);
    try {
      _currentItems = await DatabaseService.getShoppingItems(listId);
      
      // 購入予定日順にソート（予定日が近い順、予定日がないものは最後）
      _currentItems.sort((a, b) {
        if (a.plannedPurchaseDate == null && b.plannedPurchaseDate == null) {
          return 0;
        } else if (a.plannedPurchaseDate == null) {
          return 1; // aは最後
        } else if (b.plannedPurchaseDate == null) {
          return -1; // bは最後
        } else {
          return a.plannedPurchaseDate!.compareTo(b.plannedPurchaseDate!);
        }
      });
      
      notifyListeners();
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.loadShoppingItems');
    } finally {
      _setLoading(false);
    }
  }

  // 買い物アイテム追加
  Future<String> addShoppingItem(String productName, {int quantity = 1, String? barcode, DateTime? plannedPurchaseDate, String? listId}) async {
    // 単一リスト形式のため、デフォルトリストIDを使用
    listId ??= 'default_list';

    _setLoading(true);
    try {
      final itemId = await DatabaseService.addShoppingItem(
        listId,
        productName,
        quantity: quantity,
        barcode: barcode,
        plannedPurchaseDate: plannedPurchaseDate,
      );
      await loadShoppingItems(listId);
      return itemId;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.addShoppingItem');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 買い物アイテム更新
  Future<void> updateShoppingItem(ShoppingItem item, {String? listId}) async {
    // 単一リスト形式のため、デフォルトリストIDを使用
    listId ??= 'default_list';

    _setLoading(true);
    try {
      await DatabaseService.updateShoppingItem(item, listId: listId);
      await loadShoppingItems(listId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.updateShoppingItem');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 買い物アイテム削除
  Future<void> deleteShoppingItem(String itemId, {String? listId}) async {
    // 単一リスト形式のため、デフォルトリストIDを使用
    listId ??= 'default_list';

    _setLoading(true);
    try {
      await DatabaseService.deleteShoppingItem(itemId);
      await loadShoppingItems(listId);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.deleteShoppingItem');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 購入状態を切り替え
  Future<void> toggleItemPurchased(ShoppingItem item) async {
    final updatedItem = item.copyWith(isPurchased: !item.isPurchased);
    await updateShoppingItem(updatedItem);
  }

  // 在庫から買い物リストに追加
  Future<void> addFromInventory(String productName, {int quantity = 1}) async {
    if (_currentList == null) {
      throw Exception('No shopping list selected');
    }

    try {
      await addShoppingItem(productName, quantity: quantity);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.addFromInventory');
      rethrow;
    }
  }

  // 購入済みアイテムをクリア
  Future<void> clearPurchasedItems() async {
    if (_currentList == null) return;

    _setLoading(true);
    try {
      final purchasedItems = _currentItems.where((item) => item.isPurchased).toList();
      
      for (final item in purchasedItems) {
        await DatabaseService.deleteShoppingItem(item.id);
      }
      
      await loadShoppingItems(_currentList!.id);
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'ShoppingProvider.clearPurchasedItems');
    } finally {
      _setLoading(false);
    }
  }

  // 統計情報取得
  Map<String, int> getStatistics() {
    if (_currentItems.isEmpty) {
      return {
        'total': 0,
        'purchased': 0,
        'remaining': 0,
      };
    }

    final total = _currentItems.length;
    final purchased = _currentItems.where((item) => item.isPurchased).length;
    final remaining = total - purchased;

    return {
      'total': total,
      'purchased': purchased,
      'remaining': remaining,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearCurrentList() {
    _currentList = null;
    _currentItems = [];
    notifyListeners();
  }
}
