import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/models/user_simple.dart';
import 'package:food_loss_app/models/family.dart';
import 'package:food_loss_app/models/family_member.dart';

void main() {
  group('User 単体テスト', () {
    late User testUser;

    setUp(() {
      testUser = User(
        id: 'test_user_1',
        name: 'テストユーザー1',
        email: 'test1@example.com',
        avatarUrl: 'https://example.com/avatar1.jpg',
        familyIds: ['test_family_1'],
      );
    });

    test('Userの基本プロパティが正しく設定される', () {
      expect(testUser.id, 'test_user_1');
      expect(testUser.name, 'テストユーザー1');
      expect(testUser.email, 'test1@example.com');
      expect(testUser.avatarUrl, 'https://example.com/avatar1.jpg');
      expect(testUser.familyIds, ['test_family_1']);
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedUser = testUser.copyWith(
        name: '更新された名前',
        email: 'updated@example.com',
      );

      expect(copiedUser.id, testUser.id);
      expect(copiedUser.name, '更新された名前');
      expect(copiedUser.email, 'updated@example.com');
      expect(copiedUser.avatarUrl, testUser.avatarUrl);
      expect(copiedUser.familyIds, testUser.familyIds);
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testUser.toJson();
      
      expect(json['id'], 'test_user_1');
      expect(json['name'], 'テストユーザー1');
      expect(json['email'], 'test1@example.com');
      expect(json['avatarUrl'], 'https://example.com/avatar1.jpg');
      expect(json['familyIds'], isA<List>());
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'id': 'json_test_user',
        'name': 'JSONテストユーザー',
        'email': 'json@test.com',
        'avatarUrl': 'https://example.com/json_avatar.jpg',
        'familyIds': ['json_family_1', 'json_family_2'],
      };

      final user = User.fromJson(json);
      
      expect(user.id, 'json_test_user');
      expect(user.name, 'JSONテストユーザー');
      expect(user.email, 'json@test.com');
      expect(user.avatarUrl, 'https://example.com/json_avatar.jpg');
      expect(user.familyIds, ['json_family_1', 'json_family_2']);
    });

    test('ファミリーIDの追加・削除が正しく機能する', () {
      expect(testUser.familyIds.length, 1);
      
      final userWithNewFamily = testUser.copyWith(
        familyIds: ['test_family_1', 'test_family_2']
      );
      expect(userWithNewFamily.familyIds.length, 2);
      
      final userWithoutFamily = testUser.copyWith(familyIds: []);
      expect(userWithoutFamily.familyIds.isEmpty, true);
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testUser.toString();
      expect(result, contains('テストユーザー1'));
      expect(result, contains('test_user_1'));
    });

    test('等価性比較が正しく機能する', () {
      final sameUser = User(
        id: testUser.id,
        name: testUser.name,
        email: testUser.email,
        avatarUrl: testUser.avatarUrl,
        familyIds: testUser.familyIds,
      );

      expect(testUser == sameUser, true);
      
      final differentUser = testUser.copyWith(name: '違う名前');
      expect(testUser == differentUser, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameUser = User(
        id: testUser.id,
        name: testUser.name,
        email: testUser.email,
        avatarUrl: testUser.avatarUrl,
        familyIds: testUser.familyIds,
      );

      expect(testUser.hashCode, sameUser.hashCode);
    });
  });

  group('Family 単体テスト', () {
    late Family testFamily;

    setUp(() {
      testFamily = Family(
        id: 'test_family_1',
        name: 'テストファミリー',
        description: 'テスト用のファミリー',
        createdBy: 'test_user_1',
        memberIds: ['test_user_1', 'test_user_2'],
      );
    });

    test('Familyの基本プロパティが正しく設定される', () {
      expect(testFamily.id, 'test_family_1');
      expect(testFamily.name, 'テストファミリー');
      expect(testFamily.description, 'テスト用のファミリー');
      expect(testFamily.createdBy, 'test_user_1');
      expect(testFamily.memberIds, ['test_user_1', 'test_user_2']);
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedFamily = testFamily.copyWith(
        name: '更新されたファミリー名',
        description: '更新された説明',
      );

      expect(copiedFamily.id, testFamily.id);
      expect(copiedFamily.name, '更新されたファミリー名');
      expect(copiedFamily.description, '更新された説明');
      expect(copiedFamily.createdBy, testFamily.createdBy);
      expect(copiedFamily.memberIds, testFamily.memberIds);
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testFamily.toJson();
      
      expect(json['id'], 'test_family_1');
      expect(json['name'], 'テストファミリー');
      expect(json['description'], 'テスト用のファミリー');
      expect(json['createdBy'], 'test_user_1');
      expect(json['memberIds'], isA<List>());
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'id': 'json_test_family',
        'name': 'JSONテストファミリー',
        'description': 'JSONテスト用のファミリー',
        'createdBy': 'json_test_user',
        'memberIds': ['json_test_user_1', 'json_test_user_2'],
      };

      final family = Family.fromJson(json);
      
      expect(family.id, 'json_test_family');
      expect(family.name, 'JSONテストファミリー');
      expect(family.description, 'JSONテスト用のファミリー');
      expect(family.createdBy, 'json_test_user');
      expect(family.memberIds, ['json_test_user_1', 'json_test_user_2']);
    });

    test('メンバーIDの追加・削除が正しく機能する', () {
      expect(testFamily.memberIds.length, 2);
      
      final familyWithNewMember = testFamily.copyWith(
        memberIds: ['test_user_1', 'test_user_2', 'test_user_3']
      );
      expect(familyWithNewMember.memberIds.length, 3);
      
      final familyWithRemovedMember = testFamily.copyWith(
        memberIds: ['test_user_1']
      );
      expect(familyWithRemovedMember.memberIds.length, 1);
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testFamily.toString();
      expect(result, contains('テストファミリー'));
      expect(result, contains('test_family_1'));
    });

    test('等価性比較が正しく機能する', () {
      final sameFamily = Family(
        id: testFamily.id,
        name: testFamily.name,
        description: testFamily.description,
        createdBy: testFamily.createdBy,
        memberIds: testFamily.memberIds,
      );

      expect(testFamily == sameFamily, true);
      
      final differentFamily = testFamily.copyWith(name: '違う名前');
      expect(testFamily == differentFamily, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameFamily = Family(
        id: testFamily.id,
        name: testFamily.name,
        description: testFamily.description,
        createdBy: testFamily.createdBy,
        memberIds: testFamily.memberIds,
      );

      expect(testFamily.hashCode, sameFamily.hashCode);
    });
  });

  group('FamilyMember 単体テスト', () {
    late FamilyMember testFamilyMember;

    setUp(() {
      testFamilyMember = FamilyMember(
        id: 'test_member_1',
        familyId: 'test_family_1',
        userId: 'test_user_1',
        userName: 'テストユーザー1',
        userEmail: 'test1@example.com',
        role: 'admin',
      );
    });

    test('FamilyMemberの基本プロパティが正しく設定される', () {
      expect(testFamilyMember.id, 'test_member_1');
      expect(testFamilyMember.familyId, 'test_family_1');
      expect(testFamilyMember.userId, 'test_user_1');
      expect(testFamilyMember.userName, 'テストユーザー1');
      expect(testFamilyMember.userEmail, 'test1@example.com');
      expect(testFamilyMember.role, 'admin');
    });

    test('copyWithメソッドが正しく機能する', () {
      final copiedMember = testFamilyMember.copyWith(
        role: 'member',
      );

      expect(copiedMember.id, testFamilyMember.id);
      expect(copiedMember.familyId, testFamilyMember.familyId);
      expect(copiedMember.userId, testFamilyMember.userId);
      expect(copiedMember.userName, testFamilyMember.userName);
      expect(copiedMember.userEmail, testFamilyMember.userEmail);
      expect(copiedMember.role, 'member');
    });

    test('toJsonメソッドが正しく機能する', () {
      final json = testFamilyMember.toJson();
      
      expect(json['id'], 'test_member_1');
      expect(json['familyId'], 'test_family_1');
      expect(json['userId'], 'test_user_1');
      expect(json['userName'], 'テストユーザー1');
      expect(json['userEmail'], 'test1@example.com');
      expect(json['role'], 'admin');
    });

    test('fromJsonメソッドが正しく機能する', () {
      final json = {
        'id': 'json_test_member',
        'familyId': 'json_test_family',
        'userId': 'json_test_user',
        'userName': 'JSONテストユーザー',
        'userEmail': 'json@test.com',
        'role': 'member',
      };

      final member = FamilyMember.fromJson(json);
      
      expect(member.id, 'json_test_member');
      expect(member.familyId, 'json_test_family');
      expect(member.userId, 'json_test_user');
      expect(member.userName, 'JSONテストユーザー');
      expect(member.userEmail, 'json@test.com');
      expect(member.role, 'member');
    });

    test('権限ロールの変更が正しく機能する', () {
      expect(testFamilyMember.role, 'admin');
      
      final memberRole = testFamilyMember.copyWith(role: 'member');
      expect(memberRole.role, 'member');
      
      final adminRole = testFamilyMember.copyWith(role: 'admin');
      expect(adminRole.role, 'admin');
    });

    test('toStringメソッドが正しく機能する', () {
      final result = testFamilyMember.toString();
      expect(result, contains('テストユーザー1'));
      expect(result, contains('test_member_1'));
    });

    test('等価性比較が正しく機能する', () {
      final sameMember = FamilyMember(
        id: testFamilyMember.id,
        familyId: testFamilyMember.familyId,
        userId: testFamilyMember.userId,
        userName: testFamilyMember.userName,
        userEmail: testFamilyMember.userEmail,
        role: testFamilyMember.role,
      );

      expect(testFamilyMember == sameMember, true);
      
      final differentMember = testFamilyMember.copyWith(role: 'member');
      expect(testFamilyMember == differentMember, false);
    });

    test('hashCodeが正しく機能する', () {
      final sameMember = FamilyMember(
        id: testFamilyMember.id,
        familyId: testFamilyMember.familyId,
        userId: testFamilyMember.userId,
        userName: testFamilyMember.userName,
        userEmail: testFamilyMember.userEmail,
        role: testFamilyMember.role,
      );

      expect(testFamilyMember.hashCode, sameMember.hashCode);
    });
  });

  group('User-Family 関連テスト', () {
    test('ユーザーが複数のファミリーに所属できる', () {
      final userWithMultipleFamilies = User(
        id: 'multi_family_user',
        name: '複数ファミリーユーザー',
        email: 'multi@example.com',
        avatarUrl: 'https://example.com/multi_avatar.jpg',
        familyIds: ['family_1', 'family_2', 'family_3'],
      );

      expect(userWithMultipleFamilies.familyIds.length, 3);
      expect(userWithMultipleFamilies.familyIds.contains('family_1'), true);
      expect(userWithMultipleFamilies.familyIds.contains('family_2'), true);
      expect(userWithMultipleFamilies.familyIds.contains('family_3'), true);
    });

    test('ファミリーが複数のメンバーを持てる', () {
      final familyWithMultipleMembers = Family(
        id: 'multi_member_family',
        name: '複数メンバーファミリー',
        description: '複数メンバーを持つファミリー',
        createdBy: 'creator_user',
        memberIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      );

      expect(familyWithMultipleMembers.memberIds.length, 4);
      expect(familyWithMultipleMembers.memberIds.contains('user_1'), true);
      expect(familyWithMultipleMembers.memberIds.contains('user_4'), true);
    });

    test('ユーザーとファミリーの関連性が正しく機能する', () {
      final testUser = User(
        id: 'test_user_1',
        name: 'テストユーザー1',
        email: 'test1@example.com',
        avatarUrl: 'https://example.com/avatar1.jpg',
        familyIds: ['test_family_1'],
      );

      final testFamily = Family(
        id: 'test_family_1',
        name: 'テストファミリー',
        description: 'テスト用のファミリー',
        createdBy: 'test_user_1',
        memberIds: ['test_user_1', 'test_user_2'],
      );

      final testMember = FamilyMember(
        id: 'test_member_1',
        familyId: 'test_family_1',
        userId: 'test_user_1',
        userName: 'テストユーザー1',
        userEmail: 'test1@example.com',
        role: 'admin',
      );

      // ユーザー1はファミリー1に所属
      expect(testUser.familyIds, ['test_family_1']);
      
      // ファミリー1にはユーザー1とユーザー2が所属
      expect(testFamily.memberIds, ['test_user_1', 'test_user_2']);
      
      // メンバー1はユーザー1としてファミリー1に所属
      expect(testMember.userId, 'test_user_1');
      expect(testMember.familyId, 'test_family_1');
      expect(testMember.role, 'admin');
    });
  });

  group('User-Family 境界値テスト', () {
    test('空の名前でUserを作成できる', () {
      final user = User(
        id: 'test_empty_name',
        name: '',
        email: 'empty@example.com',
        avatarUrl: 'https://example.com/empty_avatar.jpg',
        familyIds: [],
      );

      expect(user.name, '');
    });

    test('空のemailでUserを作成できる', () {
      final user = User(
        id: 'test_empty_email',
        name: '空メールユーザー',
        email: '',
        avatarUrl: 'https://example.com/empty_avatar.jpg',
        familyIds: [],
      );

      expect(user.email, '');
    });

    test('空のファミリーIDリストでUserを作成できる', () {
      final user = User(
        id: 'test_empty_families',
        name: '空ファミリーユーザー',
        email: 'empty_families@example.com',
        avatarUrl: 'https://example.com/empty_avatar.jpg',
        familyIds: [],
      );

      expect(user.familyIds.isEmpty, true);
    });

    test('空の名前でFamilyを作成できる', () {
      final family = Family(
        id: 'test_empty_name',
        name: '',
        description: '空名前ファミリー',
        createdBy: 'test_user',
        memberIds: [],
      );

      expect(family.name, '');
    });

    test('空のメンバーIDリストでFamilyを作成できる', () {
      final family = Family(
        id: 'test_empty_members',
        name: '空メンバーファミリー',
        description: '空メンバーのファミリー',
        createdBy: 'test_user',
        memberIds: [],
      );

      expect(family.memberIds.isEmpty, true);
    });

    test('空のロールでFamilyMemberを作成できる', () {
      final member = FamilyMember(
        id: 'test_empty_role',
        familyId: 'test_family',
        userId: 'test_user',
        userName: '空ロールメンバー',
        userEmail: 'empty@example.com',
        role: '',
      );

      expect(member.role, '');
    });
  });
}
