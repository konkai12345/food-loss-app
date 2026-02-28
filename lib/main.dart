import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'themes/natural_eco_theme_fixed.dart';
import 'screens/home_screen_improved.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/family_management_screen.dart';
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
          '/inventory': (context) => const InventoryManagementScreen(),
          '/family': (context) => const FamilyManagementScreen(),
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
    const InventoryManagementScreen(),
    const FamilyManagementScreen(),
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
            icon: Icon(Icons.inventory),
            label: '在庫管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: '家族共有',
          ),
        ],
        selectedItemColor: NaturalEcoThemeFixed.primaryGreen,
        unselectedItemColor: NaturalEcoThemeFixed.mediumGrey,
      ),
    );
  }
}
