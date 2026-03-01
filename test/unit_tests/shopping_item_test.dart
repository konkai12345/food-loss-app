import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/shopping_item.dart';

void main() {
  group('ShoppingItem Tests', () {
    test('ShoppingItem should create with required fields', () {
      // Arrange
      final now = DateTime.now();
      final plannedDate = now.add(const Duration(days: 3));
      
      // Act
      final shoppingItem = ShoppingItem(
        id: '1',
        productName: 'Test Product',
        quantity: 2,
        plannedPurchaseDate: plannedDate,
        listId: 'default_list',
        createdDate: now,
      );
      
      // Assert
      expect(shoppingItem.id, '1');
      expect(shoppingItem.productName, 'Test Product');
      expect(shoppingItem.quantity, 2);
      expect(shoppingItem.plannedPurchaseDate, plannedDate);
      expect(shoppingItem.listId, 'default_list');
      expect(shoppingItem.isPurchased, false);
      expect(shoppingItem.barcode, null);
      expect(shoppingItem.createdDate, now);
    });

    test('ShoppingItem should create with all fields', () {
      // Arrange
      final now = DateTime.now();
      final plannedDate = now.add(const Duration(days: 3));
      
      // Act
      final shoppingItem = ShoppingItem(
        id: '1',
        productName: 'Test Product',
        quantity: 2,
        plannedPurchaseDate: plannedDate,
        listId: 'default_list',
        isPurchased: true,
        barcode: '123456789',
        createdDate: now,
      );
      
      // Assert
      expect(shoppingItem.id, '1');
      expect(shoppingItem.productName, 'Test Product');
      expect(shoppingItem.quantity, 2);
      expect(shoppingItem.plannedPurchaseDate, plannedDate);
      expect(shoppingItem.listId, 'default_list');
      expect(shoppingItem.isPurchased, true);
      expect(shoppingItem.barcode, '123456789');
      expect(shoppingItem.createdDate, now);
    });

    test('ShoppingItem should convert to JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final plannedDate = now.add(const Duration(days: 3));
      final shoppingItem = ShoppingItem(
        id: '1',
        productName: 'Test Product',
        quantity: 2,
        plannedPurchaseDate: plannedDate,
        listId: 'default_list',
        isPurchased: true,
        barcode: '123456789',
        createdDate: now,
      );
      
      // Act
      final json = shoppingItem.toJson();
      
      // Assert
      expect(json['id'], '1');
      expect(json['productName'], 'Test Product');
      expect(json['quantity'], 2);
      expect(json['plannedPurchaseDate'], plannedDate.toIso8601String());
      expect(json['listId'], 'default_list');
      expect(json['isPurchased'], 1); // bool to int conversion
      expect(json['barcode'], '123456789');
      expect(json['createdDate'], now.toIso8601String());
    });

    test('ShoppingItem should create from JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final plannedDate = now.add(const Duration(days: 3));
      final json = {
        'id': '1',
        'productName': 'Test Product',
        'quantity': 2,
        'plannedPurchaseDate': plannedDate.toIso8601String(),
        'listId': 'default_list',
        'isPurchased': 1, // int to bool conversion
        'barcode': '123456789',
        'createdDate': now.toIso8601String(),
      };
      
      // Act
      final shoppingItem = ShoppingItem.fromJson(json);
      
      // Assert
      expect(shoppingItem.id, '1');
      expect(shoppingItem.productName, 'Test Product');
      expect(shoppingItem.quantity, 2);
      expect(shoppingItem.plannedPurchaseDate, plannedDate);
      expect(shoppingItem.listId, 'default_list');
      expect(shoppingItem.isPurchased, true);
      expect(shoppingItem.barcode, '123456789');
      expect(shoppingItem.createdDate, now);
    });

    test('ShoppingItem should handle null isPurchased in JSON', () {
      // Arrange
      final now = DateTime.now();
      final plannedDate = now.add(const Duration(days: 3));
      final json = {
        'id': '1',
        'productName': 'Test Product',
        'quantity': 2,
        'plannedPurchaseDate': plannedDate.toIso8601String(),
        'listId': 'default_list',
        'isPurchased': null, // null case
        'createdDate': now.toIso8601String(),
      };
      
      // Act
      final shoppingItem = ShoppingItem.fromJson(json);
      
      // Assert
      expect(shoppingItem.isPurchased, false); // should default to false
    });

    test('ShoppingItem should copy with new values', () {
      // Arrange
      final now = DateTime.now();
      final plannedDate = now.add(const Duration(days: 3));
      final newPlannedDate = now.add(const Duration(days: 5));
      final shoppingItem = ShoppingItem(
        id: '1',
        productName: 'Test Product',
        quantity: 2,
        plannedPurchaseDate: plannedDate,
        listId: 'default_list',
        createdDate: now,
      );
      
      // Act
      final copiedItem = shoppingItem.copyWith(
        quantity: 3,
        plannedPurchaseDate: newPlannedDate,
        isPurchased: true,
      );
      
      // Assert
      expect(copiedItem.id, '1');
      expect(copiedItem.productName, 'Test Product');
      expect(copiedItem.quantity, 3);
      expect(copiedItem.plannedPurchaseDate, newPlannedDate);
      expect(copiedItem.listId, 'default_list');
      expect(copiedItem.isPurchased, true);
    });

    test('ShoppingItem should calculate days until purchase correctly', () {
      // Arrange
      final now = DateTime.now();
      final shoppingItem = ShoppingItem(
        id: '1',
        productName: 'Test Product',
        quantity: 1,
        plannedPurchaseDate: now.add(const Duration(days: 3)),
        listId: 'default_list',
        createdDate: now,
      );
      
      // Act
      final daysUntilPurchase = shoppingItem.daysUntilPurchase;
      
      // Assert
      expect(daysUntilPurchase, 3);
    });

    test('ShoppingItem should identify overdue items correctly', () {
      // Arrange
      final now = DateTime.now();
      final overdueItem = ShoppingItem(
        id: '1',
        productName: 'Overdue Item',
        quantity: 1,
        plannedPurchaseDate: now.subtract(const Duration(days: 1)),
        listId: 'default_list',
        createdDate: now,
      );
      
      final upcomingItem = ShoppingItem(
        id: '2',
        productName: 'Upcoming Item',
        quantity: 1,
        plannedPurchaseDate: now.add(const Duration(days: 1)),
        listId: 'default_list',
        createdDate: now,
      );
      
      // Act & Assert
      expect(overdueItem.isOverdue(), true);
      expect(upcomingItem.isOverdue(), false);
    });

    test('ShoppingItem should identify urgent items correctly', () {
      // Arrange
      final now = DateTime.now();
      final urgentItem = ShoppingItem(
        id: '1',
        productName: 'Urgent Item',
        quantity: 1,
        plannedPurchaseDate: now.add(const Duration(days: 1)),
        listId: 'default_list',
        createdDate: now,
      );
      
      final notUrgentItem = ShoppingItem(
        id: '2',
        productName: 'Not Urgent Item',
        quantity: 1,
        plannedPurchaseDate: now.add(const Duration(days: 5)),
        listId: 'default_list',
        createdDate: now,
      );
      
      // Act & Assert
      expect(urgentItem.isUrgent(), true);
      expect(notUrgentItem.isUrgent(), false);
    });

    test('ShoppingItem should handle null plannedPurchaseDate', () {
      // Arrange
      final now = DateTime.now();
      final shoppingItem = ShoppingItem(
        id: '1',
        productName: 'Test Product',
        quantity: 1,
        listId: 'default_list',
        createdDate: now,
        plannedPurchaseDate: null,
      );
      
      // Act & Assert
      expect(shoppingItem.daysUntilPurchase, null);
      expect(shoppingItem.isOverdue(), false);
      expect(shoppingItem.isUrgent(), false);
    });
  });
}
