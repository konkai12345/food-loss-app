import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/food_item.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 通知設定
  bool _notificationsEnabled = true;
  int _notificationDays = 3; // 何日前に通知するか
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0); // 通知時間

  // 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Androidの初期化設定
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOSの初期化設定
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // タイムゾーンの設定
    tz.initializeTimeZones();
    
    _isInitialized = true;
    
    if (kDebugMode) {
      print('NotificationService initialized');
    }
  }

  // 通知権限のリクエスト
  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return result ?? true;
  }

  // 通知のスケジューリング
  Future<void> scheduleNotifications() async {
    if (!_notificationsEnabled) return;

    // 既存の通知をキャンセル
    await _notifications.cancelAll();

    try {
      final expiringItems = await DatabaseService.getExpiringSoonItems(
        days: _notificationDays,
      );

      final expiredItems = await DatabaseService.getExpiredItems();

      // 期限切れの通知
      for (final item in expiredItems) {
        await _scheduleNotification(
          id: item.id.hashCode,
          title: '🚨 期限切れ',
          body: '${item.name}の賞味期限が切れています',
          scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
          payload: item.id,
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

        // 通知時間を設定
        final scheduledDate = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _notificationTime.hour,
          _notificationTime.minute,
        );

        await _scheduleNotification(
          id: item.id.hashCode,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: item.id,
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

  // 個別通知のスケジューリング
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      0, // id
      _notificationDetails(title, body, payload),
      tz.TZDateTime.from(scheduledDate, tz.local),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // 通知詳細の設定
  NotificationDetails _notificationDetails(String title, String body, String? payload) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'food_loss_channel',
        '食品ロス削減通知',
        channelDescription: '食材の賞味期限をお知らせする通知',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color.fromARGB(255, 76, 175, 80),
        icon: '@mipmap/ic_launcher',
        largeIcon: payload != null ? const DrawableResourceAndroidBitmap('@mipmap/ic_launcher') : null,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      ),
    );
  }

  // 通知がタップされた時の処理
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // TODO: 食材詳細画面に遷移
      if (kDebugMode) {
        print('Notification tapped: ${response.payload}');
      }
    }
  }

  // 通知設定の更新
  void updateNotificationSettings({
    bool? enabled,
    int? days,
    TimeOfDay? time,
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
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'テスト通知',
      '通知機能は正常に動作しています',
      _notificationDetails('テスト通知', '通知機能は正常に動作しています', null),
    );
  }

  // 通知履歴の管理（簡易実装）
  List<Map<String, dynamic>> getNotificationHistory() {
    // TODO: 実際の通知履歴を保存する機能を実装
    return [
      {
        'id': '1',
        'title': 'テスト通知',
        'body': '通知機能は正常に動作しています',
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      },
    ];
  }

  // 通知を既読にする
  void markNotificationAsRead(String id) {
    // TODO: 通知履歴の既読状態を更新
  }

  // 全通知をクリア
  Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }
}
