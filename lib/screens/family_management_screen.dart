import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/family_service.dart';
import '../utils/error_handler.dart';

class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key});

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  List<Family> _families = [];
  List<FamilyMember> _familyMembers = [];
  List<User> _users = [];
  bool _isLoading = true;
  String _selectedTab = 'families';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final families = await FamilyService.getAllFamilies();
      final users = await FamilyService.getAllUsers();
      
      setState(() {
        _families = families;
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyManagementScreen._loadData');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFamilyMembers(String familyId) async {
    try {
      final members = await FamilyService.getFamilyMembers(familyId);
      setState(() {
        _familyMembers = members;
      });
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyManagementScreen._loadFamilyMembers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家族共有'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateFamilyDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // タブ選択
                _buildTabSelector(),
                const SizedBox(height: 16),
                
                // タブコンテンツ
                Expanded(
                  child: _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTabChip('families', 'ファミリー'),
          _buildTabChip('members', 'メンバー'),
          _buildTabChip('shared', '共有データ'),
        ],
      ),
    );
  }

  Widget _buildTabChip(String tab, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedTab == tab,
        onSelected: (selected) {
          setState(() {
            _selectedTab = tab;
          });
        },
        backgroundColor: _selectedTab == tab ? Colors.green : Colors.grey[200],
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: _selectedTab == tab ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'families':
        return _buildFamiliesTab();
      case 'members':
        return _buildMembersTab();
      case 'shared':
        return _buildSharedDataTab();
      default:
        return const Center(child: Text('不明なタブ'));
    }
  }

  Widget _buildFamiliesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _families.length,
      itemBuilder: (context, index) {
        final family = _families[index];
        return _buildFamilyCard(family);
      },
    );
  }

  Widget _buildFamilyCard(Family family) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(
            Icons.family_restroom,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(family.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(family.description),
            Text('メンバー数: ${family.memberIds.length}'),
            Text('作成日: ${family.createdAt.month}/${family.createdAt.day}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view_members',
              child: const Text('メンバー表示'),
              onTap: () => _viewFamilyMembers(family.id),
            ),
            PopupMenuItem(
              value: 'edit',
              child: const Text('編集'),
              onTap: () => _editFamily(family),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Text('削除'),
              onTap: () => _deleteFamily(family.id),
            ),
          ],
        ),
        tileColor: Colors.green.withOpacity(0.05),
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            user.name.isNotEmpty ? user.name[0] : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('ファミリー数: ${user.familyIds.length}'),
            Text('最終ログイン: ${user.lastLoginAt.month}/${user.lastLoginAt.day}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: const Text('編集'),
              onTap: () => _editUser(user),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Text('削除'),
              onTap: () => _deleteUser(user.id),
            ),
          ],
        ),
        tileColor: Colors.blue.withOpacity(0.05),
      ),
    );
  }

  Widget _buildSharedDataTab() {
    if (_families.isEmpty) {
      return const Center(
        child: Text('ファミリーがありません'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _families.length,
      itemBuilder: (context, index) {
        final family = _families[index];
        return _buildSharedDataCard(family);
      },
    );
  }

  Widget _buildSharedDataCard(Family family) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(
            Icons.share,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(family.name),
        subtitle: Text('共有データ'),
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FamilyService.getSharedData(family.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final sharedData = snapshot.data!;
              if (sharedData.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('共有データがありません'),
                );
              }

              return Column(
                children: sharedData.map((data) {
                  return ListTile(
                    title: Text(_getSharedDataType(data['type'])),
                    subtitle: Text('共有日時: ${_formatDateTime(data['sharedAt'])}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => _importSharedData(data),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getSharedDataType(String type) {
    switch (type) {
      case 'food_item':
        return '食材';
      case 'shopping_list':
        return '買い物リスト';
      case 'recipe':
        return 'レシピ';
      default:
        return '不明';
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  void _showCreateFamilyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';
        
        return AlertDialog(
          title: const Text('ファミリー作成'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'ファミリー名',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => description = value,
                maxLines: 3,
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
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  await _createFamily(name, description);
                }
              },
              child: const Text('作成'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createFamily(String name, String description) async {
    try {
      // 現在のユーザーIDを取得（簡易実装）
      final currentUserId = 'user_1'; // 実際はログイン情報から取得
      
      final family = await FamilyService.createFamily(
        name: name,
        description: description,
        createdBy: currentUserId,
      );
      
      // 作成者をメンバーとして追加
      await FamilyService.addFamilyMember(
        familyId: family.id,
        userId: currentUserId,
        userName: '現在のユーザー', // 実際はユーザー情報から取得
        userEmail: 'user@example.com', // 実際はユーザー情報から取得
        role: 'admin',
      );
      
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ファミリーを作成しました')),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyManagementScreen._createFamily');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ファミリーの作成に失敗しました')),
      );
    }
  }

  void _viewFamilyMembers(String familyId) async {
    await _loadFamilyMembers(familyId);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ファミリーメンバー'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _familyMembers.length,
              itemBuilder: (context, index) {
                final member = _familyMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      member.userName.isNotEmpty ? member.userName[0] : 'M',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(member.userName),
                  subtitle: Text(member.userEmail),
                  trailing: Text(member.role),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _editFamily(Family family) {
    showDialog(
      context: context,
      builder: (context) {
        String name = family.name;
        String description = family.description;
        
        return AlertDialog(
          title: const Text('ファミリー編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'ファミリー名',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: family.name),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '説明',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => description = value,
                controller: TextEditingController(text: family.description),
                maxLines: 3,
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
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  await _updateFamily(family.copyWith(name: name, description: description));
                }
              },
              child: const Text('更新'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateFamily(Family family) async {
    try {
      await FamilyService.updateFamily(family);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ファミリーを更新しました')),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyManagementScreen._updateFamily');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ファミリーの更新に失敗しました')),
      );
    }
  }

  void _deleteFamily(String familyId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ファミリー削除'),
          content: const Text('このファミリーを削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FamilyService.deleteFamily(familyId);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ファミリーを削除しました')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  void _editUser(User user) {
    showDialog(
      context: context,
      builder: (context) {
        String name = user.name;
        String email = user.email;
        
        return AlertDialog(
          title: const Text('ユーザー編集'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: '名前',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: user.name),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'メール',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => email = value,
                controller: TextEditingController(text: user.email),
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
                if (name.isNotEmpty) {
                  Navigator.pop(context);
                  await _updateUser(user.copyWith(name: name, email: email));
                }
              },
              child: const Text('更新'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUser(User user) async {
    try {
      await FamilyService.updateUser(user);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザーを更新しました')),
      );
    } catch (e) {
      AppErrorHandler.handleError(e, StackTrace.current, context: 'FamilyManagementScreen._updateUser');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ユーザーの更新に失敗しました')),
      );
    }
  }

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ユーザー削除'),
          content: const Text('このユーザーを削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FamilyService.deleteUser(userId);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ユーザーを削除しました')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  void _importSharedData(Map<String, dynamic> sharedData) {
    // 共有データのインポート処理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('データをインポートしました')),
    );
  }
}
