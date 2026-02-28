import 'package:flutter/material.dart';
import 'notification_settings_screen.dart';
import 'notification_history_screen.dart';
import '../services/notification_service_simple.dart';

class HomeScreenSimple extends StatefulWidget {
  const HomeScreenSimple({super.key});

  @override
  State<HomeScreenSimple> createState() => _HomeScreenSimpleState();
}

class _HomeScreenSimpleState extends State<HomeScreenSimple> {
  int _selectedIndex = 0;
  late NotificationServiceSimple _notificationService;

  final List<Widget> _screens = [
    const HomeTab(),
    const NotificationSettingsTab(),
    const NotificationHistoryTab(),
  ];

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationServiceSimple();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('食品ロス削減アプリ'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '通知設定',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '通知履歴',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('食材登録機能は準備中です')),
                );
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen,
            size: 100,
            color: Colors.green,
          ),
          SizedBox(height: 20),
          Text(
            '食品ロス削減アプリ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'MVP開発中',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 30),
          Text(
            '機能:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10),
          Text('• 食材登録・管理'),
          Text('• 賞味期限通知'),
          Text('• カテゴリ別表示'),
          Text('• 検索機能'),
          SizedBox(height: 20),
          Text(
            '✅ 通知機能実装完了',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsTab extends StatelessWidget {
  const NotificationSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationSettingsScreen();
  }
}

class NotificationHistoryTab extends StatelessWidget {
  const NotificationHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationHistoryScreen();
  }
}
