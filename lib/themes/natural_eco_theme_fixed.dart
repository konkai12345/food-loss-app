import 'package:flutter/material.dart';

class NaturalEcoThemeFixed {
  // カラーパレット
  static const Color primaryGreen = Color(0xFF4CAF50);      // 新緑
  static const Color woodBrown = Color(0xFF8D6E63);        // 木の実色
  static const Color skyBlue = Color(0xFF81D4FA);          // 空色
  static const Color linenBackground = Color(0xFFF5F5DC);     // 亜麻布風背景
  static const Color white = Color(0xFFFFFFFF);              // 白
  static const Color lightGrey = Color(0xFFF5F5F5);         // 薄グレー
  static const Color mediumGrey = Color(0xFF757575);        // 中グレー
  static const Color darkGrey = Color(0xFF424242);         // 濃グレー

  // シンプルなテーマ
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.green,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      
      // アプリバー
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 4,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // カード
      cardTheme: CardTheme(
        color: white,
        elevation: 4,
        shadowColor: woodBrown.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ボタン
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // フローティングアクションボタン
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),

      // 入力フィールド
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: woodBrown.withOpacity(0.3),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: woodBrown.withOpacity(0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: primaryGreen,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          color: woodBrown,
        ),
        hintStyle: const TextStyle(
          color: mediumGrey,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // チップ
      chipTheme: ChipThemeData(
        backgroundColor: lightGrey,
        selectedColor: primaryGreen,
        disabledColor: mediumGrey.withOpacity(0.3),
        labelStyle: const TextStyle(
          color: darkGrey,
        ),
        secondaryLabelStyle: const TextStyle(
          color: white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),

      // リストタイル
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        tileColor: white,
        titleTextStyle: TextStyle(
          color: darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: mediumGrey,
          fontSize: 14,
        ),
      ),

      // アイコン
      iconTheme: const IconThemeData(
        color: darkGrey,
        size: 24,
      ),

      // テキスト
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkGrey,
          fontSize: 32,
          fontWeight: FontWeight.w300,
        ),
        displayMedium: TextStyle(
          color: darkGrey,
          fontSize: 28,
          fontWeight: FontWeight.w300,
        ),
        displaySmall: TextStyle(
          color: darkGrey,
          fontSize: 24,
          fontWeight: FontWeight.w300,
        ),
        headlineLarge: TextStyle(
          color: darkGrey,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: darkGrey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: darkGrey,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: darkGrey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: darkGrey,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: darkGrey,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: mediumGrey,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: mediumGrey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: TextStyle(
          color: mediumGrey,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 背景とボトムナビ
      scaffoldBackgroundColor: linenBackground,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: mediumGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
