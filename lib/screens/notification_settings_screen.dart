import 'package:flutter/material.dart';
import '../services/notification_service_simple.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationServiceSimple _notificationService = NotificationServiceSimple();
  
  bool _notificationsEnabled = true;
  int _notificationDays = 3;
  String _notificationTime = '09:00';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _notificationService.getNotificationSettings();
    setState(() {
      _notificationsEnabled = settings['enabled'];
      _notificationDays = settings['days'];
      _notificationTime = settings['time'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 通知の有効/無効
          SwitchListTile(
            title: const Text('通知を有効にする'),
            subtitle: const Text('賞味期限が近い食材をお知らせます'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _notificationService.updateNotificationSettings(enabled: value);
            },
            activeColor: Colors.green,
          ),
          
          const Divider(),
          
          // 通知タイミングの設定
          if (_notificationsEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '通知タイミング',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // 何日前に通知するか
            ListTile(
              title: const Text('通知する日数'),
              subtitle: Text('賞味期限の何日前に通知するか'),
              trailing: DropdownButton<int>(
                value: _notificationDays,
                items: [1, 2, 3, 5, 7].map((days) {
                  return DropdownMenuItem(
                    value: days,
                    child: Text('$days日前'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _notificationDays = value;
                    });
                    _notificationService.updateNotificationSettings(days: value);
                  }
                },
              ),
            ),
            
            const Divider(),
            
            // 通知時間の設定
            ListTile(
              title: const Text('通知時間'),
              subtitle: Text('毎日この時間に通知を送信します'),
              trailing: TextButton(
                onPressed: _selectTime,
                child: Text(
                  _notificationTime,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const Divider(),
            
            // テスト通知
            ListTile(
              title: const Text('テスト通知'),
              subtitle: const Text('通知機能の動作を確認できます'),
              trailing: ElevatedButton(
                onPressed: _sendTestNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('送信'),
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // 説明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '通知について',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• 通知はアプリ内で管理されます'),
                  const Text('• 期限切れの食材はすぐに検出されます'),
                  const Text('• 通知履歴から確認できます'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_notificationTime.split(':')[0]),
        minute: int.parse(_notificationTime.split(':')[1]),
      ),
    );
    
    if (picked != null) {
      setState(() {
        _notificationTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
      _notificationService.updateNotificationSettings(time: _notificationTime);
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.sendTestNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('テスト通知を送信しました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('通知の送信に失敗しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
