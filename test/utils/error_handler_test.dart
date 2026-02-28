import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_loss_app/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    testWidgets('showErrorDialogが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppErrorHandler.showErrorDialog(
                      context,
                      'テストエラーメッセージ',
                      title: 'テストエラー',
                    );
                  },
                  child: const Text('エラーを表示'),
                );
              },
            ),
          ),
        ),
      );

      // ボタンをタップ
      await tester.tap(find.text('エラーを表示'));
      await tester.pumpAndSettle();

      // エラーダイアログが表示されていること
      expect(find.text('テストエラー'), findsOneWidget);
      expect(find.text('テストエラーメッセージ'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('showSuccessSnackBarが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppErrorHandler.showSuccessSnackBar(
                      context,
                      '成功メッセージ',
                    );
                  },
                  child: const Text('成功を表示'),
                );
              },
            ),
          ),
        ),
      );

      // ボタンをタップ
      await tester.tap(find.text('成功を表示'));
      await tester.pumpAndSettle();

      // SnackBarが表示されていること
      expect(find.text('成功メッセージ'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('showErrorSnackBarが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppErrorHandler.showErrorSnackBar(
                      context,
                      'エラーメッセージ',
                    );
                  },
                  child: const Text('エラーを表示'),
                );
              },
            ),
          ),
        ),
      );

      // ボタンをタップ
      await tester.tap(find.text('エラーを表示'));
      await tester.pumpAndSettle();

      // SnackBarが表示されていること
      expect(find.text('エラーメッセージ'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('showInfoSnackBarが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppErrorHandler.showInfoSnackBar(
                      context,
                      '情報メッセージ',
                    );
                  },
                  child: const Text('情報を表示'),
                );
              },
            ),
          ),
        ),
      );

      // ボタンをタップ
      await tester.tap(find.text('情報を表示'));
      await tester.pumpAndSettle();

      // SnackBarが表示されていること
      expect(find.text('情報メッセージ'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });
  });

  group('AppException Tests', () {
    test('AppExceptionが正しく作成されること', () {
      final exception = AppException('テストエラー', code: 'TEST_ERROR');
      
      expect(exception.message, 'テストエラー');
      expect(exception.code, 'TEST_ERROR');
      expect(exception.toString(), 'AppException: テストエラー (Code: TEST_ERROR)');
    });

    test('DatabaseExceptionが正しく作成されること', () {
      final exception = DatabaseException('データベースエラー');
      
      expect(exception.message, 'データベースエラー');
      expect(exception.toString(), 'AppException: データベースエラー');
    });

    test('NetworkExceptionが正しく作成されること', () {
      final exception = NetworkException('ネットワークエラー');
      
      expect(exception.message, 'ネットワークエラー');
      expect(exception.toString(), 'AppException: ネットワークエラー');
    });

    test('ValidationExceptionが正しく作成されること', () {
      final exception = ValidationException('バリデーションエラー');
      
      expect(exception.message, 'バリデーションエラー');
      expect(exception.toString(), 'AppException: バリデーションエラー');
    });
  });
}
