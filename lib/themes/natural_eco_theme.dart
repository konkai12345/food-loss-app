import 'package:flutter/material.dart';

class NaturalEcoTheme {
  // カラーパレット
  static const Color primaryGreen = Color(0xFF4CAF50);      // 新緑
  static const Color woodBrown = Color(0xFF8D6E63);        // 木の実色
  static const Color skyBlue = Color(0xFF81D4FA);          // 空色
  static const Color linenBackground = Color(0xFFF5F5DC);     // 亜麻布風背景
  static const Color lightGreen = Color(0xFF81C784);        // 薄緑
  static const Color darkGreen = Color(0xFF2E7D32);         // 深緑
  static const Color lightBrown = Color(0xFFD7CCC8);        // 薄茶色
  static const Color white = Color(0xFFFFFFFF);              // 白
  static const Color lightGrey = Color(0xFFF5F5F5);         // 薄グレー
  static const Color mediumGrey = Color(0xFF757575);        // 中グレー
  static const Color darkGrey = Color(0xFF424242);         // 濃グレー

  // グラデーション
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient woodGradient = LinearGradient(
    colors: [woodBrown, lightBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // テーマデータ
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: woodBrown,
        tertiary: skyBlue,
        surface: linenBackground,
        background: linenBackground,
        error: Color(0xFFE57373),
        onPrimary: white,
        onSecondary: white,
        onTertiary: white,
        onSurface: darkGrey,
        onBackground: darkGrey,
        onError: white,
      ),
      
      // アプリバーのテーマ
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 4,
        titleTextStyle: const TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        iconTheme: const IconThemeData(
          color: white,
          size: 24,
        ),
      ),

      // カードのテーマ
      cardTheme: CardTheme(
        color: white,
        elevation: 8,
        shadowColor: woodBrown.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: woodBrown.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ボタンのテーマ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          elevation: 6,
          shadowColor: woodBrown.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'RoundedMplus1c',
          ),
        ),
      ),

      // フローティングアクションボタンのテーマ
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        extendedTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
      ),

      // 入力フィールドのテーマ
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Color(0xFFE57373),
            width: 2,
          ),
        ),
        labelStyle: TextStyle(
          color: woodBrown,
          fontFamily: 'RoundedMplus1c',
        ),
        hintStyle: TextStyle(
          color: mediumGrey,
          fontFamily: 'RoundedMplus1c',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // チップのテーマ
      chipTheme: ChipThemeData(
        backgroundColor: lightGrey,
        selectedColor: primaryGreen,
        disabledColor: mediumGrey.withOpacity(0.3),
        labelStyle: const TextStyle(
          color: darkGrey,
          fontFamily: 'RoundedMplus1c',
        ),
        secondaryLabelStyle: const TextStyle(
          color: white,
          fontFamily: 'RoundedMplus1c',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        side: BorderSide(
          color: woodBrown.withOpacity(0.2),
          width: 1,
        ),
      ),

      // リストタイルのテーマ
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
          fontFamily: 'RoundedMplus1c',
        ),
        subtitleTextStyle: TextStyle(
          color: mediumGrey,
          fontSize: 14,
          fontFamily: 'RoundedMplus1c',
        ),
      ),

      // アイコンのテーマ
      iconTheme: const IconThemeData(
        color: darkGrey,
        size: 24,
      ),

      // テキストのテーマ
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkGrey,
          fontSize: 32,
          fontWeight: FontWeight.w300,
          fontFamily: 'RoundedMplus1c',
        ),
        displayMedium: TextStyle(
          color: darkGrey,
          fontSize: 28,
          fontWeight: FontWeight.w300,
          fontFamily: 'RoundedMplus1c',
        ),
        displaySmall: TextStyle(
          color: darkGrey,
          fontSize: 24,
          fontWeight: FontWeight.w300,
          fontFamily: 'RoundedMplus1c',
        ),
        headlineLarge: TextStyle(
          color: darkGrey,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        headlineMedium: TextStyle(
          color: darkGrey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        headlineSmall: TextStyle(
          color: darkGrey,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        titleLarge: TextStyle(
          color: darkGrey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        titleMedium: TextStyle(
          color: darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        titleSmall: TextStyle(
          color: darkGrey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        bodyLarge: TextStyle(
          color: darkGrey,
          fontSize: 16,
          fontFamily: 'RoundedMplus1c',
        ),
        bodyMedium: TextStyle(
          color: darkGrey,
          fontSize: 14,
          fontFamily: 'RoundedMplus1c',
        ),
        bodySmall: TextStyle(
          color: mediumGrey,
          fontSize: 12,
          fontFamily: 'RoundedMplus1c',
        ),
        labelLarge: TextStyle(
          color: darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        labelMedium: TextStyle(
          color: mediumGrey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        labelSmall: TextStyle(
          color: mediumGrey,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
      ),

      // 背景のテーマ
      scaffoldBackgroundColor: linenBackground,

      // ボトムナビゲーションのテーマ
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: mediumGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'RoundedMplus1c',
        ),
      ),

      // タブのテーマ
      tabBarTheme: TabBarTheme(
        labelColor: primaryGreen,
        unselectedLabelColor: mediumGrey,
        indicatorColor: primaryGreen,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'RoundedMplus1c',
        ),
      ),

      // ダイアログのテーマ
      dialogTheme: DialogTheme(
        backgroundColor: white,
        elevation: 12,
        shadowColor: woodBrown.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        titleTextStyle: const TextStyle(
          color: darkGrey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'RoundedMplus1c',
        ),
        contentTextStyle: const TextStyle(
          color: darkGrey,
          fontSize: 16,
          fontFamily: 'RoundedMplus1c',
        ),
      ),

      // スナックバーのテーマ
      snackBarTheme: SnackBarThemeData(
        backgroundColor: woodBrown,
        contentTextStyle: const TextStyle(
          color: white,
          fontSize: 14,
          fontFamily: 'RoundedMplus1c',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
    );
  }

  // カスタムコンポーネント用のスタイル
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: woodBrown.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: woodBrown.withOpacity(0.05),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ],
      border: Border.all(
        color: woodBrown.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  static BoxDecoration get primaryButtonDecoration {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: primaryGreen.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  static BoxDecoration get statCardDecoration {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [white, lightGrey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: woodBrown.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(
        color: woodBrown.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  static BoxDecoration get expiringCardDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFFF3E0), white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Color(0xFFFF9800).withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      border: Border.all(
        color: Color(0xFFFF9800).withOpacity(0.3),
        width: 2,
      ),
    );
  }

  static BoxDecoration get expiredCardDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFFEBEE), white],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Color(0xFFF44336).withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      border: Border.all(
        color: Color(0xFFF44336).withOpacity(0.3),
        width: 2,
      ),
    );
  }
}
