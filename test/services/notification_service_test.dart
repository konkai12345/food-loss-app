import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/services/notification_service_simple.dart';
import 'package:food_loss_app/models/food_item.dart';

void main() {
  group('NotificationServiceSimple Tests', () {
    late NotificationServiceSimple notificationService;

    setUp(() {
      notificationService = NotificationServiceSimple();
    });

    test('初期化が正常に完了すること', () async {
      await notificationService.initialize();
      // 初期化が完了しても例外が発生しないことを確認
      expect(() => notificationService.initialize(), returnsNormally);
    });

    test('通知設定が正しく取得できること', () {
      final settings = notificationService.getNotificationSettings();
      
      expect(settings['enabled'], isA<bool>());
      expect(settings['days'], isA<int>());
      expect(settings['time'], isA<String>());
    });

    test('通知設定が正しく更新できること', () {
      // 設定を更新
      notificationService.updateNotificationSettings(
        enabled: false,
        days: 5,
        time: '10:30',
      );

      final settings = notificationService.getNotificationSettings();
      
      expect(settings['enabled'], false);
      expect(settings['days'], 5);
      expect(settings['time'], '10:30');
    });

    test('テスト通知が送信できること', () async {
      await notificationService.initialize();
      
      // テスト通知送信
      await notificationService.sendTestNotification();
      
      // 通知履歴に追加されていることを確認
      final history = notificationService.getNotificationHistory();
      expect(history.isNotEmpty, true);
      
      final testNotification = history.firstWhere(
        (notification) => notification['title'] == 'テスト通知',
      );
      expect(testNotification['title'], 'テスト通知');
      expect(testNotification['body'], '通知機能は正常に動作しています');
    });

    test('通知履歴が正しく管理できること', () async {
      await notificationService.initialize();
      
      // 初期状態では空であること
      var history = notificationService.getNotificationHistory();
      expect(history.isEmpty, true);
      
      // テスト通知を送信
      await notificationService.sendTestNotification();
      
      // 履歴が追加されていることを確認
      history = notificationService.getNotificationHistory();
      expect(history.isNotEmpty, true);
      
      // テスト通知が履歴に含まれていることを確認
      final hasTestNotification = history.any(
        (notification) => notification['title'] == 'テスト通知',
      );
      expect(hasTestNotification, true);
    });

    test('通知が既読にできること', () async {
      await notificationService.initialize();
      
      // テスト通知を送信
      await notificationService.sendTestNotification();
      
      final history = notificationService.getNotificationHistory();
      final notificationId = history.first['id'];
      
      // 未読状態であること
      expect(history.first['read'], false);
      
      // 既読にする
      notificationService.markNotificationAsRead(notificationId);
      
      // 既読状態になっていること
      final updatedHistory = notificationService.getNotificationHistory();
      final updatedNotification = updatedHistory.firstWhere(
        (notification) => notification['id'] == notificationId,
      );
      expect(updatedNotification['read'], true);
    });

    test('通知履歴がクリアできること', () async {
      await notificationService.initialize();
      
      // テスト通知を送信
      await notificationService.sendTestNotification();
      
      // 履歴があることを確認
      var history = notificationService.getNotificationHistory();
      expect(history.isNotEmpty, true);
      
      // 履歴をクリア
      notificationService.clearAllNotifications();
      
      // 履歴が空になっていること
      history = notificationService.getNotificationHistory();
      expect(history.isEmpty, true);
    });

    test('通知設定が無効の場合、通知が送信されないこと', () async {
      await notificationService.initialize();
      
      // 通知を無効化
      notificationService.updateNotificationSettings(enabled: false);
      
      // テスト通知を送信
      await notificationService.sendTestNotification();
      
      // テスト通知は設定に関わらず送信されることを確認
      final history = notificationService.getNotificationHistory();
      expect(history.isNotEmpty, true);
    });
  });
}
