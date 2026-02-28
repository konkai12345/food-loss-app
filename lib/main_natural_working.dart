import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'themes/natural_eco_simple.dart';
import 'screens/home_screen_improved.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/recipe_search_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/qr_code_generator_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/purchase_management_screen.dart';
import 'screens/family_management_screen.dart';
import 'screens/data_export_screen.dart';
import 'screens/waste_separation_screen.dart';
import 'services/notification_service_simple.dart';
import 'providers/shopping_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 通知サービスの初期化
  final notificationService = NotificationServiceSimple();
  await notificationService.initialize();
  
  // 定期チェックの開始
  notificationService.startPeriodicCheck();

  runApp(FoodLossAppNaturalWorking(notificationService: notificationService));
}

class FoodLossAppNaturalWorking extends StatelessWidget {
  final NotificationServiceSimple notificationService;

  const FoodLossAppNaturalWorking({Key? key, required this.notificationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: '食品ロス削減アプリ',
        theme: NaturalEcoSimpleTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        routes: {
          '/shopping_list': (context) => const ShoppingListScreen(),
          '/recipe_search': (context) => const RecipeSearchScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/qr_generator': (context) => const QRCodeGeneratorScreen(),
          '/inventory': (context) => const InventoryManagementScreen(),
          '/purchase': (context) => const PurchaseManagementScreen(),
          '/family': (context) => const FamilyManagementScreen(),
          '/data_export': (context) => const DataExportScreen(),
          '/waste_separation': (context) => const WasteSeparationScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenImproved(),
    const ShoppingListScreen(),
    const RecipeSearchScreen(),
    const AnalyticsScreen(),
    const QRCodeGeneratorScreen(),
    const InventoryManagementScreen(),
    const PurchaseManagementScreen(),
    const FamilyManagementScreen(),
    const DataExportScreen(),
    const WasteSeparationScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'ホーム',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: '買い物リスト',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu),
      label: 'レシピ',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: '分析',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.qr_code),
      label: 'QRコード',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.inventory),
      label: '在庫管理',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long),
      label: '購入管理',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.family_restroom),
      label: '家族共有',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.file_download),
      label: 'データ出力',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.delete_outline),
      label: 'ゴミ分別',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: NaturalEcoSimpleTheme.primaryGreen,
        unselectedItemColor: NaturalEcoSimpleTheme.mediumGrey,
      ),
    );
  }
}
