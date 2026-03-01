import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/services/database_service.dart';
import 'package:food_loss_app/models/food_item.dart';

void main() {
  group('DatabaseService Tests', () {
    group('Food Item Operations', () {
      test('Should add food item', () async {
        // Arrange
        final foodItem = FoodItem(
          id: '1',
          name: 'Test Food',
          quantity: 2,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          registrationDate: DateTime.now(),
          category: '野菜',
          storageLocation: '冷蔵庫',
        );

        // Act
        await DatabaseService.addFoodItem(foodItem);

        // Assert
        final items = await DatabaseService.getAllFoodItems();
        expect(items.length, 1);
        expect(items[0].name, 'Test Food');
      });

      test('Should get all food items', () async {
        // Arrange
        final foodItem1 = FoodItem(
          id: '1',
          name: 'Test Food 1',
          quantity: 2,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          registrationDate: DateTime.now(),
          category: '野菜',
          storageLocation: '冷蔵庫',
        );
        final foodItem2 = FoodItem(
          id: '2',
          name: 'Test Food 2',
          quantity: 1,
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          registrationDate: DateTime.now(),
          category: '果物',
          storageLocation: '冷凍庫',
        );

        // Act
        await DatabaseService.addFoodItem(foodItem1);
        await DatabaseService.addFoodItem(foodItem2);
        final items = await DatabaseService.getAllFoodItems();

        // Assert
        expect(items.length, 2);
        expect(items[0].name, 'Test Food 1');
        expect(items[1].name, 'Test Food 2');
      });

      test('Should get food items by category', () async {
        // Arrange
        final vegetableItem = FoodItem(
          id: '1',
          name: 'Vegetable',
          quantity: 2,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          registrationDate: DateTime.now(),
          category: '野菜',
          storageLocation: '冷蔵庫',
        );
        final fruitItem = FoodItem(
          id: '2',
          name: 'Fruit',
          quantity: 1,
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          registrationDate: DateTime.now(),
          category: '果物',
          storageLocation: '冷凍庫',
        );

        // Act
        await DatabaseService.addFoodItem(vegetableItem);
        await DatabaseService.addFoodItem(fruitItem);
        final vegetables = await DatabaseService.getFoodItemsByCategory('野菜');

        // Assert
        expect(vegetables.length, 1);
        expect(vegetables[0].category, '野菜');
        expect(vegetables[0].name, 'Vegetable');
      });

      test('Should update food item', () async {
        // Arrange
        final foodItem = FoodItem(
          id: '1',
          name: 'Test Food',
          quantity: 2,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          registrationDate: DateTime.now(),
          category: '野菜',
          storageLocation: '冷蔵庫',
        );
        await DatabaseService.addFoodItem(foodItem);
        final updatedItem = foodItem.copyWith(
          quantity: 3,
          memo: 'Updated memo',
        );

        // Act
        await DatabaseService.updateFoodItem(updatedItem);
        final items = await DatabaseService.getAllFoodItems();

        // Assert
        expect(items.length, 1);
        expect(items[0].quantity, 3);
        expect(items[0].memo, 'Updated memo');
      });

      test('Should delete food item', () async {
        // Arrange
        final foodItem = FoodItem(
          id: '1',
          name: 'Test Food',
          quantity: 2,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          registrationDate: DateTime.now(),
          category: '野菜',
          storageLocation: '冷蔵庫',
        );
        await DatabaseService.addFoodItem(foodItem);

        // Act
        await DatabaseService.deleteFoodItem('1');
        final items = await DatabaseService.getAllFoodItems();

        // Assert
        expect(items.length, 0);
      });
    });

    group('Shopping Item Operations', () {
      test('Should add shopping item', () async {
        // Act
        final id = await DatabaseService.addShoppingItem('default_list', 'Test Product', quantity: 2);

        // Assert
        expect(id, isA<String>());
        expect(id, isNotEmpty);
      });
    });

    group('Food Item Logic', () {
      test('Should identify expired items correctly', () {
        // Arrange
        final now = DateTime.now();
        final expiredItem = FoodItem(
          id: '1',
          name: 'Expired Food',
          quantity: 1,
          expiryDate: now.subtract(const Duration(days: 1)),
          registrationDate: now,
          category: '野菜',
          storageLocation: '冷蔵庫',
        );
        
        final validItem = FoodItem(
          id: '2',
          name: 'Valid Food',
          quantity: 1,
          expiryDate: now.add(const Duration(days: 1)),
          registrationDate: now,
          category: '野菜',
          storageLocation: '冷蔵庫',
        );

        // Act & Assert
        expect(expiredItem.isExpired(), true);
        expect(validItem.isExpired(), false);
      });

      test('Should calculate days until expiry correctly', () {
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
    });
  });
}
