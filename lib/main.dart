import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shopping_provider.dart';
import 'screens/home_screen_improved.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/inventory_list_screen.dart';
import 'themes/natural_eco_theme_fixed.dart';
import 'services/notification_service_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 通知サービスの初期化
  await NotificationServiceSimple().initialize();
  
  runApp(FoodLossApp());
}

class FoodLossApp extends StatelessWidget {
  const FoodLossApp({super.key});

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
          '/inventory': (context) => const InventoryListScreen(),
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
  ];

  @override
  void initState() {
    super.initState();
    // 通知の定期チェックを開始
    NotificationServiceSimple().startPeriodicCheck();
  }

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
            icon: Icon(Icons.inventory),
            label: '在庫管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '買い物リスト',
          ),
        ],
        selectedItemColor: NaturalEcoThemeFixed.primaryGreen,
        unselectedItemColor: NaturalEcoThemeFixed.mediumGrey,
      ),
    );
  }
}
