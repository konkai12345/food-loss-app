import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:provider/provider.dart';
import 'themes/natural_eco_theme.dart';
import 'screens/home_screen_improved.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/recipe_search_screen.dart';
import 'providers/shopping_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const FoodLossAppNaturalEco());
}

class FoodLossAppNaturalEco extends StatelessWidget {
  const FoodLossAppNaturalEco({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
      ],
      child: MaterialApp(
        title: '食品ロス削減アプリ',
        theme: NaturalEcoTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreenImproved(),
        routes: {
          '/shopping_list': (context) => const ShoppingListScreen(),
          '/recipe_search': (context) => const RecipeSearchScreen(),
        },
      ),
    );
  }
}
