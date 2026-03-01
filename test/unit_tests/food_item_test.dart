import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/food_item.dart';

void main() {
  group('FoodItem Tests', () {
    test('FoodItem should create with required fields', () {
      // Arrange
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 7));
      
      // Act
      final foodItem = FoodItem(
        id: '1',
        name: 'Test Food',
        quantity: 2,
        expiryDate: expiryDate,
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      // Assert
      expect(foodItem.id, '1');
      expect(foodItem.name, 'Test Food');
      expect(foodItem.quantity, 2);
      expect(foodItem.expiryDate, expiryDate);
      expect(foodItem.registrationDate, now);
      expect(foodItem.category, '野菜');
      expect(foodItem.storageLocation, '冷蔵庫');
      expect(foodItem.price, null);
      expect(foodItem.purchaseStore, null);
      expect(foodItem.memo, null);
      expect(foodItem.imagePath, null);
    });

    test('FoodItem should create with all fields', () {
      // Arrange
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 7));
      
      // Act
      final foodItem = FoodItem(
        id: '1',
        name: 'Test Food',
        quantity: 2,
        expiryDate: expiryDate,
        registrationDate: now,
        category: '果物',
        storageLocation: '冷凍庫',
        price: 300.0,
        purchaseStore: 'Test Store',
        memo: 'Test Memo',
        imagePath: '/path/to/image.jpg',
      );
      
      // Assert
      expect(foodItem.id, '1');
      expect(foodItem.name, 'Test Food');
      expect(foodItem.quantity, 2);
      expect(foodItem.expiryDate, expiryDate);
      expect(foodItem.registrationDate, now);
      expect(foodItem.category, '果物');
      expect(foodItem.storageLocation, '冷凍庫');
      expect(foodItem.price, 300.0);
      expect(foodItem.purchaseStore, 'Test Store');
      expect(foodItem.memo, 'Test Memo');
      expect(foodItem.imagePath, '/path/to/image.jpg');
    });

    test('FoodItem should convert to JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 7));
      final foodItem = FoodItem(
        id: '1',
        name: 'Test Food',
        quantity: 2,
        expiryDate: expiryDate,
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
        price: 300.0,
        purchaseStore: 'Test Store',
        memo: 'Test Memo',
        imagePath: '/path/to/image.jpg',
      );
      
      // Act
      final json = foodItem.toJson();
      
      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'Test Food');
      expect(json['quantity'], 2);
      expect(json['expiryDate'], expiryDate.toIso8601String());
      expect(json['registrationDate'], now.toIso8601String());
      expect(json['category'], '野菜');
      expect(json['storageLocation'], '冷蔵庫');
      expect(json['price'], 300.0);
      expect(json['purchaseStore'], 'Test Store');
      expect(json['memo'], 'Test Memo');
      expect(json['imagePath'], '/path/to/image.jpg');
    });

    test('FoodItem should create from JSON correctly', () {
      // Arrange
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 7));
      final json = {
        'id': '1',
        'name': 'Test Food',
        'quantity': 2,
        'expiryDate': expiryDate.toIso8601String(),
        'registrationDate': now.toIso8601String(),
        'category': '果物',
        'storageLocation': '冷凍庫',
        'price': 300.0,
        'purchaseStore': 'Test Store',
        'memo': 'Test Memo',
        'imagePath': '/path/to/image.jpg',
      };
      
      // Act
      final foodItem = FoodItem.fromJson(json);
      
      // Assert
      expect(foodItem.id, '1');
      expect(foodItem.name, 'Test Food');
      expect(foodItem.quantity, 2);
      expect(foodItem.expiryDate, expiryDate);
      expect(foodItem.registrationDate, now);
      expect(foodItem.category, '果物');
      expect(foodItem.storageLocation, '冷凍庫');
      expect(foodItem.price, 300.0);
      expect(foodItem.purchaseStore, 'Test Store');
      expect(foodItem.memo, 'Test Memo');
      expect(foodItem.imagePath, '/path/to/image.jpg');
    });

    test('FoodItem should copy with new values', () {
      // Arrange
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(days: 7));
      final newExpiryDate = now.add(const Duration(days: 10));
      final foodItem = FoodItem(
        id: '1',
        name: 'Test Food',
        quantity: 2,
        expiryDate: expiryDate,
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      // Act
      final copiedItem = foodItem.copyWith(
        quantity: 3,
        expiryDate: newExpiryDate,
        memo: 'Updated memo',
      );
      
      // Assert
      expect(copiedItem.id, '1');
      expect(copiedItem.name, 'Test Food');
      expect(copiedItem.quantity, 3);
      expect(copiedItem.expiryDate, newExpiryDate);
      expect(copiedItem.registrationDate, now);
      expect(copiedItem.category, '野菜');
      expect(copiedItem.storageLocation, '冷蔵庫');
      expect(copiedItem.memo, 'Updated memo');
    });

    test('FoodItem should calculate days until expiry correctly', () {
      // Arrange
      final now = DateTime.now();
      final foodItem = FoodItem(
        id: '1',
        name: 'Test Food',
        quantity: 1,
        expiryDate: now.add(const Duration(days: 3)),
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      // Act
      final daysUntilExpiry = foodItem.daysUntilExpiry;
      
      // Assert
      expect(daysUntilExpiry, 3);
    });

    test('FoodItem should identify expired items correctly', () {
      // Arrange
      final now = DateTime.now();
      final expiredFoodItem = FoodItem(
        id: '1',
        name: 'Expired Food',
        quantity: 1,
        expiryDate: now.subtract(const Duration(days: 1)),
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      final validFoodItem = FoodItem(
        id: '2',
        name: 'Valid Food',
        quantity: 1,
        expiryDate: now.add(const Duration(days: 1)),
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      // Act & Assert
      expect(expiredFoodItem.isExpired(), true);
      expect(validFoodItem.isExpired(), false);
    });

    test('FoodItem should identify expiring soon items correctly', () {
      // Arrange
      final now = DateTime.now();
      final expiringSoonFoodItem = FoodItem(
        id: '1',
        name: 'Expiring Soon Food',
        quantity: 1,
        expiryDate: now.add(const Duration(days: 2)),
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      final notExpiringSoonFoodItem = FoodItem(
        id: '2',
        name: 'Not Expiring Soon Food',
        quantity: 1,
        expiryDate: now.add(const Duration(days: 5)),
        registrationDate: now,
        category: '野菜',
        storageLocation: '冷蔵庫',
      );
      
      // Act & Assert
      expect(expiringSoonFoodItem.daysUntilExpiry <= 3, true);
      expect(notExpiringSoonFoodItem.daysUntilExpiry <= 3, false);
    });
  });
}
