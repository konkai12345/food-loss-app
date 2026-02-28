import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/food_item.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import '../services/database_service.dart';
import '../services/mock_data_service.dart';
import '../utils/error_handler.dart';

class FamilyService {
  static const String _usersKey = 'users';
  static const String _familiesKey = 'families';
  static const String _familyMembersKey = 'family_members';

  // ユーザー作成
  static Future<User> createUser({
    required String name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final user = User(
        name: name,
        email: email,
        avatarUrl: avatarUrl,
      );

      if (kIsWeb) {
        // Web版ではローカルストレージに保存
        await MockDataService.saveUser(user);
      } else {
        // モバージョンではデータベースに保存
        await _saveUserToDatabase(user);
      }

      return user;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.createUser');
      rethrow;
    }
  }

  // ユーザー取得
  static Future<User?> getUser(String userId) async {
    try {
      if (kIsWeb) {
        return await MockDataService.getUser(userId);
      } else {
        return await _getUserFromDatabase(userId);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getUser');
      return null;
    }
  }

  // ユーザーリスト取得
  static Future<List<User>> getAllUsers() async {
    try {
      if (kIsWeb) {
        return await MockDataService.getAllUsers();
      } else {
        return await _getAllUsersFromDatabase();
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getAllUsers');
      return [];
    }
  }

  // ユーザー更新
  static Future<User> updateUser(User user) async {
    try {
      if (kIsWeb) {
        await MockDataService.updateUser(user);
      } else {
        await _updateUserInDatabase(user);
      }

      return user;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.updateUser');
      rethrow;
    }
  }

  // ユーザー削除
  static Future<void> deleteUser(String userId) async {
    try {
      if (kIsWeb) {
        await MockDataService.deleteUser(userId);
      } else {
        await _deleteUserFromDatabase(userId);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.deleteUser');
    }
  }

  // ファミリー作成
  static Future<Family> createFamily({
    required String name,
    String? description,
    required String createdBy,
  }) async {
    try {
      final family = Family(
        name: name,
        description: description,
        createdBy: createdBy,
      );

      if (kIsWeb) {
        await MockDataService.saveFamily(family);
      } else {
        await _saveFamilyToDatabase(family);
      }

      return family;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.createFamily');
      rethrow;
    }
  }

  // ファミリー取得
  static Future<Family?> getFamily(String familyId) async {
    try {
      if (kIsWeb) {
        return await MockDataService.getFamily(familyId);
      } else {
        return await _getFamilyFromDatabase(familyId);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getFamily');
      return null;
    }
  }

  // ファミリーリスト取得
  static Future<List<Family>> getAllFamilies() async {
    try {
      if (kIsWeb) {
        return await MockDataService.getAllFamilies();
      } else {
        return await _getAllFamiliesFromDatabase();
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getAllFamilies');
      return [];
    }
  }

  // ファミリー更新
  static Future<Family> updateFamily(Family family) async {
    try {
      if (kIsWeb) {
        await MockDataService.updateFamily(family);
      } else {
        await _updateFamilyInDatabase(family);
      }

      return family;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.updateFamily');
      rethrow;
    }
  }

  // ファミリー削除
  static Future<void> deleteFamily(String familyId) async {
    try {
      if (kIsWeb) {
        await MockDataService.deleteFamily(familyId);
      } else {
        await _deleteFamilyFromDatabase(familyId);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.deleteFamily');
    }
  }

  // ファミリーメンバー追加
  static Future<FamilyMember> addFamilyMember({
    required String familyId,
    required String userId,
    required String userName,
    required String userEmail,
    String? role,
  }) async {
    try {
      final member = FamilyMember(
        familyId: familyId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        role: role ?? 'member',
      );

      if (kIsWeb) {
        await MockDataService.saveFamilyMember(member);
      } else {
        await _saveFamilyMemberToDatabase(member);
      }

      // ユーザーのfamilyIdsを更新
      final user = await getUser(userId);
      if (user != null) {
        final updatedFamilyIds = [...user.familyIds, familyId];
        await updateUser(user.copyWith(familyIds: updatedFamilyIds));
      }

      // ファミリーのmemberIdsを更新
      final family = await getFamily(familyId);
      if (family != null) {
        final updatedMemberIds = [...family.memberIds, userId];
        await updateFamily(family.copyWith(memberIds: updatedMemberIds));
      }

      return member;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.addFamilyMember');
      rethrow;
    }
  }

  // ファミリーメンバー取得
  static Future<List<FamilyMember>> getFamilyMembers(String familyId) async {
    try {
      if (kIsWeb) {
        return await MockDataService.getFamilyMembers(familyId);
      } else {
        return await _getFamilyMembersFromDatabase(familyId);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getFamilyMembers');
      return [];
    }
  }

  // ファミリーメンバー更新
  static Future<FamilyMember> updateFamilyMember(FamilyMember member) async {
    try {
      if (kIsWeb) {
        await MockDataService.updateFamilyMember(member);
      } else {
        await _updateFamilyMemberInDatabase(member);
      }

      return member;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.updateFamilyMember');
      rethrow;
    }
  }

  // ファミリーメンバー削除
  static Future<void> removeFamilyMember(String familyId, String userId) async {
    try {
      if (kIsWeb) {
        await MockDataService.deleteFamilyMember(familyId, userId);
      } else {
        await _deleteFamilyMemberFromDatabase(familyId, userId);
      }

      // ユーザーのfamilyIdsを更新
      final user = await getUser(userId);
      if (user != null) {
        final updatedFamilyIds = user.familyIds.where((id) => id != familyId).toList();
        await updateUser(user.copyWith(familyIds: updatedFamilyIds));
      }

      // ファミリーのmemberIdsを更新
      final family = await getFamily(familyId);
      if (family != null) {
        final updatedMemberIds = family.memberIds.where((id) => id != userId).toList();
        await updateFamily(family.copyWith(memberIds: updatedMemberIds));
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.removeFamilyMember');
    }
  }

  // ユーザーのファミリーリスト取得
  static Future<List<Family>> getUserFamilies(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return [];

      final families = <Family>[];
      for (final familyId in user.familyIds) {
        final family = await getFamily(familyId);
        if (family != null) {
          families.add(family);
        }
      }

      return families;
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getUserFamilies');
      return [];
    }
  }

  // データ共有（食材）
  static Future<void> shareFoodItemWithFamily(String foodItemId, String familyId) async {
    try {
      final foodItem = await DatabaseService.getFoodItemById(foodItemId);
      if (foodItem == null) return;

      // 共有データを作成
      final sharedData = {
        'type': 'food_item',
        'foodItemId': foodItemId,
        'sharedBy': foodItem.id,
        'sharedAt': DateTime.now().toIso8601String(),
        'familyId': familyId,
        'data': foodItem.toJson(),
      };

      if (kIsWeb) {
        await MockDataService.saveSharedData(sharedData);
      } else {
        await _saveSharedDataToDatabase(sharedData);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.shareFoodItemWithFamily');
    }
  }

  // データ共有（買い物リスト）
  static Future<void> shareShoppingListWithFamily(String shoppingListId, String familyId) async {
    try {
      final shoppingList = await DatabaseService.getShoppingListById(shoppingListId);
      if (shoppingList == null) return;

      final items = await DatabaseService.getShoppingItems(shoppingListId);

      // 共有データを作成
      final sharedData = {
        'type': 'shopping_list',
        'shoppingListId': shoppingListId,
        'sharedBy': shoppingList.id,
        'sharedAt': DateTime.now().toIso8601String(),
        'familyId': familyId,
        'data': shoppingList.toJson(),
        'items': items.map((item) => item.toJson()).toList(),
      };

      if (kIsWeb) {
        await MockDataService.saveSharedData(sharedData);
      } else {
        await _saveSharedDataToDatabase(sharedData);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.shareShoppingListWithFamily');
    }
  }

  // 共有データ取得
  static Future<List<Map<String, dynamic>>> getSharedData(String familyId) async {
    try {
      if (kIsWeb) {
        return await MockDataService.getSharedData(familyId);
      } else {
        return await _getSharedDataFromDatabase(familyId);
      }
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.getSharedData');
      return [];
    }
  }

  // データベース操作（モバイル版）
  static Future<void> _saveUserToDatabase(User user) async {
    // 実際のデータベース実装
    // 注: ここではモック実装を返す
    await MockDataService.saveUser(user);
  }

  static Future<User?> _getUserFromDatabase(String userId) async {
    return await MockDataService.getUser(userId);
  }

  static Future<List<User>> _getAllUsersFromDatabase() async {
    return await MockDataService.getAllUsers();
  }

  static Future<void> _updateUserInDatabase(User user) async {
    await MockDataService.updateUser(user);
  }

  static Future<void> _deleteUserFromDatabase(String userId) async {
    await MockDataService.deleteUser(userId);
  }

  static Future<void> _saveFamilyToDatabase(Family family) async {
    await MockDataService.saveFamily(family);
  }

  static Future<Family?> _getFamilyFromDatabase(String familyId) async {
    return await MockDataService.getFamily(familyId);
  }

  static Future<List<Family>> _getAllFamiliesFromDatabase() async {
    return await MockDataService.getAllFamilies();
  }

  static Future<void> _updateFamilyInDatabase(Family family) async {
    await MockDataService.updateFamily(family);
  }

  static Future<void> _deleteFamilyFromDatabase(String familyId) async {
    await MockDataService.deleteFamily(familyId);
  }

  static Future<void> _saveFamilyMemberToDatabase(FamilyMember member) async {
    await MockDataService.saveFamilyMember(member);
  }

  static Future<List<FamilyMember>> _getFamilyMembersFromDatabase(String familyId) async {
    return await MockDataService.getFamilyMembers(familyId);
  }

  static Future<void> _updateFamilyMemberInDatabase(FamilyMember member) async {
    await MockDataService.updateFamilyMember(member);
  }

  static Future<void> _deleteFamilyMemberFromDatabase(String familyId, String userId) async {
    await MockDataService.deleteFamilyMember(familyId, userId);
  }

  static Future<void> _saveSharedDataToDatabase(Map<String, dynamic> sharedData) async {
    await MockDataService.saveSharedData(sharedData);
  }

  static Future<List<Map<String, dynamic>>> _getSharedDataFromDatabase(String familyId) async {
    return await MockDataService.getSharedData(familyId);
  }

  // 権限管理
  static bool hasPermission(String userId, String familyId, String permission) {
    // 実際の権限チェック実装
    return true; // 簡易実装
  }

  // 役割管理
  static bool isAdmin(String userId, String familyId) {
    // 実際の役割チェック実装
    return true; // 簡易実装
  }

  // 同期管理
  static Future<void> syncData(String familyId) async {
    try {
      // 実際の同期処理実装
      // 1. ユーザー情報の同期
      // 2. ファミリー情報の同期
      // 3. 共有データの同期
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyService.syncData');
    }
  }
}
