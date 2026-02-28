import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'themes/natural_eco_theme_fixed.dart';
import 'screens/home_screen_improved.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/qr_code_generator_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/purchase_management_screen.dart';
import 'screens/family_management_screen.dart';
import 'screens/data_export_screen.dart';
import 'screens/waste_separation_screen.dart';
import 'screens/recipe_screen.dart';
import 'services/notification_service_simple.dart';
import 'providers/shopping_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 通知サービスの初期化
  final notificationService = NotificationServiceSimple();
  await notificationService.initialize();
  
  // 定期チェックの開始
  notificationService.startPeriodicCheck();

  runApp(FoodLossApp(notificationService: notificationService));
}

class FoodLossApp extends StatelessWidget {
  final NotificationServiceSimple notificationService;

  const FoodLossApp({Key? key, required this.notificationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: '食品ロス削減アプリ',
        theme: NaturalEcoThemeFixed.theme,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        routes: {
          '/shopping_list': (context) => const ShoppingListScreen(),
          '/recipe_search': (context) => const RecipeScreen(),
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
    const RecipeScreen(),
    const AnalyticsScreen(),
    const QRCodeGeneratorScreen(),
    const InventoryManagementScreen(),
    const PurchaseManagementScreen(),
    const FamilyManagementScreen(),
    const DataExportScreen(),
    const WasteSeparationScreen(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '買い物リスト',
          ),
          BottomNavigationBarItem(
            icon: Icons.restaurant_menu),
            label: 'レシピ',
          ),
          BottomNavigationBarItem(
            icon: Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QRコード',
          ),
          BottomNavigationBarItem(
            icon: Icons.inventory),
            label: '在庫管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: '購入管理',
          ),
          BottomNavigationBarItem(
            icon: Icons.family_restroom),
            label: '家族共有',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download),
            label: 'データ出力',
          ),
          BottomNavigationBarItem(
            icon: Icons.delete_outline),
            label: 'ゴミ分別',
          ),
        ],
        selectedItemColor: NaturalEcoThemeFixed.primaryGreen,
        unselectedItemColor: NaturalEcoThemeFixed.mediumGrey,
      ),
    );
  }
}
