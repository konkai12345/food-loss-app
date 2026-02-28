import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service_simple.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  final NotificationServiceSimple _notificationService = NotificationServiceSimple();
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _notificationService.getNotificationHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知履歴'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: '全てクリア',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '通知履歴がありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '食材を登録すると通知がここに表示されます',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final timestamp = DateTime.parse(notification['timestamp']);
    final isRead = notification['read'] ?? false;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _markAsRead(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 通知アイコン
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isRead ? Colors.grey[300] : Colors.green[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  _getNotificationIcon(notification['title']),
                  color: isRead ? Colors.grey[600] : Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // 通知内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isRead ? Colors.grey[600] : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['body'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isRead ? Colors.grey[500] : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MM/dd HH:mm').format(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 既読マーク
              if (!isRead)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String title) {
    if (title.contains('期限切れ')) {
      return Icons.error;
    } else if (title.contains('明日期限')) {
      return Icons.warning;
    } else if (title.contains('期限が近い')) {
      return Icons.info;
    } else if (title.contains('テスト')) {
      return Icons.notifications;
    }
    return Icons.notifications;
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
    _notificationService.markNotificationAsRead(_notifications[index]['id']);
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('すべての通知履歴をクリアしてもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              _notificationService.clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('通知履歴をクリアしました'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('クリア', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
