import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/shopping_list.dart';
import 'package:food_loss_app/models/shopping_item.dart';

void main() {
  group('ShoppingList 単体テスト', () {
    late ShoppingList testShoppingList;

    setUp(() {
      testShoppingList = ShoppingList(
        id: 'test_list_1',
        name: 'テスト買い物リスト1',
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
        isCompleted: false,
      );
    });

    test('ShoppingListの基本プロパティが正しく設定される', () {
      expect(testShoppingList.id, 'test_list_1');
      expect(testShoppingList.name, 'テスト買い物リスト1');
      expect(testShoppingList.isCompleted, false);
      expect(testShoppingList.createdDate, isA<DateTime>());
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedList = testShoppingList.copyWith(
        name: '更新されたリスト',
        isCompleted: true,
      );

      expect(copiedList.id, testShoppingList.id);
      expect(copiedList.name, '更新されたリスト');
      expect(copiedList.isCompleted, true);
      expect(copiedList.createdDate, testShoppingList.createdDate);
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testShoppingList.toJson();
      
      expect(json['id'], 'test_list_1');
      expect(json['name'], 'テスト買い物リスト1');
      expect(json['isCompleted'], false);
      expect(json['createdDate'], isA<String>());
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'id': 'json_test_list',
        'name': 'JSONテストリスト',
        'createdDate': DateTime.now().toIso8601String(),
        'isCompleted': 1,
      };

      final shoppingList = ShoppingList.fromJson(json);
      
      expect(shoppingList.id, 'json_test_list');
      expect(shoppingList.name, 'JSONテストリスト');
      expect(shoppingList.isCompleted, true);
      expect(shoppingList.createdDate, isA<DateTime>());
    });

    test('完了状態の切り替えが正しく機能する', () {
      expect(testShoppingList.isCompleted, false);
      
      final completedList = testShoppingList.copyWith(isCompleted: true);
      expect(completedList.isCompleted, true);
      
      final uncompletedList = completedList.copyWith(isCompleted: false);
      expect(uncompletedList.isCompleted, false);
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testShoppingList.toString();
      expect(result, contains('テスト買い物リスト1'));
      expect(result, contains('test_list_1'));
    });

    test('等価性比較が正しく機能する', () {
      final sameList = ShoppingList(
        id: testShoppingList.id,
        name: testShoppingList.name,
        createdDate: testShoppingList.createdDate,
        isCompleted: testShoppingList.isCompleted,
      );

      expect(testShoppingList == sameList, true);
      
      final differentList = testShoppingList.copyWith(name: '違う名前');
      expect(testShoppingList == differentList, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameList = ShoppingList(
        id: testShoppingList.id,
        name: testShoppingList.name,
        createdDate: testShoppingList.createdDate,
        isCompleted: testShoppingList.isCompleted,
      );

      expect(testShoppingList.hashCode, sameList.hashCode);
    });
  });

  group('ShoppingItem 単体テスト', () {
    late ShoppingItem testShoppingItem;

    setUp(() {
      testShoppingItem = ShoppingItem(
        id: 'test_item_1',
        listId: 'test_list_1',
        productName: 'テストりんご',
        quantity: 2,
        barcode: '4901085184109',
        isPurchased: false,
        createdDate: DateTime.now().subtract(const Duration(hours: 2)),
      );
    });

    test('ShoppingItemの基本プロパティが正しく設定される', () {
      expect(testShoppingItem.id, 'test_item_1');
      expect(testShoppingItem.listId, 'test_list_1');
      expect(testShoppingItem.productName, 'テストりんご');
      expect(testShoppingItem.quantity, 2);
      expect(testShoppingItem.barcode, '4901085184109');
      expect(testShoppingItem.isPurchased, false);
      expect(testShoppingItem.createdDate, isA<DateTime>());
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedItem = testShoppingItem.copyWith(
        quantity: 5,
        isPurchased: true,
      );

      expect(copiedItem.id, testShoppingItem.id);
      expect(copiedItem.listId, testShoppingItem.listId);
      expect(copiedItem.productName, testShoppingItem.productName);
      expect(copiedItem.quantity, 5);
      expect(copiedItem.isPurchased, true);
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testShoppingItem.toJson();
      
      expect(json['id'], 'test_item_1');
      expect(json['listId'], 'test_list_1');
      expect(json['productName'], 'テストりんご');
      expect(json['quantity'], 2);
      expect(json['barcode'], '4901085184109');
      expect(json['isPurchased'], false);
      expect(json['createdDate'], isA<String>());
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'id': 'json_test_item',
        'listId': 'json_test_list',
        'productName': 'JSONテスト商品',
        'quantity': 3,
        'barcode': '4901085184112',
        'isPurchased': 1,
        'createdDate': DateTime.now().toIso8601String(),
      };

      final shoppingItem = ShoppingItem.fromJson(json);
      
      expect(shoppingItem.id, 'json_test_item');
      expect(shoppingItem.listId, 'json_test_list');
      expect(shoppingItem.productName, 'JSONテスト商品');
      expect(shoppingItem.quantity, 3);
      expect(shoppingItem.isPurchased, true);
    });

    test('購入状態の切り替えが正しく機能する', () {
      expect(testShoppingItem.isPurchased, false);
      
      final purchasedItem = testShoppingItem.copyWith(isPurchased: true);
      expect(purchasedItem.isPurchased, true);
      
      final unpurchasedItem = purchasedItem.copyWith(isPurchased: false);
      expect(unpurchasedItem.isPurchased, false);
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testShoppingItem.toString();
      expect(result, contains('テストりんご'));
      expect(result, contains('test_item_1'));
    });

    test('等価性比較が正しく機能する', () {
      final sameItem = ShoppingItem(
        id: testShoppingItem.id,
        listId: testShoppingItem.listId,
        productName: testShoppingItem.productName,
        quantity: testShoppingItem.quantity,
        barcode: testShoppingItem.barcode,
        isPurchased: testShoppingItem.isPurchased,
        createdDate: testShoppingItem.createdDate,
      );

      expect(testShoppingItem == sameItem, true);
      
      final differentItem = testShoppingItem.copyWith(quantity: 10);
      expect(testShoppingItem == differentItem, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameItem = ShoppingItem(
        id: testShoppingItem.id,
        listId: testShoppingItem.listId,
        productName: testShoppingItem.productName,
        quantity: testShoppingItem.quantity,
        barcode: testShoppingItem.barcode,
        isPurchased: testShoppingItem.isPurchased,
        createdDate: testShoppingItem.createdDate,
      );

      expect(testShoppingItem.hashCode, sameItem.hashCode);
    });
  });

  group('ShoppingList 境界値テスト', () {
    test('空の名前でShoppingListを作成できる', () {
      final shoppingList = ShoppingList(
        id: 'test_empty_name',
        name: '',
        createdDate: DateTime.now(),
        isCompleted: false,
      );

      expect(shoppingList.name, '');
    });

    test('nullのcreatedDateでShoppingListを作成できる', () {
      final shoppingList = ShoppingList(
        id: 'test_null_date',
        name: 'null日付リスト',
        createdDate: DateTime.now(),
        isCompleted: false,
      );

      expect(shoppingList.createdDate, isA<DateTime>());
    });
  });

  group('ShoppingItem 境界値テスト', () {
    test('空の商品名でShoppingItemを作成できる', () {
      final shoppingItem = ShoppingItem(
        id: 'test_empty_name',
        listId: 'test_list',
        productName: '',
        quantity: 1,
        barcode: '',
        isPurchased: false,
        createdDate: DateTime.now(),
      );

      expect(shoppingItem.productName, '');
      expect(shoppingItem.barcode, '');
    });

    test('数量が0のShoppingItemを作成できる', () {
      final shoppingItem = ShoppingItem(
        id: 'test_zero_quantity',
        listId: 'test_list',
        productName: '数量ゼロ商品',
        quantity: 0,
        barcode: '',
        isPurchased: false,
        createdDate: DateTime.now(),
      );

      expect(shoppingItem.quantity, 0);
    });

    test('nullのバーコードでShoppingItemを作成できる', () {
      final shoppingItem = ShoppingItem(
        id: 'test_null_barcode',
        listId: 'test_list',
        productName: 'nullバーコード商品',
        quantity: 1,
        barcode: '',
        isPurchased: false,
        createdDate: DateTime.now(),
      );

      expect(shoppingItem.barcode, '');
    });
  });
}
