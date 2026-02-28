import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/food_provider.dart';
import 'providers/shopping_provider.dart';
import 'providers/recipe_provider.dart';
import 'themes/natural_eco_theme.dart';
import 'screens/home_screen_natural_eco.dart';
import 'screens/shopping_list_screen_natural_eco.dart';
import 'screens/recipe_search_screen_natural_eco.dart';

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
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: '食品ロス削減アプリ',
        theme: NaturalEcoTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreenNaturalEco(),
        routes: {
          '/shopping_list': (context) => const ShoppingListScreenNaturalEco(),
          '/recipe_search': (context) => const RecipeSearchScreenNaturalEco(),
        },
      ),
    );
  }
}
