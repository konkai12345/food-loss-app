import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'database_service.dart';

class NotificationServiceSimple {
  static final NotificationServiceSimple _instance = NotificationServiceSimple._internal();
  factory NotificationServiceSimple() => _instance;
  NotificationServiceSimple._internal();

  // 通知設定
  bool _notificationsEnabled = true;
  int _notificationDays = 3; // 何日前に通知するか
  String _notificationTime = '09:00'; // 通知時間

  // 通知履歴の管理（簡易実装）
  List<Map<String, dynamic>> _notificationHistory = [];

  // 初期化
  Future<void> initialize() async {
    // テスト用に履歴をクリア
    _notificationHistory.clear();
    
    if (kDebugMode) {
      print('NotificationServiceSimple initialized');
    }
  }

  // 通知のスケジューリング（簡易実装）
  Future<void> scheduleNotifications() async {
    if (!_notificationsEnabled || kIsWeb) return;

    try {
      final expiringItems = await DatabaseService.getExpiringSoonItems(
        days: _notificationDays,
      );

      final expiredItems = await DatabaseService.getExpiredItems();

      // 期限切れの通知
      for (final item in expiredItems) {
        _addToHistory(
          title: '🚨 期限切れ',
          body: '${item.name}の賞味期限が切れています',
          itemId: item.id,
        );
      }

      // 期限が近い通知
      for (final item in expiringItems) {
        final daysLeft = item.daysUntilExpiry;
        String title;
        String body;

        if (daysLeft <= 0) {
          title = '🚨 期限切れ';
          body = '${item.name}の賞味期限が切れています';
        } else if (daysLeft == 1) {
          title = '⏰ 明日期限';
          body = '${item.name}の賞味期限が明日です';
        } else {
          title = '⚠️ 期限が近い';
          body = '${item.name}の賞味期限まであと$daysLeft日です';
        }

        _addToHistory(
          title: title,
          body: body,
          itemId: item.id,
        );
      }

      if (kDebugMode) {
        print('Scheduled ${expiringItems.length + expiredItems.length} notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notifications: $e');
      }
    }
  }

  // 通知履歴に追加
  void _addToHistory({
    required String title,
    required String body,
    required String itemId,
  }) {
    _notificationHistory.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'itemId': itemId,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });

    // 履歴は最新50件まで保持
    if (_notificationHistory.length > 50) {
      _notificationHistory = _notificationHistory.take(50).toList();
    }
  }

  // 通知設定の更新
  void updateNotificationSettings({
    bool? enabled,
    int? days,
    String? time,
  }) {
    if (enabled != null) _notificationsEnabled = enabled;
    if (days != null) _notificationDays = days;
    if (time != null) _notificationTime = time;

    // 設定変更後に通知を再スケジュール
    scheduleNotifications();
  }

  // 通知設定の取得
  Map<String, dynamic> getNotificationSettings() {
    return {
      'enabled': _notificationsEnabled,
      'days': _notificationDays,
      'time': _notificationTime,
    };
  }

  // 定期チェックの開始
  void startPeriodicCheck() {
    // 毎日通知をチェック
    Timer.periodic(const Duration(hours: 1), (timer) {
      scheduleNotifications();
    });
  }

  // テスト通知の送信
  Future<void> sendTestNotification() async {
    _addToHistory(
      title: 'テスト通知',
      body: '通知機能は正常に動作しています',
      itemId: 'test',
    );

    if (kDebugMode) {
      print('Test notification sent');
    }
  }

  // 通知履歴の取得
  List<Map<String, dynamic>> getNotificationHistory() {
    return List.from(_notificationHistory);
  }

  // 通知を既読にする
  void markNotificationAsRead(String id) {
    final index = _notificationHistory.indexWhere((notification) => notification['id'] == id);
    if (index != -1) {
      _notificationHistory[index]['read'] = true;
    }
  }

  // 全通知をクリア
  void clearAllNotifications() {
    _notificationHistory.clear();
  }
}
